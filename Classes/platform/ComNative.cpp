#include "CCNative.h"
#include "cocos2d.h"
#include <stdlib.h>
using namespace cocos2d;
using namespace std;
float getNow()
{
    struct timeval val;
    //struct timezone zone;
    gettimeofday(&val, NULL);
	return val.tv_sec+val.tv_usec/1000000.0;
}

void writeFile(const char *fname, const char *content, int size) {
    FILE *nf = fopen(fname, "wb");
    fwrite(content, 1, size, nf);
    fclose(nf);
}
string getFileData(const char *fname) {
    unsigned long size;
    unsigned char *con = CCFileUtils::sharedFileUtils()->getFileData(fname, "r", &size);
    string str((char*)con, size);
    //删除返回的文件数据
    delete [] con;
    return str;
}
