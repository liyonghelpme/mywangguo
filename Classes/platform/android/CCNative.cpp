#include "platform/CCNative.h"
#include "platform/android/jni/JniHelper.h"

#include "CCLuaEngine.h"
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
	CCLog(content);
}

void CCNative::clearLocalNotification()
{
	//"do not support");
}

NS_CC_EXT_END
