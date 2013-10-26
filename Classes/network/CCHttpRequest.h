
#ifndef __CC_EXTENSION_CCHTTP_REQUEST_H_
#define __CC_EXTENSION_CCHTTP_REQUEST_H_

#include "cocos2d.h"
#include "network/CCHttpRequestDelegate.h"
#include "cocos2d_ext_const.h"

NS_CC_EXT_BEGIN

typedef enum {
    CCHttpRequestMethodGET = 0,
    CCHttpRequestMethodPOST,
} CCHttpRequestMethod;

typedef enum {
    CCHttpRequestErrorNone = 0,
    CCHttpRequestErrorConnectionFailure = 1,
    CCHttpRequestErrorTimeout,
    CCHttpRequestErrorAuthentication,
    CCHttpRequestErrorCancelled,
    CCHttpRequestErrorUnknown
} CCHttpRequestError;

class CCHttpRequest : public CCObject
{
public:
    static CCHttpRequest* createWithUrl(CCHttpRequestDelegate* delegate,
                                        const char* url,
                                        CCHttpRequestMethod method = CCHttpRequestMethodGET,
                                        bool isAutoReleaseOnFinish = true);

    static CCHttpRequest* createWithUrlLua(int nHandler, const char* url, bool isGet=true);
    
    ~CCHttpRequest(void);
    
    /** @brief Add a custom header to the request. */
    void addRequestHeader(const char* key, const char* value);

    /** @brief Add a POST variable to the request, POST only. */
    void addPostValue(const char* key, const char* value);
    
    /** @brief Set POST data to the request body, POST only. */
    void setPostData(const char* data);

    /** @brief Number of seconds to wait before timing out - default is 10. */
    void setTimeout(float timeout);
    
    /** @brief True when the request hasn't finished yet. */
    bool getIsInProgress(void);

    /** @brief Return CCHttpRequestDelegate delegate. */
    CCHttpRequestDelegate* getDelegate(void) {
        return m_delegate;
    }

    /** @brief Execute an asynchronous request
     
     If isCached set to false, it will force request not to be cached.        
     Setting isCache to false also appends a query string parameter, "_=[TIMESTAMP]", to the URL.
     */
    void start(bool isCached = false);
    
    /** @brief Cancel an asynchronous request. */
    void cancel(void);
    
    /** @brief Cancel an asynchronous request, clearing all delegates first. */
    void clearDelegatesAndCancel(void);
    
    /** @brief Return HTTP status code. */
    int getResponseStatusCode(void);
    
    /** @brief Returns the contents of the result. */
    const char* getResponseString(void);
    
    /** @brief Get response data. */
    const void* getResponseData(int* dataLength);

    /** @brief Get response data length (bytes). */
    int getResponseDataLength(void);
    
    /** @brief Get error code. */
    CCHttpRequestError getErrorCode(void);
    
    /** @brief Get error message. */
    const char* getErrorMessage(void);

    /** @brief timer function. */
    virtual void update(float dt);

private:
    CCHttpRequest(CCHttpRequestDelegate* delegate,
                  const char* url,
                  CCHttpRequestMethod method,
                  bool isAutoReleaseOnFinish)
    : m_delegate(delegate)
    , m_url(url ? url : "")
    , m_method(method)
    , m_request(NULL)
    , m_isAutoReleaseOnFinish(isAutoReleaseOnFinish)
    , m_errorCode(CCHttpRequestErrorNone)
    , m_luaHandler(0)
    {
    }
    bool initHttpRequest(void);

    CCHttpRequestDelegate*  m_delegate;
    const std::string       m_url;
    CCHttpRequestMethod     m_method;
    void*                   m_request;
    bool                    m_isAutoReleaseOnFinish;
    CCHttpRequestError      m_errorCode;
    std::string             m_errorMessage;
    int						m_luaHandler;
};

NS_CC_EXT_END

#endif // __CC_EXTENSION_CCHTTP_REQUEST_H_
