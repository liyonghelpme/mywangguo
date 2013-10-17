#ifndef __BONE_H__
#define __BONE_H__
#include "cocos2d.h"
using namespace cocos2d;

class Bone : public CCSprite3D {
public:
    static Bone *create();
    Bone();
    virtual void init();

    virtual void draw();
};
#endif
