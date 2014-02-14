#ifndef __SCISSORNODE_H__
#define __SCISSORNODE_H__
#include "cocos2d.h"
using namespace cocos2d;
class Scissor : public cocos2d::CCNode {
	
public:
    static Scissor *create();
    virtual void visit();
};
#endif
