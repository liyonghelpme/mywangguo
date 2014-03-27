
#include "network/CCHttpRequest.h"
#include "network/CCHttpRequest_impl.h"
#include "cocos2d.h"

#include "CCLuaEngine.h"

using namespace cocos2d;

NS_CC_EXT_BEGIN

CCHttpRequest* CCHttpRequest::createWithUrl(CCHttpRequestDelegate* delegate,
                                            const char* url,
                                            CCHttpRequestMethod method,
                                            bool isAutoReleaseOnFinish)
{
    CCHttpRequest* request = new CCHttpRequest(delegate, url, method, isAutoReleaseOnFinish);
    request->initHttpRequest();
    request->autorelease();
    if (isAutoReleaseOnFinish)
    {
        request->retain();
    }
    return request;
}

CCHttpRequest* CCHttpRequest::createWithUrlLua(int nHandler, const char* url, bool isGet)
{
    CCHttpRequest* request = new CCHttpRequest(NULL, url, isGet?CCHttpRequestMethodGET:CCHttpRequestMethodPOST, true);
    request->m_luaHandler = nHandler;
    request->initHttpRequest();
    request->autorelease();
    request->retain();
    //CCLog("request count is? %d", request->retainCount());
    return request;
}

bool CCHttpRequest::initHttpRequest(void)
{
    m_request = new CCHttpRequest_impl(m_url.c_str(), m_method);
    return true;
}

CCHttpRequest::~CCHttpRequest(void)
{
    delete (CCHttpRequest_impl*)m_request;
}

void CCHttpRequest::addRequestHeader(const char* key, const char* value)
{
    if (key && value)
    {
        ((CCHttpRequest_impl*)m_request)->addRequestHeader(key, value);
    }
}

void CCHttpRequest::addPostValue(const char* key, const char* value)
{
    if (key && value)
    {
        ((CCHttpRequest_impl*)m_request)->addPostValue(key, value);
    }
}

void CCHttpRequest::setPostData(const char* data)
{
    if (data)
    {
        ((CCHttpRequest_impl*)m_request)->setPostData(data);
    }
}

void CCHttpRequest::setTimeout(float timeout)
{
    ((CCHttpRequest_impl*)m_request)->setTimeout(timeout);
}

bool CCHttpRequest::getIsInProgress(void)
{
    return ((CCHttpRequest_impl*)m_request)->getIsInProgress();
}

void CCHttpRequest::start(bool isCached)
{
    CCDirector::sharedDirector()->getScheduler()->unscheduleUpdateForTarget(this);
    if (((CCHttpRequest_impl*)m_request)->start())
    {
        CCDirector::sharedDirector()->getScheduler()->scheduleUpdateForTarget(this, 0, false);
    }
}

void CCHttpRequest::cancel(void)
{
    CCDirector::sharedDirector()->getScheduler()->unscheduleUpdateForTarget(this);
    ((CCHttpRequest_impl*)m_request)->cancel();
}

void CCHttpRequest::clearDelegatesAndCancel(void)
{
    m_delegate = NULL;
    cancel();
}

int CCHttpRequest::getResponseStatusCode(void) {
    return ((CCHttpRequest_impl*)m_request)->getResponseStatusCode();
}

const char* CCHttpRequest::getResponseString(void)
{
    return ((CCHttpRequest_impl*)m_request)->getResposeString().c_str();
}

const void* CCHttpRequest::getResponseData(int* dataLength)
{
    return ((CCHttpRequest_impl*)m_request)->getResponseData();
}

int CCHttpRequest::getResponseDataLength()
{
    return ((CCHttpRequest_impl*)m_request)->getResponseDataLength();
}

CCHttpRequestError  CCHttpRequest::getErrorCode(void)
{
    return ((CCHttpRequest_impl*)m_request)->getErrorCode();
}

const char* CCHttpRequest::getErrorMessage(void)
{
    return ((CCHttpRequest_impl*)m_request)->getErrorMessage();
}

void CCHttpRequest::update(float dt)
{
    //CCLog("update Request state %d", retainCount());
    CCHttpRequest_impl* request = (CCHttpRequest_impl*)m_request;
    if (!request || !request->getIsInProgress())
    {
        CCDirector::sharedDirector()->getScheduler()->unscheduleUpdateForTarget(this);
    }
    
    if (request->getIsCompleted())
    {
        if (m_delegate) m_delegate->requestFinished(this);
        
        if (m_luaHandler)
        {
			bool isSuc = (request->getErrorCode()==CCHttpRequestErrorNone);
			CCLuaEngine* engine = CCLuaEngine::defaultEngine();

			engine->getLuaStack()->clean();
			engine->getLuaStack()->pushBoolean(isSuc);
			engine->getLuaStack()->executeFunctionByHandler(m_luaHandler, 1);
            //CCLog("afterHandler retainCount %d", retainCount());
			/*
            cocos2d::CCLuaValueDict dict;
            dict["name"] = cocos2d::CCLuaValue::stringValue("completed");
            dict["request"] = cocos2d::CCLuaValue::ccobjectValue(this, "CCHttpRequest");
            cocos2d::CCLuaEngine* engine = cocos2d::CCLuaEngine::defaultEngine();
            engine->cleanStack();
            engine->pushCCLuaValueDict(dict);
            engine->executeFunctionByHandler(m_luaHandler, 1);
			*/
        }
        
    }
    else if (request->getIsCancelled())
    {
        if (m_delegate) m_delegate->requestFailed(this);
        
        if (m_luaHandler)
        {
			CCLuaEngine* engine = CCLuaEngine::defaultEngine();

			engine->getLuaStack()->clean();
			engine->getLuaStack()->pushBoolean(false);
			engine->getLuaStack()->executeFunctionByHandler(m_luaHandler, 1);
			/*
            cocos2d::CCLuaValueDict dict;
            dict["name"] = cocos2d::CCLuaValue::stringValue("failed");
            dict["request"] = cocos2d::CCLuaValue::ccobjectValue(this, "CCHttpRequest");
            cocos2d::CCLuaEngine* engine = cocos2d::CCLuaEngine::defaultEngine();
            engine->cleanStack();
            engine->pushCCLuaValueDict(dict);
            engine->executeFunctionByHandler(m_luaHandler, 1);
			*/
        }
    }
}

NS_CC_EXT_END
