#include "Scissor.h"
Scissor *Scissor::create() {
    Scissor *pRet = new Scissor();
    pRet->autorelease();
    return pRet;
}
void Scissor::visit() {
    CCSize szLimitSize = getContentSize();
    
	CCPoint worldPt = getParent()->convertToWorldSpace(getPosition());
	//worldPt.x -= szLimitSize.width/2;
    //worldPt.y -= szLimitSize.height/2;

    CCSize size;
    size.width = szLimitSize.width;
    size.height = szLimitSize.height;

    glEnable(GL_SCISSOR_TEST);
    CCDirector::sharedDirector()->getOpenGLView()->setScissorInPoints(worldPt.x, worldPt.y, size.width, size.height);
    CCNode::visit();
    glDisable(GL_SCISSOR_TEST);
}
