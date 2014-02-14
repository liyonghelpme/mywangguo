#ifndef __IMAGEUPDATE_H__
#define __IMAGEUPDATE_H__
#include <curl/curl.h>
#include "support/zip_support/unzip.h"
#include "cocos2d.h"
#include <map>
#include <string>
#include <vector>

using namespace cocos2d;
using namespace std;
class ImageUpdate {
public:
    //服务器地址 下载图片
    //每个图片的版本文件
    //本地每个图片的版本文件
    ImageUpdate(const char *serverUrl, const char *versionUrl, const char *localUrl);
    bool checkUpdate();
    bool update();
    bool download();

public:
    string _serverUrl;
    string _versionUrl;
    string _localUrl;
    string _storagePath;

    map<string, string> _lversion;
    map<string, string> _sversion;
    vector<string> needUpdate;

    CURL *_curl;

	string tempData;

};

#endif

