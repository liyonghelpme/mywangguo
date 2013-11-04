#include "CCNative.h"
#include "cocos2d.h"
using namespace cocos2d;
float getNow()
{
    struct timeval val;
    //struct timezone zone;
    gettimeofday(&val, NULL);
	return val.tv_sec+val.tv_usec/1000000.0;
}
