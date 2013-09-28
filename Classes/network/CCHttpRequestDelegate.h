
#ifndef __CC_EXTENSION_CCHTTP_REQUEST_DELEGATE_H_
#define __CC_EXTENSION_CCHTTP_REQUEST_DELEGATE_H_

#include "cocos2d_ext_const.h"
NS_CC_EXT_BEGIN

class CCHttpRequest;

class CCHttpRequestDelegate
{
public:
    virtual void requestFinished(CCHttpRequest* request) = 0;
    virtual void requestFailed(CCHttpRequest* request) {
    }
};

NS_CC_EXT_END

#endif // __CC_EXTENSION_CCHTTP_REQUEST_DELEGATE_H_
