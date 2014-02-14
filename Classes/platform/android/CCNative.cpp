#include "platform/CCNative.h"
#include "platform/android/jni/JniHelper.h"

#include "CCLuaEngine.h"
NS_CC_EXT_BEGIN

void CCNative::openURL(const char* pszUrl)
{
    JniMethodInfo minfo;
    CCLog("openURL %s", pszUrl);
    if(JniHelper::getStaticMethodInfo(minfo, "org/cocos2dx/hellolua", "openURL", "(Ljava/lang/String;)V"))
    {
        CCLog("find method");
        jstring StringArg1 = minfo.env->NewStringUTF(pszUrl);
        minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, StringArg1);
        minfo.env->DeleteLocalRef(StringArg1);
        minfo.env->DeleteLocalRef(minfo.classID);
    }
}

void CCNative::postNotification(int duration, const char* content)
{
	CCLog(content);
}

void CCNative::clearLocalNotification()
{
	//"do not support");
}

NS_CC_EXT_END
