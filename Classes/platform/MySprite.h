#ifndef MYSPRITE_H__ 
#define MYSPRITE_H__
#include "cocos2d.h"
using namespace cocos2d;
class MySprite : public CCSprite {
public:
    float offset;
    int offUni;
    virtual void draw();
};
#endif
