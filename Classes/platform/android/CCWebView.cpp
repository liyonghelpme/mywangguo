#include "platform/CCWebView.h"
#include "platform/android/jni/JniHelper.h"

#include <stdio.h>

#include "CCLuaEngine.h"

NS_CC_EXT_BEGIN

CCWebView* single = NULL;

CCWebView::CCWebView(){
    CCLog("init webview");
}

CCWebView::~CCWebView(){
    
    CCLog("destroy webview");
}

void CCWebView::webViewDidFinishLoad(){
    CCLog("finsih view");
}

// only do normal set here
bool CCWebView::init(const char* url, int luaHandler){
    char debugLog[100];
    sprintf(debugLog, "initLuaHandler:%d", luaHandler);
    //CCLog(debugLog);
	this->m_luaHandler = luaHandler;
	//CCWebView_iosImpl* impl = [[CCWebView_iosImpl alloc] init];
	//[impl addWebView:this withUrl:url];
	//this->retain();
	JniMethodInfo minfo;

    CCLog("init android view");
    if(JniHelper::getStaticMethodInfo(minfo, "com/caesars/android/Cocos2dxEntry", "openWebview", "(Ljava/lang/String;)V"))
    {
        jstring StringArg1 = minfo.env->NewStringUTF(url);
        minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, StringArg1);
        minfo.env->DeleteLocalRef(StringArg1);
        minfo.env->DeleteLocalRef(minfo.classID);
    }
    return true;
}

CCWebView* CCWebView::create(const char *url, int luaHandler){
    if(single!=NULL){
        single->init(url, luaHandler);
        return single;
    }
    CCWebView* pView = new CCWebView();
    if (pView->init(url, luaHandler)){
        pView->autorelease();
        single = pView;
        single->retain();
        CCLog("init single");
        return pView;
    }
    CC_SAFE_DELETE(pView);
    return NULL;
}

bool CCWebView::shouldLoadUrl(const char *url){
    if(this->m_luaHandler != 0){
        
        char debugLog[100];
        sprintf(debugLog, "callbackLuaHandler:%d", this->m_luaHandler);
        //CCLog(debugLog);
        
        //CCLog(url);
        CCLuaEngine *engine = CCLuaEngine::defaultEngine();
        CCLuaStack *stack = engine->getLuaStack();
        stack->clean();
        stack->pushString(url);

        int ret = stack->executeFunctionByHandler(this->m_luaHandler, 1);
        CCLog("check url finish");
        return ret==1;
    }
    return true;
}

NS_CC_EXT_END

jboolean Java_com_caesars_android_Cocos2dxEntry_shouldLoadUrl(JNIEnv *env, jobject thiz, jstring url){
    char debugLog[1000];
    bool ret;
    const char* s=env->GetStringUTFChars(url, NULL);
    CCLog("android load url");
    sprintf(debugLog, "checkUrl:%s", s);
    //CCLog(debugLog);
    ret = cocos2d::extension::single->shouldLoadUrl(s);
    CCLog("checkUrlFinish");
    //if(!ret){
        //cocos2d::extension::single->release();
        //cocos2d::extension::single = NULL;
    //}
    sprintf(debugLog, "checkUrlResult:%d", ret?1:0);
    //CCLog(debugLog);
    return (jboolean)(ret?1:0);
}
