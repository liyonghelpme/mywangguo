
#ifndef __CC_EXTENSION_CCNATIVE_H_
#define __CC_EXTENSION_CCNATIVE_H_

#include "cocos2d_ext_const.h"
#include <string>
#include "cocos2d.h"
#include "MySprite.h"
using namespace cocos2d;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "platform/android/jni/JniHelper.h"
extern "C"
{
    void Java_com_liyong_wangguo_HelloLua_setDeviceId(JNIEnv *env, jobject thiz, jstring url);
    void Java_com_liyong_wangguo_HelloLua_setPoints(JNIEnv *env, jobject thiz, jint v);
}
#endif


NS_CC_EXT_BEGIN

class CCNative
{
public:
#pragma mark -
#pragma mark misc
    
    /** @brief Open a web page in the browser; create an email; or call a phone number. */
    static void openURL(const char* url);

	static void postNotification(int duration, const char* content);

	static void clearLocalNotification();

    
private:
    CCNative(void) {}
};

NS_CC_EXT_END

float getNow();
void writeFile(const char* fname, const char *content, int size);
std::string getFileData(const char *fname);

int setGLProgram(CCSprite *);
void setOffset(CCSprite *, float off);
CCSprite *createSprite(char *fn);

#endif // __CC_EXTENSION_CCNATIVE_H_
