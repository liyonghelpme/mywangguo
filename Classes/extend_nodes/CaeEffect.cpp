#include <math.h>

#include "CaeEffect.h"

using namespace cocos2d;

Flame *Flame::create(ccColor3B color) {
    Flame *pRet = new Flame();
    pRet->init(color);
    pRet->autorelease();
    return pRet;
}

bool Flame::init(ccColor3B color) {
	this->initWithFile("gun.png", 10);
    lines = CCArray::create();
    lines->retain();
    scheduleUpdate();

    return true;
}

//调整枪口火焰的角度 
//调整枪口火焰的长度
//调整枪口火焰的消失时间
//调整火焰的数量
void Flame::update(float dt) {
    if(lines->count() < 10) {
        CCSprite *sp = CCSprite::create("Flame.png");
        addChild(sp);
        sp->setColor(ccc3(254, 81, 0));
        ccBlendFunc f = {GL_ONE, GL_ONE};
        sp->setBlendFunc(f);
		/*
        float sx = random()%10000/10000.0*3+2;
        sp->setScaleX(sx);
        float deg = random()%10000/10000.0*60-30;
        sp->setRotation(deg);
		*/
        sp->setAnchorPoint(ccp(0, 0.5));

        sp->runAction(CCSequence::create(CCFadeOut::create(0.2), CCCallFunc::create(this, callfunc_selector(Flame::removeLine)), NULL));

        lines->addObject(sp);
    }
}
void Flame::removeLine() {
    CCNode *l = (CCNode*)lines->objectAtIndex(0);
    l->removeFromParent();
    lines->removeObjectAtIndex(0);
}

Flame::~Flame() {
    lines->release();
}
