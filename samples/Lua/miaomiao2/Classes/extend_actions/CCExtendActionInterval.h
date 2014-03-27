
#ifndef __ACTION_CCEXTEND_INTERVAL_ACTION_H__
#define __ACTION_CCEXTEND_INTERVAL_ACTION_H__

#include "cocos2d_ext_const.h"
#include "base_nodes/CCNode.h"
#include "actions/CCActionInterval.h"
#include "actions/CCActionEase.h"
#include "CCProtocols.h"
#include "sprite_nodes/CCSpriteFrame.h"
#include "sprite_nodes/CCAnimation.h"
#include <vector>

NS_CC_EXT_BEGIN

class CCAlphaTo : public CCActionInterval
{
public:
	bool initWithDuration(float duration, GLubyte from, GLubyte to);
	
	virtual void update(float time);
    virtual CCActionInterval* reverse(void);
    virtual CCObject* copyWithZone(CCZone* pZone);
    
public:
    /** creates the action */
    static CCAlphaTo* create(float d, GLubyte from, GLubyte to);
    
private:
	GLubyte m_uFromAlpha;
	GLubyte m_uToAlpha;
	
	void recurAlpha(CCNode* node, GLubyte alpha);
};


class CCNumberTo : public CCActionInterval
{
public:
	bool initWithDuration(float duration, int from, int to, const char* prefix, const char* suffix);
	
	virtual void update(float time);
    virtual CCActionInterval* reverse(void);
    virtual CCObject* copyWithZone(CCZone* pZone);
    
public:
    /** creates the action */
    static CCNumberTo* create(float d, int from, int to, const char* prefix, const char* suffix);
    
private:
	int m_uFromNumber;
	int m_uToNumber;
	const char* m_sPrefix;
	const char* m_sSuffix;
};

class CCShake : public CCActionInterval
{
public:
	bool initWithDuration(float duration, float amplitude);
	
	virtual void update(float time);
    virtual void stop(void);
    virtual CCObject* copyWithZone(CCZone* pZone);
    
public:
    /** creates the action */
    static CCShake* create(float d, float amplitude);
    
private:
	CCPoint m_startPosition;
	float m_fAmplitude;
};

NS_CC_EXT_END
#endif //__ACTION_CCEXTEND_INTERVAL_ACTION_H__