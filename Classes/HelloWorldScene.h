#ifndef __HELLOWORLD_SCENE_H__
#define __HELLOWORLD_SCENE_H__

#include "cocos2d.h"
#include "CCSprite3D.h"
#include "Bone2.h"
using namespace cocos2d;

class HelloWorld : public cocos2d::CCLayer
{
public:
    // Here's a difference. Method 'init' in cocos2d-x returns bool, instead of returning 'id' in cocos2d-iphone
    virtual bool init();  

    // there's no 'id' in cpp, so we recommend returning the class instance pointer
    static cocos2d::CCScene* scene();
    
    // a selector callback
    void menuCloseCallback(CCObject* pSender);
    
    // implement the "static node()" method manually
    CREATE_FUNC(HelloWorld);
    CCSprite *sp;
    virtual void update(float diff);
    int frameNum;
    
    CCSprite3D *m33;

    Bone b1, b2;
    Bone *allBone[2];

    kmMat4 invBoneMat[2];

    float passTime;

    CCSprite3D *rb1, *rb2;
};

#endif // __HELLOWORLD_SCENE_H__
