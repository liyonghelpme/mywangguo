#include "CCNative.h"
#include "cocos2d.h"
#include <stdlib.h>
using namespace cocos2d;
using namespace std;

void setScriptTouchPriority(CCLayer *lay, int pri){
    //CCLog("setScriptTouchPriority %d", pri);
    CCTouchScriptHandlerEntry *st = lay->getScriptTouchHandlerEntry();
    st->setPriority(pri);
    //CCLog("priority %d %d", st->getPriority(), st->getSwallowsTouches());
    /*
    lay->retain();
    CCNode *par = lay->getParent();
    lay->removeFromParent();
    par->addChild(lay);
    lay->release();
    */
    lay->setTouchPriority(pri);
}

string getFileData(const char *fname) {
    unsigned long size;
    unsigned char *con = CCFileUtils::sharedFileUtils()->getFileData(fname, "r", &size);
    string str((char*)con, size);
    //删除返回的文件数据
    delete [] con;
    return str;
}
void pauseAction(CCNode *n) {
    
}

void setTextureRect(CCSprite *sp, CCRect rect, bool rotated, CCSize size) {
    sp->setTextureRect(rect, rotated, size);
}
void enableShadow(CCLabelTTF *lab, CCSize sz, float so, float sb, bool up, int r, int g, int b) {
    //CCLog("enableShadow %d %d %d", r, g, b);
    lab->enableShadow(sz, so, sb, up);//, r, g, b
}
void setFontFillColor(CCLabelTTF *lab, ccColor3B c, bool u) {
    lab->setFontFillColor(c, u);
}

int setGLProgram(CCNode *sp, const char *name, const char *vert, const char *frag) {
    //CCLog("setGLProgram %s %s %s", name, vert, frag);
    CCShaderCache *sc = CCShaderCache::sharedShaderCache();
    CCGLProgram *prog = (CCGLProgram*)sc->programForKey(name);
    if(prog == NULL) {
        GLchar *fragSource = (GLchar*)CCString::createWithContentsOfFile(CCFileUtils::sharedFileUtils()->fullPathForFilename(frag).c_str())->getCString();
        GLchar *vertSource = (GLchar*)CCString::createWithContentsOfFile(CCFileUtils::sharedFileUtils()->fullPathForFilename(vert).c_str())->getCString();
        //CCLog("Frag File");
        ////CCLog("%s", fragSource);
        //CCLog("Vert File");
        ////CCLog("%s", vertSource);

        prog = new CCGLProgram();
        prog->initWithVertexShaderByteArray(vertSource, fragSource);
        sp->setShaderProgram(prog);
        prog->release();

        CHECK_GL_ERROR_DEBUG();
        prog->addAttribute(kCCAttributeNamePosition, kCCVertexAttrib_Position);
        prog->addAttribute(kCCAttributeNameColor, kCCVertexAttrib_Color);
        prog->addAttribute(kCCAttributeNameTexCoord, kCCVertexAttrib_TexCoords);
        CHECK_GL_ERROR_DEBUG();

        prog->link();
        CHECK_GL_ERROR_DEBUG();
        prog->updateUniforms();
        CHECK_GL_ERROR_DEBUG();
        sc->addProgram(prog, name);
    } else {
        sp->setShaderProgram(prog);
    }
    //return (int)glGetUniformLocation(prog->getProgram(), "offset");
    return 0;
}

//只支持加载 png 图片 不带 透明通道的 加载到 RGB565 格式的 数据中
void initTextureData(char *name) {
    CCImage *pImage = NULL;
    std::string pathKey = name;
    pathKey = CCFileUtils::sharedFileUtils()->fullPathForFilename(pathKey.c_str());
    CCTextureCache *tc = CCTextureCache::sharedTextureCache();
    CCTexture2D *texture = CCTextureCache::sharedTextureCache()->textureForKey(pathKey.c_str());
    std::string fullPath = pathKey;
    //纹理不存在
    if(texture == NULL) {
        //初始图片
        CCImage::EImageFormat eImageFormat = CCImage::kFmtPng;
        pImage = new CCImage();
        bool bRet = pImage->initWithImageFile(fullPath.c_str(), eImageFormat);
        
        //初始化纹理
        texture = new CCTexture2D();
        unsigned char *tempData = pImage->getData();
        unsigned char *inPixel8 = NULL;
        unsigned short *outPixel16 = NULL;
		unsigned int *inPixel32 = NULL;

        unsigned int width = pImage->getWidth();
        unsigned int height = pImage->getHeight();

        bool hasAlpha = pImage->hasAlpha();
        CCLog("hasAlpha %d", hasAlpha);
        CCSize imageSize = CCSizeMake((float)(pImage->getWidth()), (float)(pImage->getHeight()));
        
        CCTexture2DPixelFormat pixelFormat;
        pixelFormat = kCCTexture2DPixelFormat_RGB565;
        unsigned int length = width*height;
        
		//CCLog("image has Alpha %d", hasAlpha);

        tempData = new unsigned char[width*height*2];
        outPixel16 = (unsigned short*)tempData;
        inPixel8 = (unsigned char*)pImage->getData();
		inPixel32 = (unsigned int*)inPixel8;
        //无alpha
        //RRRRRRRR to RRRRR  888 565 调整png 数据到565 格式
		/*
				((((*inPixel32 >>  0) & 0xFF) >> 3) << 11) |  // R
                ((((*inPixel32 >>  8) & 0xFF) >> 2) << 5)  |  // G
                ((((*inPixel32 >> 16) & 0xFF) >> 3) << 0);    // B
			*/
		/*|  // R
                (((*inPixel8++ & 0xFF) >> 2) << 5)  |  // G
                (((*inPixel8++ & 0xFF) >> 3) << 0);    // B
		`*/
			/*
                (((*inPixel8++ & 0xFF) >> 3) << 11) |
                (((*inPixel8++ & 0xFF) >> 2) << 5) |
                (((*inPixel8++ & 0xFF) >> 3) << 0);
			*/
		CCLog("length is %d", length);
        //rgb 888  rgb565
        for(unsigned int i=0; i < length; i++) {
			unsigned int r = *inPixel8++;
			unsigned int g = *inPixel8++;
			unsigned int b = *inPixel8++;
            if(hasAlpha == 1){
                inPixel8++;
            }
            
			*outPixel16++ = ((r>>3) << 11) | ((g>>2) << 5) | (b>>3);
			/*
			if(i < 100) {
				CCLog("%x %x %x %x", r, g, b, *(outPixel16-1));
			}
            */
			//inPixel8++;
			//inPixel8++;
			
			
        }
		
        //使用数据初始化 纹理
        texture->initWithData(tempData, pixelFormat, width, height, imageSize);
		if(tempData != pImage->getData()) {
			delete [] tempData;
		}
        //设定纹理Cache
        tc->m_pTextures->setObject(texture, pathKey.c_str());
        texture->release();
        
        //释放图片
        CC_SAFE_RELEASE(pImage);
    }
}

/*
#include <time.h>
#include <windows.h>

#if defined(_MSC_VER) || defined(_MSC_EXTENSIONS)
  #define DELTA_EPOCH_IN_MICROSECS  11644473600000000Ui64
#else
  #define DELTA_EPOCH_IN_MICROSECS  11644473600000000ULL
#endif

struct mytimezone 
{
  int  tz_minuteswest;
  int  tz_dsttime;    
};
struct mytimeval {
    long tv_sec;
    long tv_usec;
};

int gettimeofday(struct mytimeval *tv, struct mytimezone *tz)
{
  FILETIME ft;
  unsigned __int64 tmpres = 0;
  static int tzflag;
 
  if (NULL != tv)
  {
    GetSystemTimeAsFileTime(&ft);
 
    tmpres |= ft.dwHighDateTime;
    tmpres <<= 32;
    tmpres |= ft.dwLowDateTime;
 
    tmpres -= DELTA_EPOCH_IN_MICROSECS; 
    tmpres /= 10;  
    tv->tv_sec = (long)(tmpres / 1000000UL);
    tv->tv_usec = (long)(tmpres % 1000000UL);
  }
 
  if (NULL != tz)
  {
    if (!tzflag)
    {
      _tzset();
      tzflag++;
    }
    tz->tz_minuteswest = _timezone / 60;
    tz->tz_dsttime = _daylight;
  }
 
  return 0;
}
*/
 

//#include "stdafx.h"
/*
#include <time.h>
#include <windows.h> 

const __int64 DELTA_EPOCH_IN_MICROSECS= 11644473600000000;

struct timezone2 
{
  __int32  tz_minuteswest;
  bool  tz_dsttime;
};

struct timeval2 {
__int32    tv_sec;
__int32    tv_usec;
};

int gettimeofday(struct timeval2 *tv, struct timezone2 *tz)
{
  FILETIME ft;
  __int64 tmpres = 0;
  TIME_ZONE_INFORMATION tz_winapi;
  int rez=0;

   ZeroMemory(&ft,sizeof(ft));
   ZeroMemory(&tz_winapi,sizeof(tz_winapi));

    GetSystemTimeAsFileTime(&ft);

    tmpres = ft.dwHighDateTime;
    tmpres <<= 32;
    tmpres |= ft.dwLowDateTime;
    tmpres /= 10;  
    tmpres -= DELTA_EPOCH_IN_MICROSECS; 
    tv->tv_sec = (__int32)(tmpres*0.000001);
    tv->tv_usec =(tmpres%1000000);


    //_tzset(),don't work properly, so we use GetTimeZoneInformation
    rez=GetTimeZoneInformation(&tz_winapi);
    tz->tz_dsttime=(rez==2)?true:false;
    tz->tz_minuteswest = tz_winapi.Bias + ((rez==2)?tz_winapi.DaylightBias:0);

  return 0;
}
*/
/*
float getTimeOfDay() {
    float t = GetTickCount();
    //CCLog("getTimeOfDay %f", t);
    return t/1000.0f;
}
*/
/*
float getTimeOfDay() {
    struct timeval2 now;
    struct timezone2 tz;
    ZeroMemory(&now, sizeof(now));
    ZeroMemory(&tz, sizeof(tz));

    gettimeofday(&now, &tz);
    //CCTime::gettimeofdayCocos2d(&now, NULL);
    float t = now.tv_sec+now.tv_usec/1000000.0f;
    //CCLog("getTimeOfDay %f", t);
    return t; 
}
*/

struct cc_timeval startTime;
bool start = false;

double getTimeOfDay() {
    struct cc_timeval now;
    CCTime::gettimeofdayCocos2d(&now, NULL);
    double t = now.tv_sec+now.tv_usec/1000000.0;
    ////CCLog("getTimeOfDay %f", t);
    return t;
}
