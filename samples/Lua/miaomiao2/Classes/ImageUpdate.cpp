#include "ImageUpdate.h"
#include "iniReader.h"
#include <string.h>

ImageUpdate::ImageUpdate(const char *serverUrl, const char *versionUrl, const char *localUrl)
:_serverUrl(serverUrl)
,_versionUrl(versionUrl)
,_localUrl(localUrl)
{
    _storagePath = CCFileUtils::sharedFileUtils()->getWritablePath();
    //在获取本地的图片版本信息 
    //新路径放在最后 会优先获取旧的文件 需要想方法优先获取新文件
    //增加包中的images 路径
    //CCFileUtils::sharedFileUtils()->addSearchPath();
    
    //设定图片路径 优先使用缓存中图片
    //再使用images 文件夹中的图片
    
    //AppDelegate 里面处理 路径问题
    //CCFileUtils::sharedFileUtils()->addSearchPath(_storagePath.c_str());
    //CCFileUtils::sharedFileUtils()->addSearchPath("images");

    
    //vector<string> sp = CCFileUtils::sharedFileUtils()->getSearchPaths();
    //sp.insert(sp.begin(), _storagePath);
    //sp.insert(sp.begin(), "images");
}

static size_t getVersionCode(void *ptr, size_t size, size_t nmemb, void *userdata) {
	//如果文件过大 可能多次获取 version code 数据 等待获取结束
    CCLog("getVersionCode");
    ImageUpdate *pImage = (ImageUpdate *)userdata;
	int len = size*nmemb;
	char *word = (char*)ptr;
	pImage->tempData.append(word, len);

	/*
    map<string, string> *version = &pImage->_sversion;
    map<string, string> *temp = handleIni((char*)ptr, size*nmemb);
    (*version) = *(temp);
    delete temp;
    
    string fullPath = pImage->_storagePath+pImage->_versionUrl;
    FILE *nf = fopen(fullPath.c_str(), "wb");
    fwrite(ptr, size, nmemb, nf);
    fclose(nf);
	*/
    return (size*nmemb);
}
//下载每个图片文件的内容写入到文件里面
static size_t downLoadPackage(void *ptr, size_t size, size_t nmemb, void *userdata) {
    FILE *fp = (FILE *)userdata;
    size_t written = fwrite(ptr, size, nmemb, fp);
	return written;
}
bool ImageUpdate::download() {
    CURLcode res;
    for(vector<string>::iterator it=needUpdate.begin(); it != needUpdate.end(); it++) {
        string outFileName = _storagePath+(*it);
        FILE *fp = fopen(outFileName.c_str(), "wb");

        curl_easy_setopt(_curl, CURLOPT_URL, (_serverUrl+(*it)).c_str());
        curl_easy_setopt(_curl, CURLOPT_WRITEFUNCTION, downLoadPackage);
        curl_easy_setopt(_curl, CURLOPT_WRITEDATA, fp);

        res = curl_easy_perform(_curl);
        if(res != 0) {
            CCLog("download image file fail %s", (*it).c_str());
        }
        //curl_easy_setopt(_curl, CURLOPT_NOPROGRESS, false);
        //curl_easy_setopt(_curl, CURLOPT_PROGRESSFUNCTION, progressFunc);
        fclose(fp);
    }
	return true;
}
bool ImageUpdate::update() {
    download();

    unsigned long fsize;

    //将下载的ser.ini 文件内容写入到 all.ini 中
    unsigned char *data = CCFileUtils::sharedFileUtils()->getFileData(_versionUrl.c_str(), "r", &fsize);
    string fullPath = _storagePath+_localUrl;
    FILE *out = fopen(fullPath.c_str(), "wb");
    fwrite(data, fsize, 1, out);
    fclose(out);
    delete [] data;

    return true;
}
bool ImageUpdate::checkUpdate() {
    //首先打开本地的 all.ini 文件 
    CCLog("image store path %s", _storagePath.c_str());
    CCLog("checkUpdate compare local %s %s", _localUrl.c_str(), _versionUrl.c_str());
    //vector<string> arr = (CCFileUtils::sharedFileUtils()->getSearchPaths());
    //arr.insert(arr.begin(), _storagePath);
    unsigned long fsize;
    //先查看缓存中版本文件
    //再查看包中版本文件
	unsigned char *data = CCFileUtils::sharedFileUtils()->getFileData((_storagePath+_localUrl).c_str(), "r", &fsize);
    if(data == NULL) {
	    data = CCFileUtils::sharedFileUtils()->getFileData(_localUrl.c_str(), "r", &fsize);
    }
    string ts((char*)data, (size_t)fsize);
    CCLog("all.ini content %s %x %d", ts.c_str(), data, fsize);
    map<string, string> *temp = handleIni((char*)data, fsize);
    CCLog("old pictures %d", temp->size());
    delete [] data;
    for(map<string, string>::iterator it=temp->begin(); it != temp->end(); it++) {
		CCLog("old files %s %s", it->first.c_str(), it->second.c_str());
    }

    //接着从服务器下载新的ser.ini 文件
    _curl = curl_easy_init();
    CURLcode res;
    curl_easy_setopt(_curl, CURLOPT_URL, (_serverUrl+_versionUrl).c_str());
    curl_easy_setopt(_curl, CURLOPT_SSL_VERIFYPEER, 0L);
    curl_easy_setopt(_curl, CURLOPT_WRITEFUNCTION, getVersionCode);
    curl_easy_setopt(_curl, CURLOPT_WRITEDATA, this);
    res = curl_easy_perform(_curl);


    if(res != 0) {
        CCLog("image not get version file content");
        return false;
    }
	//读取version file 结束 写入数据到 version中
	map<string, string> *version = &_sversion;
	map<string, string> *temp2 = handleIni(tempData.c_str(), tempData.size());
    (*version) = *(temp2);
    delete temp2;
    
	//将下载的版本信息 写入到 ser.ini 文件里面  等图片下载完成再更新版本信息
    string fullPath = _storagePath+_versionUrl;
    FILE *nf = fopen(fullPath.c_str(), "wb");
    fwrite(tempData.c_str(), tempData.size(), 1, nf);
    fclose(nf);
	tempData.clear();

    //对比所有本地图片文件 和 远程图片文件 比较 需要更新的图片文件
    for(map<string, string>::iterator it=_sversion.begin(); it != _sversion.end(); it++) {
        CCLog("compare file %s %s", it->first.c_str(), it->second.c_str());
        if((*temp)[it->first] != it->second) {
            CCLog("different old new %s %s %s", it->first.c_str(), (*temp)[it->first].c_str(), it->second.c_str() );
            needUpdate.push_back(it->first);
        }
    }
    delete temp;

    //download(); 

    //verfileData = (char*)data;
    //verfileSize = fsize;

    CCLog("need Update Image %d", needUpdate.size());
    for(vector<string>::iterator it=needUpdate.begin(); it != needUpdate.end(); it++) {
		CCLog("update %s ", (*it).c_str());
    }

    if(needUpdate.size() > 0)
        return true;
    
    //不需要更新
    //delete [] data;
    //verfileData = NULL;
    return false;
}
