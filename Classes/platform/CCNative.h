
#ifndef __CC_EXTENSION_CCNATIVE_H_
#define __CC_EXTENSION_CCNATIVE_H_

#include "cocos2d_ext_const.h"
#include "cocos2d.h"
using namespace cocos2d;

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

void setScriptTouchPriority(CCLayer *lay, int pri);
std::string getFileData(const char *fname);
//只停止动作不要停止 更新
void pauseAction(CCNode *n);
void setTextureRect(CCSprite *, CCRect, bool, CCSize);
void enableShadow(CCLabelTTF *, CCSize , float, float, bool, int r, int g, int b);
void setFontFillColor(CCLabelTTF *, ccColor3B, bool);

int setGLProgram(CCNode *, const char *, const char *, const char *);

void initTextureData(char *fileName);
#endif // __CC_EXTENSION_CCNATIVE_H_
