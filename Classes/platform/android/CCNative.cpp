#include "platform/CCNative.h"
#include "platform/android/jni/JniHelper.h"
#include "support/user_default/CCUserDefault.h"
#include "CCLuaEngine.h"
#include "support/CCNotificationCenter.h"
using namespace cocos2d;
void Java_com_liyong_wangguo_HelloLua_setDeviceId(JNIEnv *env, jobject thiz, jstring url){
    const char* s=env->GetStringUTFChars(url, NULL);
    cocos2d::CCUserDefault::sharedUserDefault()->setStringForKey("username", s);
}
void Java_com_liyong_wangguo_HelloLua_setPoints(JNIEnv *env, jobject thiz, jint v) {
    CCLog("setPoints %d", (int)v);
    cocos2d::CCUserDefault::sharedUserDefault()->setIntegerForKey("gold", v);
    cocos2d::CCNotificationCenter::sharedNotificationCenter()->postNotification("EVENT_SETPOINT");
}

NS_CC_EXT_BEGIN

void CCNative::openURL(const char* pszUrl)
{
    JniMethodInfo minfo;

    if(JniHelper::getStaticMethodInfo(minfo, "com/caesars/android/Cocos2dxEntry", "openURL", "(Ljava/lang/String;)V"))
    {
        jstring StringArg1 = minfo.env->NewStringUTF(pszUrl);
        minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, StringArg1);
        minfo.env->DeleteLocalRef(StringArg1);
        minfo.env->DeleteLocalRef(minfo.classID);
    }
}

void CCNative::postNotification(int duration, const char* content)
{
	//CCLog(content);
}

void CCNative::clearLocalNotification()
{
}
NS_CC_EXT_END
