#include "platform/CCWebView.h"

#include "CCLuaEngine.h"
NS_CC_EXT_BEGIN
CCWebView::CCWebView(){
}

CCWebView::~CCWebView(){
}

void CCWebView::webViewDidFinishLoad(){
    CCLOG("The webview load over");
}

// only do normal set here
bool CCWebView::init(const char* url, int luaHandler){
	this->m_luaHandler = luaHandler;
	//CCWebView_iosImpl* impl = [[CCWebView_iosImpl alloc] init];
	//[impl addWebView:this withUrl:url];
	return this->shouldLoadUrl(url);
}

CCWebView* CCWebView::create(const char *url, int luaHandler){
    CCWebView* pView = new CCWebView();
    if (pView->init(url, luaHandler)){
        //pView->autorelease();
        return pView;
    }
    CC_SAFE_DELETE(pView);
    return NULL;
}

bool CCWebView::shouldLoadUrl(const char *url){
    if(this->m_luaHandler != 0){
        CCLog("load url");
        CCLuaEngine *engine = CCLuaEngine::defaultEngine();
        engine->getLuaStack()->clean();
        engine->getLuaStack()->pushString(url);

        int ret = engine->getLuaStack()->executeFunctionByHandler(this->m_luaHandler, 1);
        CCLog("check url finish");
        return ret==1;
    }
    return true;
}

NS_CC_EXT_END