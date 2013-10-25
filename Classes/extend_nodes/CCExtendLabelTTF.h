#ifndef	__CAESARS_NODE_CCEXTENDLABELTTF_H__
#define __CAESARS_NODE_CCEXTENDLABELTTF_H__

#include "cocos2d_ext_const.h"
#include "label_nodes/CCLabelTTF.h"

NS_CC_EXT_BEGIN
class CCExtendLabelTTF : public CCLabelTTF
{
private:
	float m_fStroke;
public:
    CCExtendLabelTTF(void);

    static CCExtendLabelTTF * create(const char *string, const char *fontName, float fontSize,
                               const CCSize& dimensions, CCTextAlignment hAlignment, 
                               CCVerticalTextAlignment vAlignment, float stokeWidth);

	void setStroke(float stokeWidth);

	virtual void setString(const char *label);
private:
    bool updateTexture();
};

NS_CC_EXT_END

#endif //__CAESARS_NODE_CCEXTENDLABELTTF_H__
