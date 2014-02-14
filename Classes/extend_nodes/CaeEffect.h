#ifndef __CAEEFFECT_H__
#define __CAEEFFECT_H__

#include "cocos2d.h"
using namespace cocos2d;

class Flame : public CCSpriteBatchNode {
public:
    virtual bool init(ccColor3B color);
    static Flame *create(ccColor3B color);

    virtual void update(float dt);
    ~Flame();

    void removeLine();
private:
    CCArray *lines;
};

#endif //__CAEEFFECT_H__
