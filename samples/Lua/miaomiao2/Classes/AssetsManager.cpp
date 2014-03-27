/****************************************************************************
 Copyright (c) 2013 cocos2d-x.org
 
 http://www.cocos2d-x.org
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/


#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#define PATHSEP "\\"
#else
#define PATHSEP "/"
#endif

#include "AssetsManager.h"
#include "cocos2d.h"

#include <curl/curl.h>
#include <curl/easy.h>
#include <stdio.h>
#include <vector>

#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#endif

#include "support/zip_support/unzip.h"
#if CC_TARGET_PLATFORM != CC_PLATFORM_WIN32
#include "pthread.h"
#endif
using namespace cocos2d;
using namespace std;

//NS_CC_EXT_BEGIN;

#define KEY_OF_VERSION   "current-version-code"
#define KEY_OF_DOWNLOADED_VERSION    "downloaded-version-code"
#define TEMP_PACKAGE_FILE_NAME    "cocos2dx-update-temp-package.zip"
#define BUFFER_SIZE    8192
#define MAX_FILENAME   512

int progress = 0;
AssetsManager *publicAssets = NULL;

AssetsManager::AssetsManager()
: _packageUrl("")
, _versionFileUrl("")
, _version("")
, _curl(NULL)
{
    _storagePath = CCFileUtils::sharedFileUtils()->getWritablePath();
    checkStoragePath();
}

AssetsManager::AssetsManager(const char* packageUrl, const char* versionFileUrl)
: _packageUrl(packageUrl)
, _version("")
, _versionFileUrl(versionFileUrl)
, _curl(NULL)
{
    _storagePath = CCFileUtils::sharedFileUtils()->getWritablePath();
    checkStoragePath();
}

AssetsManager::AssetsManager(const char* packageUrl, const char* versionFileUrl, const char* storagePath)
: _packageUrl(packageUrl)
, _version("")
, _versionFileUrl(versionFileUrl)
, _storagePath(storagePath)
, _curl(NULL)
{
    checkStoragePath();
}

void AssetsManager::checkStoragePath()
{
       
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
    if (_storagePath.size() > 0 && _storagePath[_storagePath.size() - 1] != '/')
    {
        _storagePath.append("/");
    }
#else

#endif
}

static size_t getVersionCode(void *ptr, size_t size, size_t nmemb, void *userdata)
{
    string *version = (string*)userdata;
    version->append((char*)ptr, size * nmemb);
    
    return (size * nmemb);
}

bool AssetsManager::checkUpdate()
{
    if (_versionFileUrl.size() == 0) return false;
    
    _curl = curl_easy_init();
    if (! _curl)
    {
        CCLOG("can not init curl");
        return false;
    }
    
    // Clear _version before assign new value.
    _version.clear();
    
    CCLog("start version url Update %s", _versionFileUrl.c_str());
    CURLcode res;
    curl_easy_setopt(_curl, CURLOPT_URL, _versionFileUrl.c_str());
    curl_easy_setopt(_curl, CURLOPT_SSL_VERIFYPEER, 0L);
    curl_easy_setopt(_curl, CURLOPT_WRITEFUNCTION, getVersionCode);
    curl_easy_setopt(_curl, CURLOPT_WRITEDATA, &_version);
    res = curl_easy_perform(_curl);
    
    if (res != 0)
    {
        CCLOG("can not get version file content, error code is %d", res);
        curl_easy_cleanup(_curl);
        return false;
    }
    
    string recordedVersion = CCUserDefault::sharedUserDefault()->getStringForKey(KEY_OF_VERSION);
    if (recordedVersion == _version)
    {
        CCLOG("there is not new version");
        // Set resource search path.
        setSearchPath();
        return false;
    }
    
    CCLOG("there is a new version: %s", _version.c_str());
    
    return true;
}
void AssetsManager::updateVersion() {
    CCLog("updateVersion");

    CCUserDefault::sharedUserDefault()->setStringForKey(KEY_OF_VERSION, _version.c_str());
    // Unrecord downloaded version code.
    CCUserDefault::sharedUserDefault()->setStringForKey(KEY_OF_DOWNLOADED_VERSION, "");
    CCUserDefault::sharedUserDefault()->flush();
    string v = CCUserDefault::sharedUserDefault()->getStringForKey(KEY_OF_VERSION);
    CCLog("update new version %s %s", v.c_str(), _version.c_str());
}
//当progress == 200 的时候 下载结束
static void* assetsManagerDownloadAndUncompress(void *data) {
	AssetsManager* self = (AssetsManager*)data;
	string downloadedVersion = CCUserDefault::sharedUserDefault()->getStringForKey(KEY_OF_DOWNLOADED_VERSION);
    if (downloadedVersion != self->_version)
    {
        if (! self->downLoad()) {
			progress = 200;
			return false;
		}
        CCLog("downloading finish");
        //不应该在这里修改版本信息
        //主线程才能修改
        // Record downloaded version.
        CCUserDefault::sharedUserDefault()->setStringForKey(KEY_OF_DOWNLOADED_VERSION, self->_version.c_str());
        CCUserDefault::sharedUserDefault()->flush();
    }
    
    // Uncompress zip file.
    if (! self->uncompress()) {
		progress = 200;
        CCLog("uncompress failed !!");
		return false;
	}
    //self->updateVersion();
    //更新结束在主线程调用 updateVersion 写入到 UserDefault 中
    // Set resource search path.
    //self->setSearchPath();
    
    // Delete unloaded zip file.
    string zipfileName = self->_storagePath + TEMP_PACKAGE_FILE_NAME;
    if (remove(zipfileName.c_str()) != 0)
    {
        CCLOG("can not remove downloaded zip file");
    }
    CCLog("finish update script");
	progress = 200;
}
#if CC_TARGET_PLATFORM != CC_PLATFORM_WIN32
static pthread_t *_tid; 
#endif
bool AssetsManager::update()
{
    // 1. Urls of package and version should be valid;
    // 2. Package should be a zip file.
    if (_versionFileUrl.size() == 0 ||
        _packageUrl.size() == 0 ||
        std::string::npos == _packageUrl.find(".zip"))
    {
        CCLOG("no version file url, or no package url, or the package is not a zip file");
		progress = 200;
        return false;
    }
    
    // Check if there is a new version.
    if (! checkUpdate()) {
		progress = 200;
		return false;
	}
    //UpdateScene 里面更新脚本 
    //因此不要在AppDelegate 里面调用UpdateFile
	#if CC_TARGET_PLATFORM != CC_PLATFORM_WIN32
	pthread_mutex_init(&_message, NULL);
	_tid = new pthread_t();
	pthread_create(&(*_tid), NULL, assetsManagerDownloadAndUncompress, this);
	//下载结束线程通知
	#else
	assetsManagerDownloadAndUncompress(this);
	#endif
    return true;
}

bool AssetsManager::uncompress()
{
    // Open the zip file
    string outFileName = _storagePath + TEMP_PACKAGE_FILE_NAME;
    CCLOG("outFileName %s %s", _storagePath.c_str(), TEMP_PACKAGE_FILE_NAME);
    unzFile zipfile = unzOpen(outFileName.c_str());

    if (! zipfile)
    {
        CCLOG("can not open downloaded zip file %s", outFileName.c_str());
        return false;
    }
    
    // Get info about the zip file
    unz_global_info global_info;
    if (unzGetGlobalInfo(zipfile, &global_info) != UNZ_OK)
    {
        CCLOG("can not read file global info of %s", outFileName.c_str());
        unzClose(zipfile);
    }
    
    // Buffer to hold data read from the zip file
    char readBuffer[BUFFER_SIZE];
    
    CCLOG("start uncompressing");
    
    // Loop to extract all files.
    uLong i;
    for (i = 0; i < global_info.number_entry; ++i)
    {
        // Get info about current file.
        unz_file_info fileInfo;
        char fileName[MAX_FILENAME];
        if (unzGetCurrentFileInfo(zipfile,
                                  &fileInfo,
                                  fileName,
                                  MAX_FILENAME,
                                  NULL,
                                  0,
                                  NULL,
                                  0) != UNZ_OK)
        {
            CCLOG("can not read file info");
            unzClose(zipfile);
            return false;
        }
        
        string fullPath = _storagePath + fileName;
        CCLog("full path of file is %s", fullPath.c_str());

        //windows下替换所有/ 为\\ 路径
        #if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
        int position = fullPath.find("/");
        while(position != std::string::npos) {
            fullPath.replace(position, 1, "\\");
            position = fullPath.find("\\", position+1);
        }
        #endif   

        //cout << "uncompress full path " << fullPath << endl;
        
        // Check if this entry is a directory or a file.
        const size_t filenameLength = strlen(fileName);
        if (fileName[filenameLength-1] == '/')
        {
            // Entry is a direcotry, so create it.
            // If the directory exists, it will failed scilently.
            if (!createDirectory(fullPath.c_str()))
            {
                CCLOG("can not create directory %s", fullPath.c_str());
                unzClose(zipfile);
                return false;
            }
        }
        else
        {
            // Entry is a file, so extract it.
            
            // Open current file.
            if (unzOpenCurrentFile(zipfile) != UNZ_OK)
            {
                CCLOG("can not open file %s", fileName);
                unzClose(zipfile);
                return false;
            }
            
            // Create a file to store current file.
            FILE *out = fopen(fullPath.c_str(), "wb");
            if (! out)
            {
                CCLOG("can not open destination file %s", fullPath.c_str());
                unzCloseCurrentFile(zipfile);
                unzClose(zipfile);
                return false;
            }
            
            // Write current file content to destinate file.
            int error = UNZ_OK;
            do
            {
                error = unzReadCurrentFile(zipfile, readBuffer, BUFFER_SIZE);
                if (error < 0)
                {
                    CCLOG("can not read zip file %s, error code is %d", fileName, error);
                    unzCloseCurrentFile(zipfile);
                    unzClose(zipfile);
                    return false;
                }
                
                if (error > 0)
                {
                    fwrite(readBuffer, error, 1, out);
                }
            } while(error > 0);
            
            fclose(out);
        }
        
        unzCloseCurrentFile(zipfile);
        
        // Goto next entry listed in the zip file.
        if ((i+1) < global_info.number_entry)
        {
            //unzGotoNextFile(zipfile);
            if (unzGoToNextFile(zipfile) != UNZ_OK)
            {
                CCLOG("can not read next file");
                unzClose(zipfile);
                return false;
            }
        }
    }
    
    CCLOG("end uncompressing");
    
    return true;
}

/*
 * Create a direcotry is platform depended.
 */
bool AssetsManager::createDirectory(const char *path)
{
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
    mode_t processMask = umask(0);
    int ret = mkdir(path, S_IRWXU | S_IRWXG | S_IRWXO);
    umask(processMask);
    if (ret != 0 && (errno != EEXIST))
    {
        return false;
    }
    
    return true;
#else
    BOOL ret = CreateDirectoryA(path, NULL);
	if (!ret && ERROR_ALREADY_EXISTS != GetLastError())
	{
		return false;
	}
    return true;
#endif
}

void AssetsManager::setSearchPath()
{
    /*
    没有必要设定 资源路径 如果不用 图片资源
    vector<string> searchPaths = CCFileUtils::sharedFileUtils()->getSearchPaths();
    vector<string>::iterator iter = searchPaths.begin();
    searchPaths.insert(iter, _storagePath);
    CCFileUtils::sharedFileUtils()->setSearchPaths(searchPaths);
    */
}

static size_t downLoadPackage(void *ptr, size_t size, size_t nmemb, void *userdata)
{
    FILE *fp = (FILE*)userdata;
    size_t written = fwrite(ptr, size, nmemb, fp);
    return written;
}
static AssetsManager *am;
#if CC_TARGET_PLATFORM != CC_PLATFORM_WIN32
pthread_mutex_t _message;
#endif
static int progressFunc(void *ptr, double totalToDownload, double nowDownloaded, double totalToUpLoad, double nowUpLoaded)
{
    CCLOG("downloading... %d%%", (int)(nowDownloaded/totalToDownload*100));
	progress = (int)(nowDownloaded/totalToDownload*100);
	return 0;
}

bool AssetsManager::downLoad()
{
	am = this;
    CCLog("download package file", _packageUrl.c_str());
    // Create a file to save package.
    string outFileName = _storagePath + TEMP_PACKAGE_FILE_NAME;
    FILE *fp = fopen(outFileName.c_str(), "wb");
    if (! fp)
    {
        CCLOG("can not create file %s", outFileName.c_str());
        return false;
    }
    
    // Download pacakge
    CURLcode res;
    curl_easy_setopt(_curl, CURLOPT_URL, _packageUrl.c_str());
    curl_easy_setopt(_curl, CURLOPT_WRITEFUNCTION, downLoadPackage);
    curl_easy_setopt(_curl, CURLOPT_WRITEDATA, fp);
    curl_easy_setopt(_curl, CURLOPT_NOPROGRESS, false);
    curl_easy_setopt(_curl, CURLOPT_PROGRESSFUNCTION, progressFunc);
    res = curl_easy_perform(_curl);
    curl_easy_cleanup(_curl);
    if (res != 0)
    {
        CCLOG("error when download package");
        fclose(fp);
        return false;
    }
    
    CCLOG("succeed downloading package %s", _packageUrl.c_str());
    
    fclose(fp);
    return true;
}

const char* AssetsManager::getPackageUrl() const
{
    return _packageUrl.c_str();
}

void AssetsManager::setPackageUrl(const char *packageUrl)
{
    _packageUrl = packageUrl;
}

const char* AssetsManager::getStoragePath() const
{
    return _storagePath.c_str();
}

void AssetsManager::setStoragePath(const char *storagePath)
{
    _storagePath = storagePath;
    checkStoragePath();
}

const char* AssetsManager::getVersionFileUrl() const
{
    return _versionFileUrl.c_str();
}

void AssetsManager::setVersionFileUrl(const char *versionFileUrl)
{
    _versionFileUrl = versionFileUrl;
}

string AssetsManager::getVersion()
{
    return CCUserDefault::sharedUserDefault()->getStringForKey(KEY_OF_VERSION);
}

void AssetsManager::deleteVersion()
{
    CCUserDefault::sharedUserDefault()->setStringForKey(KEY_OF_VERSION, "");
}

//NS_CC_EXT_END;
