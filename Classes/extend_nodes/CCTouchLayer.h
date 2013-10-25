#ifndef __CAESARS_NODE_CCTOUCHLAYER_H__
#define __CAESARS_NODE_CCTOUCHLAYER_H__

#include "cocos2d_ext_const.h"
#include "base_nodes/CCNode.h"
#include "touch_dispatcher/CCTouchDelegateProtocol.h"

NS_CC_EXT_BEGIN

//
// CCTouchLayer
//
/**
I wish this layer could manager the touches like a tree.
*/
class CCTouchLayer: public CCNode, public CCTargetedTouchDelegate
{
public:
	CCTouchLayer();
	virtual ~CCTouchLayer();
	virtual bool initWithPriority(int priority, bool hold);
	
    /** create one layer */
    static CCTouchLayer *create(int priority, bool hold);

    virtual void onEnter();
    virtual void onExit();

	/* A CCTouchLayer Child would be added by itself if it's child node */
	void addChildLayer(CCTouchLayer* child);
	void removeChildLayer(CCTouchLayer* child, int touches);
	
    // default implements are used to call script callback if exist
    virtual bool ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent);
    virtual void ccTouchMoved(CCTouch *pTouch, CCEvent *pEvent);
    virtual void ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent);
    virtual void ccTouchCancelled(CCTouch *pTouch, CCEvent *pEvent);
    
	void registerTouchHandler(void);
	void unregisterTouchHandler(void);

    /** Register script touch events handler */
    void registerScriptTouchHandler(int nHandler);
    /** Unregister script touch events handler */
    void unregisterScriptTouchHandler(void);

    /** priority of the touch events. Default is 0 */
    virtual void setTouchPriority(int priority);
    virtual int getTouchPriority();

    inline int getLuaTouchHandler() { return m_uLuaTouchHandler; };
private:
    // Script touch events handler
    int m_uLuaTouchHandler;
    
    int m_nTouchPriority;
	bool m_bTouchHold;
	bool m_inTouch;

	unsigned int m_uTouchFlags;

	CCArray* m_pChildTouchLayers;
	
	CCTouchLayer** m_pChildTouchMap;

	bool m_bIsExit;

	CCTouchLayer* m_parentTouchLayer;

    int excuteScriptTouchHandler(int nEventType, CCTouch *pTouch);
};

NS_CC_EXT_END
#endif //__CAESARS_NODE_CCTOUCHLAYER_H__