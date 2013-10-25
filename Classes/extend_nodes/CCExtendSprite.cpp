#include "CCExtendSprite.h"

#include "textures/CCTextureCache.h"
#include "sprite_nodes/CCSpriteFrameCache.h"

NS_CC_EXT_BEGIN


CCExtendSprite::CCExtendSprite(void)
:m_pHSVHandler(NULL)
{
}

CCExtendSprite::~CCExtendSprite(void)
{
	if(m_pHSVHandler!=NULL)
		delete m_pHSVHandler;
}

void CCExtendSprite::setHueOffset(int offset, bool isRecur)
{
	if(m_pHSVHandler==NULL){
		m_pHSVHandler = new CCHSVShaderHandler();
	}
	m_pHSVHandler->setHueOffset(this, offset, isRecur);
}

void CCExtendSprite::setSatOffset(int offset, bool isRecur)
{
	if(m_pHSVHandler==NULL){
		m_pHSVHandler = new CCHSVShaderHandler();
	}
	m_pHSVHandler->setSatOffset(this, offset, isRecur);
}

void CCExtendSprite::setValOffset(int offset, bool isRecur)
{
	if(m_pHSVHandler==NULL){
		m_pHSVHandler = new CCHSVShaderHandler();
	}
	m_pHSVHandler->setValOffset(this, offset, isRecur);
}

void CCExtendSprite::setHSVParentOffset(int hoff, int soff, int voff)
{
	if(m_pHSVHandler==NULL){
		m_pHSVHandler = new CCHSVShaderHandler();
	}
	m_pHSVHandler->setHSVParentOffset(this, hoff, soff, voff);
}

void CCExtendSprite::addChild(CCNode *child, int zOrder, int tag)
{
	if (m_pHSVHandler!=NULL && m_pHSVHandler->isRecur())
	{
		m_pHSVHandler->recurSetShader(this, child);
	}
	CCSprite::addChild(child, zOrder, tag);
}

CCExtendSprite* CCExtendSprite::create(const char* pszFileName)
{
    CCExtendSprite *pobSprite = new CCExtendSprite();
    if (pobSprite && pobSprite->initWithFile(pszFileName))
    {
        pobSprite->autorelease();
        return pobSprite;
    }
    CC_SAFE_DELETE(pobSprite);
    return NULL;
}

CCExtendSprite* CCExtendSprite::createWithSpriteFrameName(const char *pszSpriteFrameName)
{
    CCSpriteFrame *pFrame = CCSpriteFrameCache::sharedSpriteFrameCache()->spriteFrameByName(pszSpriteFrameName);
    
#if COCOS2D_DEBUG > 0
    char msg[256] = {0};
    sprintf(msg, "Invalid spriteFrameName: %s", pszSpriteFrameName);
    CCAssert(pFrame != NULL, msg);
#endif
    
    CCExtendSprite *pobSprite = new CCExtendSprite();
    if (pFrame && pobSprite && pobSprite->initWithSpriteFrame(pFrame))
    {
        pobSprite->autorelease();
        return pobSprite;
    }
    CC_SAFE_DELETE(pobSprite);
    return NULL;
}

bool CCExtendSprite::initWithSpriteFrame(CCSpriteFrame* pSpriteFrame)
{
	
    CCAssert(pSpriteFrame != NULL, "");

    bool bRet = initWithTexture(pSpriteFrame->getTexture(), pSpriteFrame->getRect());
    setDisplayFrame(pSpriteFrame);

    return bRet;
}

bool CCExtendSprite::initWithFile(const char* pszFilename)
{
	CCAssert(pszFilename != NULL, "Invalid filename for sprite");

    CCTexture2D *pTexture = CCTextureCache::sharedTextureCache()->addImage(pszFilename);
    if (pTexture)
    {
        CCRect rect = CCRectZero;
        rect.size = pTexture->getContentSize();
        return initWithTexture(pTexture, rect);
    }
    return false;
}

bool CCExtendSprite::isAlphaTouched(CCPoint nodePoint)
{
	//CCPoint basePoint = this->getTextureRect().origin;
	//return this->getTexture()->getAlphaAtPoint(basePoint.x + nodePoint.x, basePoint.y + nodePoint.y) == 0;
	return false;
}

void CCExtendSprite::recurSetColor(CCNode* node, const ccColor3B& color)
{
    CCRGBAProtocol *pRGBAProtocol = dynamic_cast<CCRGBAProtocol*>(node);
    if (pRGBAProtocol)
    {
        pRGBAProtocol->setColor(color);
    }
	CCArray* childs = node->getChildren();
	if (childs){
		for(unsigned int i=0; i<childs->count(); i++){
			CCNode *child =  (CCNode *)(childs->objectAtIndex(i));
			if (child)
			{
				recurSetColor(child, color);
			}
		}
	}
}

void CCExtendSprite::recurSetGray(CCNode* node)
{
    CCHSVShaderProtocol *protocol = dynamic_cast<CCHSVShaderProtocol*>(node);
    if (protocol)
    {
		protocol->setSatOffset(-100, false);
    }
	else{
		CCHSVShaderHandler* handler = new CCHSVShaderHandler();
		handler->setHSVParentOffset(node, 0, -100, 0);
		delete handler;
	}
	CCArray* childs = node->getChildren();
	if (childs){
		for(unsigned int i=0; i<childs->count(); i++){
			CCNode *child =  (CCNode *)(childs->objectAtIndex(i));
			if (child)
			{
				recurSetGray(child);
			}
		}
	}
}

/*
void CCExtendSprite::onExit()
{
	//如果引用计数为1，表示是需要判断是否回收的
	if(this->retainCount()==1){
		//如果父节点还存在，表示自己是被单独移除的，所以加入到回收
		if(this->getParent()->isRunning()){

		}
		else{

		}
	}
}
*/

NS_CC_EXT_END