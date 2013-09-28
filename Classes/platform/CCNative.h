#ifndef __CC_EXTENSION_CCNATIVE_H_
#define __CC_EXTENSION_CCNATIVE_H_

#include "ExtensionMacros.h"
#include "cocoa/CCDictionary.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "platform/android/jni/JniHelper.h"
extern "C"
{
	void Java_com_caesars_lib_CaesarsActivity_setDeviceId(JNIEnv *env, jobject thiz, jstring url);
}
#endif

NS_CC_EXT_BEGIN

class CCNative
{
public:
    /** @brief Open a web page in the browser; create an email; or call a phone number. */
    static void openURL(const char* url);

	static void postNotification(int duration, const char* content);

	static void clearLocalNotification();

	static void buyProductIdentifier(const char* productId);

	static void initStore(CCDictionary* dict);

	static void showAchievements();

	static void reportAchievement(const char *identifer, float percent);
    
    //simple alert dialog; button integer: 0 is NULL, 1 is back, 2 is close game
    static void showAlert(const char* title, const char* content, int button1, const char* button1Text, int button2, const char* button2Text);

private:
    CCNative(void) {}
};

NS_CC_EXT_END

#endif // __CC_EXTENSION_CCNATIVE_H_
