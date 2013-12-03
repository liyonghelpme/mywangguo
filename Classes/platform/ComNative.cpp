#include "CCNative.h"
#include "cocos2d.h"
#include <stdlib.h>
using namespace cocos2d;
using namespace std;

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

string getFileData(const char *fname) {
    unsigned long size;
    unsigned char *con = CCFileUtils::sharedFileUtils()->getFileData(fname, "r", &size);
    string str((char*)con, size);
    //删除返回的文件数据
    delete [] con;
    return str;
}
