#include "CCExtendLabelTTF.h"
#include "CCDirector.h"
#include "misc_nodes/CCRenderTexture.h"

NS_CC_EXT_BEGIN

CCExtendLabelTTF::CCExtendLabelTTF(void)
: m_fStroke(false)
{

}

CCExtendLabelTTF* CCExtendLabelTTF::create(const char *string, const char *fontName, float fontSize,
                               const CCSize& dimensions, CCTextAlignment hAlignment, 
                               CCVerticalTextAlignment vAlignment, float strokeWidth)
{
    CCExtendLabelTTF *pLabel = new CCExtendLabelTTF();
    if (pLabel)
    {
		pLabel->m_fStroke = strokeWidth;
		pLabel->initWithString(string, fontName, fontSize, dimensions, hAlignment, vAlignment);
        pLabel->autorelease();
        return pLabel;
    }
    CC_SAFE_DELETE(pLabel);
    return NULL;
}

void CCExtendLabelTTF::setStroke(float stroke)
{
	if(stroke!=m_fStroke)
	{
		m_fStroke = stroke;
		this->updateTexture();
	}
}

void CCExtendLabelTTF::setString(const char *string)
{
    CCAssert(string != NULL, "Invalid string");
    
    if (m_string.compare(string))
    {
        m_string = string;
        
        this->updateTexture();
    }
}

bool CCExtendLabelTTF::updateTexture()
{
	CCTexture2D *tex;
    
    // let system compute label's width or height when its value is 0
    // refer to cocos2d-x issue #1430
    tex = new CCTexture2D();
    tex->initWithString( m_string.c_str(),
                        m_pFontName->c_str(),
                        m_fFontSize * CC_CONTENT_SCALE_FACTOR(),
                        CC_SIZE_POINTS_TO_PIXELS(m_tDimensions), 
                        m_hAlignment,
                        m_vAlignment);
    
    if (! tex)
    {
        return false;
    }

	if(m_fStroke>0)
	{
		CCSize cs = tex->getContentSize();
		float edgeSize = m_fFontSize*m_fStroke;
		CCRenderTexture* rt = CCRenderTexture::create(cs.width+edgeSize*2, cs.height+edgeSize*2, kTexture2DPixelFormat_RGBA8888);
		CCSprite* sp = CCSprite::createWithTexture(tex);
		sp->setAnchorPoint(CCPointZero);
		sp->setColor(ccc3(0,0,0));
		sp->setFlipY(true);
		ccBlendFunc blend = {GL_SRC_ALPHA, GL_ONE};
		sp->setBlendFunc(blend);
		rt->begin();
		for(int i=0;i<36;i++)
		{
			sp->setPosition(CCPointMake(edgeSize+edgeSize*sin(i*0.1745f), edgeSize+edgeSize*cos(i*0.1745f)));
			sp->visit();
		}
		sp->setColor(ccc3(255, 255, 255));
		sp->setPosition(CCPointMake(edgeSize, edgeSize));
		sp->visit();
		rt->end();
		tex->release();
		tex = rt->getSprite()->getTexture();
		tex->retain();
		ccTexParams params = {GL_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE};
		tex->setTexParameters(&params);
		//tex->setAntiAliasTexParameters();
	}
	
    this->setTexture(tex);
    tex->release();
	
	CCRect rect = CCRectZero;
    rect.size = m_pobTexture->getContentSize();
    this->setTextureRect(rect);
    
    return true;
}

NS_CC_EXT_END