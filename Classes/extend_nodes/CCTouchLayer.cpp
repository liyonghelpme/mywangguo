#include "CCTouchLayer.h"
#include "CCDirector.h"
#include "touch_dispatcher/CCTouchDispatcher.h"
#include "CCLuaEngine.h"
#include <algorithm>

NS_CC_EXT_BEGIN

CCTouchLayer::CCTouchLayer()
: m_uLuaTouchHandler(NULL)
, m_nTouchPriority(0)
, m_pChildTouchLayers(NULL)
, m_uTouchFlags(0)
, m_parentTouchLayer(NULL)
, m_bIsExit(false)
, m_pChildTouchMap(NULL)
, m_bTouchHold(true)
, m_inTouch(false)
{
	m_pChildTouchMap = new CCTouchLayer* [8];
	for(int i=0;i<8;i++){
		m_pChildTouchMap[i] = NULL;
	}
}

CCTouchLayer::~CCTouchLayer()
{
    unregisterScriptTouchHandler();
	CC_SAFE_RELEASE(m_pChildTouchLayers);
	if(m_pChildTouchMap){
		delete [] m_pChildTouchMap;
	}
}

bool CCTouchLayer::initWithPriority(int priority, bool hold)
{
	m_nTouchPriority = priority;
	m_bTouchHold = hold;
	return true;
}

CCTouchLayer* CCTouchLayer::create(int priority, bool hold)
{
    CCTouchLayer *pRet = new CCTouchLayer();
    if (pRet && pRet->initWithPriority(priority, hold))
    {
        pRet->autorelease();
        return pRet;
    }
    else
    {
        CC_SAFE_DELETE(pRet);
        return NULL;
    }
}

void CCTouchLayer::onEnter()
{
	if(m_bIsExit){
		m_bIsExit = false;
		this->release();
	}
	else{
		registerTouchHandler();
	}

    // then iterate over all the children
    CCNode::onEnter();
}

void CCTouchLayer::onExit()
{
    CCNode::onExit();

	if(m_uTouchFlags>0 || m_inTouch){
		m_bIsExit = true;
		this->retain();
	}
	else{
		unregisterTouchHandler();
	}
}

void CCTouchLayer::registerTouchHandler()
{
	CCNode* pNode = this->getParent();
	m_parentTouchLayer = NULL;
	while(pNode!=NULL){
		m_parentTouchLayer = dynamic_cast<CCTouchLayer*>(pNode);
		if(m_parentTouchLayer!=NULL){
			break;
		}
		pNode = pNode->getParent();
	}
	//m_parentTouchLayer = dynamic_cast<CCTouchLayer*>(getParent());
	if(m_parentTouchLayer!=NULL){
		m_parentTouchLayer->addChildLayer(this);
	}
	else{
		CCDirector::sharedDirector()->getTouchDispatcher()->addTargetedDelegate(this,m_nTouchPriority,true);
	}
}

void CCTouchLayer::unregisterTouchHandler()
{
	if(m_parentTouchLayer){
		m_parentTouchLayer->removeChildLayer(this, m_uTouchFlags);
		m_parentTouchLayer = NULL;
	}
	else{
        CCDirector::sharedDirector()->getTouchDispatcher()->removeDelegate(this);
	}
}

/** Register script touch events handler */
void CCTouchLayer::registerScriptTouchHandler(int nHandler)
{
	m_uLuaTouchHandler = nHandler;
}
/** Unregister script touch events handler */
void CCTouchLayer::unregisterScriptTouchHandler(void)
{
	m_uLuaTouchHandler = 0;
}

void CCTouchLayer::addChildLayer(CCTouchLayer* childLayer)
{
	if(m_pChildTouchLayers==NULL){
		m_pChildTouchLayers = CCArray::createWithCapacity(4);
		m_pChildTouchLayers->retain();
	}
	m_pChildTouchLayers->addObject(childLayer);
}

void CCTouchLayer::removeChildLayer(CCTouchLayer* childLayer, int touches)
{
	if(m_pChildTouchLayers!=NULL){
		m_pChildTouchLayers->removeObject(childLayer);
	}
	for(int i=0; touches!=0; i++){
		if(touches & 1){
			m_pChildTouchMap[i] = NULL;
		}
		touches >>= 1;
	}
}

void CCTouchLayer::setTouchPriority(int priority)
{
    if (m_nTouchPriority != priority)
    {
        m_nTouchPriority = priority;
		/*if()
		{
			setTouchEnabled(false);
			setTouchEnabled(true);*/
    }
}

int CCTouchLayer::getTouchPriority()
{
    return m_nTouchPriority;
}

/**
 * Used for sort
 */
static int less(const CCObject* p1, const CCObject* p2)
{
    return ((CCTouchLayer*)p1)->getTouchPriority() < ((CCTouchLayer*)p2)->getTouchPriority();
}

/** if user remove the touchLayer when check the touch event, an error appears;
	so, retain first;
*/
bool CCTouchLayer::ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent)
{
	bool isTouch=false, ret=false;
	CCPoint touchPoint = pTouch->getLocation();
	int id = pTouch->getID();
	//it should not handle more touch event
	if(!m_bIsExit){
		m_inTouch = true;
		if(m_pChildTouchLayers && m_pChildTouchLayers->count()>1){
			std::sort(m_pChildTouchLayers->data->arr, m_pChildTouchLayers->data->arr + m_pChildTouchLayers->data->num, less);
		}
		bool visible = this->isVisible();
		CCNode* parent = this->getParent();
		while(visible && parent!=NULL){
			visible = parent->isVisible();
			parent = parent->getParent();
		}
		if(m_bTouchHold && visible){
			CCPoint nodePoint = this->convertToNodeSpace(touchPoint);
			const CCSize& nodeSize = this->getContentSize();
			if(nodePoint.x>=0 && nodePoint.y>=0 && nodePoint.x <= nodeSize.width && nodePoint.y <= nodeSize.height){
				ret = true;
			}
		}
		if(!m_bTouchHold || ret){
			CCObject* child;
			CCARRAY_FOREACH(m_pChildTouchLayers, child)
			{
				CCTouchLayer* pNode = (CCTouchLayer*) child;
				if(pNode && pNode->ccTouchBegan(pTouch, pEvent)){
					ret = isTouch = true;
					m_pChildTouchMap[id] = pNode;
					break;
				}
			}
			if(!isTouch && m_uLuaTouchHandler!=0){
				if(this->excuteScriptTouchHandler(CCTOUCHBEGAN, pTouch)>0){
					ret = true;
					m_pChildTouchMap[id] = this;
				}
			}
		}
		if(ret){
			m_uTouchFlags |= (1<<id);
		}
		m_inTouch = false;
	}
	return ret;
}

void CCTouchLayer::ccTouchMoved(CCTouch *pTouch, CCEvent *pEvent)
{
	int id = pTouch->getID();
	if(m_pChildTouchMap[id]!=NULL){
		if(m_pChildTouchMap[id]==this){
			this->excuteScriptTouchHandler(CCTOUCHMOVED, pTouch);
		}
		else{
			m_pChildTouchMap[id]->ccTouchMoved(pTouch, pEvent);
		}
	}
}

void CCTouchLayer::ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent)
{
	int id = pTouch->getID();
	if(m_pChildTouchMap[id]!=NULL){
		if(m_pChildTouchMap[id]==this){
			this->excuteScriptTouchHandler(CCTOUCHENDED, pTouch);
		}
		else{
			m_pChildTouchMap[id]->ccTouchEnded(pTouch, pEvent);
		}
	}
	m_uTouchFlags -= (1 << id);
	m_pChildTouchMap[id] = NULL;
	if(m_uTouchFlags==0 && m_bIsExit){
		unregisterTouchHandler();
		m_bIsExit = false;
		this->release();
	}
}
 
void CCTouchLayer::ccTouchCancelled(CCTouch *pTouch, CCEvent *pEvent)
{
	int id = pTouch->getID();
	if(m_pChildTouchMap[id]!=NULL){
		if(m_pChildTouchMap[id]==this){
			this->excuteScriptTouchHandler(CCTOUCHCANCELLED, pTouch);
		}
		else{
			m_pChildTouchMap[id]->ccTouchCancelled(pTouch, pEvent);
		}
	}
	m_uTouchFlags -= (1 << id);
	m_pChildTouchMap[id] = NULL;
	if(m_uTouchFlags==0 && m_bIsExit){
		unregisterTouchHandler();
		m_bIsExit = false;
		this->release();
	}
}

int CCTouchLayer::excuteScriptTouchHandler(int nEventType, CCTouch *pTouch)
{
	if(m_bIsExit)
		return 0;
	int id = pTouch->getID();
	CCPoint touchPoint = pTouch->getLocation();
	CCLuaEngine* engine = CCLuaEngine::defaultEngine();
    engine->getLuaStack()->clean();
	engine->getLuaStack()->pushInt(nEventType);
	engine->getLuaStack()->pushInt(id);
	engine->getLuaStack()->pushFloat(touchPoint.x);
    engine->getLuaStack()->pushFloat(touchPoint.y);

	return engine->getLuaStack()->executeFunctionByHandler(m_uLuaTouchHandler, 4);
}

NS_CC_EXT_END