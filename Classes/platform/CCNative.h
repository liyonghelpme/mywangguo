
#ifndef __CC_EXTENSION_CCNATIVE_H_
#define __CC_EXTENSION_CCNATIVE_H_

#include "cocos2d_ext_const.h"

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

#endif // __CC_EXTENSION_CCNATIVE_H_
