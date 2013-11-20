#include "CCNative.h"
void setScriptTouchPriority(CCLayer *lay, int pri){
    CCLog("setScriptTouchPriority %d", pri);
    CCTouchScriptHandlerEntry *st = lay->getScriptTouchHandlerEntry();
    st->setPriority(pri);
    CCLog("priority %d %d", st->getPriority(), st->getSwallowsTouches());
    /*
    lay->retain();
    CCNode *par = lay->getParent();
    lay->removeFromParent();
    par->addChild(lay);
    lay->release();
    */
    lay->setTouchPriority(pri);
}
