#ifndef __CAESARS_NODE_CCTEXTINPUT_H__
#define __CAESARS_NODE_CCTEXTINPUT_H__

#include "cocos2d_ext_const.h"
#include "CCExtendNode.h"
#include "sprite_nodes/CCSprite.h"
#include "actions/CCActionInterval.h"
#include "text_input_node/CCTextFieldTTF.h"

NS_CC_EXT_BEGIN

class CCTextInput: public CCExtendNode, public CCLabelProtocol, public CCIMEDelegate, public CCTouchDelegate
{
private:
	//点击开始位置
	CCPoint m_beginPos;

	// 光标精灵   
    CCSprite *m_pCursorSprite;

	// 光标动画   
    CCAction *m_pCursorAction;  
                   
    // 光标坐标   
    CCPoint m_cursorPos;  
      
    // 输入框内容   
    std::string *m_pInputText;

	CCSize m_designSize;

	unsigned int m_limitNum;

	int priority;

	int m_uAlign;

	CCLabelProtocol* m_pLabel;
	CCNode* m_pLabelNode;
	CCRGBAProtocol* m_pColor;
protected:
    std::string * m_pPlaceHolder;
    ccColor3B m_ColorSpaceHolder;
	ccColor3B m_ColorText;
public:
	CCTextInput();
	~CCTextInput();

	static CCTextInput* create(const char* placeHolder, CCNode* label, CCSize designSize, int align, unsigned int limit);

	bool initWithLabel(const char* placeHolder, CCNode* label, CCSize designSize, int align, unsigned int limit);

	void onEnter();
	void onExit();
	
    virtual bool attachWithIME();
    virtual bool detachWithIME();
      
    // CCLayer Touch   
    bool ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent);  
    void ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent);  
      
    // 判断是否点击在TextField处   
    bool isInTextField(CCPoint endPos);  
    // 得到TextField矩形   
    CCRect getRect();  
      
    // 打开输入法   
    void openIME();  
    // 关闭输入法   
    void closeIME(); 

	//设置字符长度限制，一个汉字三个字符
    void setLimitNum(unsigned int limitNum);
    unsigned int getLimitNum();

    CC_SYNTHESIZE_READONLY(int, m_nCharCount, CharCount);

	void setTouchPriority(int pri);

	//CCLabelProtocol
    virtual void setString(const char *text);
    virtual const char* getString(void);

	//COLOR SUPPORT
	virtual void setColor(const ccColor3B& color);
	virtual const ccColor3B& getColor();
protected:
	
    //////////////////////////////////////////////////////////////////////////
    // CCIMEDelegate interface
    //////////////////////////////////////////////////////////////////////////

    virtual bool canAttachWithIME();
    virtual bool canDetachWithIME();
    virtual void insertText(const char * text, int len);
    virtual void deleteBackward();
    virtual const char * getContentText();

	void resetView();
};

NS_CC_EXT_END

#endif //__CAESARS_NODE_CCTEXTINPUT_H__