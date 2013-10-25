#include "CCTextInput.h"
#include "CCDirector.h"
#include "CCEGLView.h"
#include "touch_dispatcher/CCTouchDispatcher.h"

NS_CC_EXT_BEGIN

static int _calcCharCount(const char * pszText)
{
    int n = 0;
    char ch = 0;
    while ((ch = *pszText))
    {
        CC_BREAK_IF(! ch);
        
        if (0x80 != (0xC0 & ch))
        {
            ++n;
        }
        ++pszText;
    }
    return n;
}


CCTextInput::CCTextInput()
{
	CCTextFieldTTF();
    
    m_pCursorSprite = NULL;
    m_pCursorAction = NULL;
    
    m_pInputText = NULL;
    m_limitNum = 30;
	m_ColorSpaceHolder = ccc3(127,127,127);
	m_ColorText = ccc3(0,0,0);
	priority=-128;
}

CCTextInput::~CCTextInput()
{

}

void CCTextInput::onEnter()
{
	CCExtendNode::onEnter();
	CCDirector::sharedDirector()->getTouchDispatcher()->addTargetedDelegate(this, this->priority, false);
}

void CCTextInput::onExit()
{
    this->detachWithIME();
    CCExtendNode::onExit();
    CCDirector::sharedDirector()->getTouchDispatcher()->removeDelegate(this);
}

unsigned int CCTextInput::getLimitNum()
{
    return m_limitNum;
}
//设置字符长度
void CCTextInput::setLimitNum(unsigned int limitNum)
{
    m_limitNum = limitNum;
}

void CCTextInput::setTouchPriority(int pri)
{
	this->priority = pri;
}

void CCTextInput::openIME()
{
    m_pCursorSprite->setVisible(true);
    this->attachWithIME();
}

void CCTextInput::closeIME()
{
    m_pCursorSprite->setVisible(false);
    this->detachWithIME();
}

bool CCTextInput::isInTextField(CCPoint endPos)
{   
    CCPoint pTouchPos = this->convertToNodeSpace(endPos);
	CCSize size = this->getContentSize(); 
	if (pTouchPos.x>0 && pTouchPos.y>-size.height && pTouchPos.x < size.width && pTouchPos.y < size.height*2)
		return true;
    return false;
}

void CCTextInput::ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent)
{
    CCPoint endPos = pTouch->getLocationInView();
    endPos = CCDirector::sharedDirector()->convertToGL(endPos);
    // 判断是打开输入法还是关闭输入法
    isInTextField(endPos) ? openIME() : closeIME();
}

bool CCTextInput::ccTouchBegan(cocos2d::CCTouch *pTouch, cocos2d::CCEvent *pEvent)
{    
    m_beginPos = pTouch->getLocationInView();
    m_beginPos = CCDirector::sharedDirector()->convertToGL(m_beginPos);
    
	if(this->isInTextField(m_beginPos)){
	    return true;
	}
	else{
		closeIME();
		return false;
	}
}

CCRect CCTextInput::getRect()
{
    CCSize size = m_designSize;
   
    CCRect rect = CCRectMake(0 - size.width * getAnchorPoint().x, 0 - size.height * getAnchorPoint().y, size.width, size.height);
    return  rect;
}

CCTextInput* CCTextInput::create(const char* placeHolder, CCNode* label, CCSize designSize, int align, unsigned int limit)
{
	CCTextInput *pRet = new CCTextInput();
    
    if(pRet)
    {
		pRet->setContentSize(designSize);
		pRet->setClip(true);
		if(pRet->initWithLabel(placeHolder, label, designSize, align, limit)){
			pRet->autorelease();
			return pRet;
		}
    }
    
    CC_SAFE_DELETE(pRet);
    
    return NULL;
}

bool CCTextInput::initWithLabel(const char* placeHolder, CCNode* label, CCSize designSize, int align, unsigned int limit)
{
	m_uAlign = align;
	m_pColor = dynamic_cast<CCRGBAProtocol*>(label);
	m_pLabelNode = label;
	m_pLabel = dynamic_cast<CCLabelProtocol*>(label);
    if (placeHolder!=NULL)
    {
        m_pPlaceHolder = (placeHolder) ? new std::string(placeHolder) : new std::string;
		m_pLabel->setString(placeHolder);
		m_pColor->setColor(m_ColorSpaceHolder);
    }
	this->setLimitNum(limit);

	int cursorHeight = (int)(designSize.height * 0.9);
	int* pixels = new int[2*cursorHeight];
	for (int i=0; i<cursorHeight; ++i) {
		for (int j=0; j<2; ++j) {
			 pixels[i*2+j] = 0x00000000;
		}
	}
	CCTexture2D *texture = new CCTexture2D();
	texture->initWithData(pixels, kCCTexture2DPixelFormat_RGB888, 1, 1, CCSizeMake(2, cursorHeight));
	delete[] pixels;
	m_pCursorSprite = CCSprite::createWithTexture(texture);
	m_pCursorSprite->setAnchorPoint(CCPointMake(0, 0.5));
	m_cursorPos = CCPointMake(0, designSize.height / 2);
	addChild(m_pCursorSprite, 1, 1);

	m_pCursorAction = CCRepeatForever::create((CCActionInterval *) CCSequence::create(CCFadeOut::create(0.25f), CCFadeIn::create(0.25f), NULL));
    m_pCursorSprite->runAction(m_pCursorAction);
	m_pCursorSprite->setVisible(false);

	// add view
	addChild(m_pLabelNode, 0, 0);
	setString(m_pLabel->getString());

	return true;
}

void CCTextInput::resetView()
{
	float labelWidth = m_pLabelNode->getContentSize().width * m_pLabelNode->getScaleX();
	if(labelWidth>this->getContentSize().width){
		m_pLabelNode->setAnchorPoint(CCPointMake(1,0.5));
		m_pLabelNode->setPosition(this->getContentSize().width-2, this->getContentSize().height/2);

		m_pCursorSprite->setPosition(CCPointMake(this->getContentSize().width-2, this->getContentSize().height/2));
	}
	else{
		CCPoint anchorPoint = CCPointMake(m_uAlign/2.0, 0.5);
		const CCSize& size = this->getContentSize();
		m_pLabelNode->setAnchorPoint(anchorPoint);
		m_pLabelNode->setPosition(size.width * anchorPoint.x, size.height * anchorPoint.y);

		if(! m_pInputText->length())
			m_pCursorSprite->setPosition(CCPointMake(size.width * anchorPoint.x, size.height * anchorPoint.y));
		else
			m_pCursorSprite->setPosition(CCPointMake((size.width-labelWidth) * anchorPoint.x + labelWidth, size.height * anchorPoint.y));
	}
}

// input text property
void CCTextInput::setString(const char *text)
{
    CC_SAFE_DELETE(m_pInputText);

    if (text)
    {
        m_pInputText = new std::string(text);
    }
    else
    {
        m_pInputText = new std::string;
    }

    // if there is no input text, display placeholder instead
    if (! m_pInputText->length())
    {
        m_pLabel->setString(m_pPlaceHolder->c_str());
		m_pColor->setColor(m_ColorSpaceHolder);
    }
    else
    {
        m_pLabel->setString(m_pInputText->c_str());
		m_pColor->setColor(m_ColorText);
    }
    m_nCharCount = _calcCharCount(m_pInputText->c_str());
	this->resetView();
}

const char* CCTextInput::getString(void)
{
    return m_pInputText->c_str();
}

const char* CCTextInput::getContentText()
{
    return m_pInputText->c_str();
}

void CCTextInput::setColor(const ccColor3B& color)
{
	m_ColorText = color;
	m_pCursorSprite->setColor(color);
	if(m_pInputText->length())
	{
		m_pColor->setColor(m_ColorText);
	}
}

const ccColor3B& CCTextInput::getColor()
{
	return m_ColorText;
}


//////////////////////////////////////////////////////////////////////////
// CCIMEDelegate
//////////////////////////////////////////////////////////////////////////

bool CCTextInput::attachWithIME()
{
    bool bRet = CCIMEDelegate::attachWithIME();
    if (bRet)
    {
        // open keyboard
        CCEGLView * pGlView = CCDirector::sharedDirector()->getOpenGLView();
        if (pGlView)
        {
            pGlView->setIMEKeyboardState(true);
        }
    }
    return bRet;
}

bool CCTextInput::detachWithIME()
{
    bool bRet = CCIMEDelegate::detachWithIME();
    if (bRet)
    {
        // close keyboard
        CCEGLView * pGlView = CCDirector::sharedDirector()->getOpenGLView();
        if (pGlView)
        {
            pGlView->setIMEKeyboardState(false);
        }
    }
    return bRet;
}

bool CCTextInput::canAttachWithIME()
{
    return true;
}

bool CCTextInput::canDetachWithIME()
{
    return true;
}

void CCTextInput::insertText(const char * text, int len)
{
    std::string sInsert(text, len);

    // insert \n means input end
    int nPos = sInsert.find('\n');
    if ((int)sInsert.npos != nPos)
    {
        len = nPos;
        sInsert.erase(nPos);
    }
    
    if (len > 0)
    {
		unsigned int inputCharCount = _calcCharCount(sInsert.c_str()) + m_nCharCount;
		if(inputCharCount>m_limitNum){
			return;
		}
        m_nCharCount = inputCharCount;
        std::string sText(*m_pInputText);
        sText.append(sInsert);
        setString(sText.c_str());
    }

    if ((int)sInsert.npos == nPos) {
        return;
    }
    
    // if delegate hasn't processed, detach from IME by default
    closeIME();
}

void CCTextInput::deleteBackward()
{
    int nStrLen = m_pInputText->length();
    if (! nStrLen)
    {
        // there is no string
        return;
    }

    // get the delete byte number
    int nDeleteLen = 1;    // default, erase 1 byte

    while(0x80 == (0xC0 & m_pInputText->at(nStrLen - nDeleteLen)))
    {
        ++nDeleteLen;
    }

    // if all text deleted, show placeholder string
    if (nStrLen <= nDeleteLen)
    {
        setString("");
        return;
    }

    // set new input text
    std::string sText(m_pInputText->c_str(), nStrLen - nDeleteLen);
    setString(sText.c_str());
}

NS_CC_EXT_END