
#include "CCExtendActionInterval.h"
#include "sprite_nodes/CCSprite.h"
#include "base_nodes/CCNode.h"
#include "cocoa/CCZone.h"

NS_CC_EXT_BEGIN

//
// AlphaTo
//

CCAlphaTo* CCAlphaTo::create(float d, GLubyte from, GLubyte to)
{
	CCAlphaTo* pAction = new CCAlphaTo();
	
	pAction->initWithDuration(d, from ,to);
	pAction->autorelease();
	
	return pAction;
}

bool CCAlphaTo::initWithDuration(float d, GLubyte from, GLubyte to)
{
    if (CCActionInterval::initWithDuration(d))
    {
        m_uFromAlpha = from;
        m_uToAlpha = to;
        return true;
    }

    return false;
}

CCObject* CCAlphaTo::copyWithZone(CCZone *pZone)
{
    CCZone* pNewZone = NULL;
    CCAlphaTo* pCopy = NULL;
    if(pZone && pZone->m_pCopyObject) 
    {
        //in case of being called at sub class
        pCopy = (CCAlphaTo*)(pZone->m_pCopyObject);
    }
    else
    {
        pCopy = new CCAlphaTo();
        pZone = pNewZone = new CCZone(pCopy);
    }

    CCActionInterval::copyWithZone(pZone);

    pCopy->initWithDuration(m_fDuration, m_uFromAlpha, m_uToAlpha);

    CC_SAFE_DELETE(pNewZone);
    return pCopy;
}

void CCAlphaTo::recurAlpha(CCNode* node, GLubyte alpha)
{
    CCRGBAProtocol *pRGBAProtocol = dynamic_cast<CCRGBAProtocol*>(node);
    if (pRGBAProtocol)
    {
        pRGBAProtocol->setOpacity(alpha);
    }
	CCArray* childs = node->getChildren();
	if (childs){
		for(unsigned int i=0; i<childs->count(); i++){
			CCNode *child =  (CCNode *)(childs->objectAtIndex(i));
			if (child)
			{
				this->recurAlpha(child, alpha);
			}
		}
	}
}

void CCAlphaTo::update(float time)
{
    this->recurAlpha(m_pTarget, GLubyte(m_uFromAlpha + time * (m_uToAlpha - m_uFromAlpha)));
}

CCActionInterval* CCAlphaTo::reverse(void)
{
    return CCAlphaTo::create(m_fDuration, m_uToAlpha, m_uFromAlpha);
}

//
// NumberTo
//

CCNumberTo* CCNumberTo::create(float duration, int from, int to, const char* prefix, const char* suffix)
{
	CCNumberTo* pAction = new CCNumberTo();
	
	pAction->initWithDuration(duration, from ,to, prefix, suffix);
	pAction->autorelease();
	
	return pAction;
}

bool CCNumberTo::initWithDuration(float duration, int from, int to, const char* prefix, const char* suffix)
{
    if (CCActionInterval::initWithDuration(duration))
    {
        m_uFromNumber = from;
        m_uToNumber = to;
		m_sPrefix = prefix;
		m_sSuffix = suffix;
        return true;
    }

    return false;
}

CCObject* CCNumberTo::copyWithZone(CCZone *pZone)
{
    CCZone* pNewZone = NULL;
    CCNumberTo* pCopy = NULL;
    if(pZone && pZone->m_pCopyObject) 
    {
        //in case of being called at sub class
        pCopy = (CCNumberTo*)(pZone->m_pCopyObject);
    }
    else
    {
        pCopy = new CCNumberTo();
        pZone = pNewZone = new CCZone(pCopy);
    }

    CCActionInterval::copyWithZone(pZone);

    pCopy->initWithDuration(m_fDuration, m_uFromNumber, m_uToNumber, m_sPrefix, m_sSuffix);

    CC_SAFE_DELETE(pNewZone);
    return pCopy;
}

void CCNumberTo::update(float time)
{
    CCLabelProtocol *labelProtocol = dynamic_cast<CCLabelProtocol*>(m_pTarget);
	if(labelProtocol)
	{
		char* label = new char[50];
		sprintf(label, "%s%d%s", m_sPrefix, m_uFromNumber + (int)((m_uToNumber-m_uFromNumber)*time), m_sSuffix);
		labelProtocol->setString(label);
		delete label;
	}
}

CCActionInterval* CCNumberTo::reverse(void)
{
    return CCNumberTo::create(m_fDuration, m_uToNumber, m_uFromNumber, m_sPrefix, m_sSuffix);
}


CCShake* CCShake::create(float duration, float amplitude)
{
	CCShake* pAction = new CCShake();
	
	pAction->initWithDuration(duration, amplitude);
	pAction->autorelease();
	
	return pAction;
}

bool CCShake::initWithDuration(float duration, float amplitude)
{
    if (CCActionInterval::initWithDuration(duration))
    {
        m_fAmplitude = amplitude;
		m_startPosition = CCPointMake(0,0);
        return true;
    }

    return false;
}

CCObject* CCShake::copyWithZone(CCZone *pZone)
{
    CCZone* pNewZone = NULL;
    CCShake* pCopy = NULL;
    if(pZone && pZone->m_pCopyObject) 
    {
        //in case of being called at sub class
        pCopy = (CCShake*)(pZone->m_pCopyObject);
    }
    else
    {
        pCopy = new CCShake();
        pZone = pNewZone = new CCZone(pCopy);
    }

    CCActionInterval::copyWithZone(pZone);

    pCopy->initWithDuration(m_fDuration, m_fAmplitude);

    CC_SAFE_DELETE(pNewZone);
    return pCopy;
}

void CCShake::update(float time)
{
	float amp = m_fAmplitude*(1-time);
    float fx=(CCRANDOM_0_1()*2-1)*amp;
	float fy=(CCRANDOM_0_1()*2-1)*amp;
	CCPoint pt = m_pTarget->getPosition();
	m_pTarget->setPositionX(pt.x-m_startPosition.x + fx);
	m_pTarget->setPositionY(pt.y-m_startPosition.y + fy);
	m_startPosition = CCPointMake(fx, fy);
}

void CCShake::stop()
{
	CCPoint pt = m_pTarget->getPosition();
	m_pTarget->setPosition(CCPointMake(pt.x-m_startPosition.x, pt.y-m_startPosition.y));
}

NS_CC_EXT_END