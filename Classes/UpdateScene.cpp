﻿#include "UpdateScene.h"

#include "CCLuaEngine.h"
#include "AssetsManager.h"
UpdateScene *UpdateScene::create() {
    UpdateScene *p = new UpdateScene();
    p->init();
    p->autorelease();
    return p;
}
static int localcount = 0;
bool UpdateScene::init() {
    CCScene::init();
	CCDirector *pDirector = CCDirector::sharedDirector();
    //背景黑框和屏幕一样大小
    CCSprite *lm = CCSprite::create("black.png");
    addChild(lm);
    CCSize vs = pDirector->getVisibleSize();
    lm->setPosition(ccp(vs.width/2, vs.height/2));
    CCSize sz = lm->getContentSize();

    lm->setScaleX(vs.width/sz.width);
    lm->setScaleY(vs.height/sz.height);
    
    CCLabelTTF *lab = CCLabelTTF::create("Loading...", "", 25);
    lab->setColor(ccc3(255, 255, 255));
    lab->enableShadow(CCSizeMake(1, 2), 1, 1, true);
    lab->setAnchorPoint(ccp(0, 0.5));
    lab->setPosition(ccp(16, 768-743));
    addChild(lab);
    
    CCSpriteFrameCache *sf = CCSpriteFrameCache::sharedSpriteFrameCache();
	//loadAni 效果很差
	//CCTexture2D::setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444);
    sf->addSpriteFramesWithFile("loadAni.plist");
	//CCTexture2D::setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888);

    CCAnimation *ani = CCAnimation::create();
    char name[100];
    for(int i = 0; i <= 8; i++) {
        sprintf(name, "load%d.png", i);
        ani->addSpriteFrame(sf->spriteFrameByName(name));
    }
    ani->setDelayPerUnit(2/20.0);
    ani->setRestoreOriginalFrame(true);

    CCSprite *cat = CCSprite::createWithSpriteFrameName("load0.png");
    addChild(cat);
    cat->setPosition(ccp(vs.width-228*0.7, 101*0.7));
    cat->runAction(CCRepeatForever::create(CCAnimate::create(ani)));
	cat->setScale(1);


    updateYet = false;
    scheduleUpdate();
    nodeNum = 0;

	return true;
}
//每10个百分点 增加1个点
void UpdateScene::loadPoint(int p) {
    return;
	CCDirector *pDirector = CCDirector::sharedDirector();
    CCSize vs = pDirector->getVisibleSize();
    int k = p/10;
    int initX = 40; 
    int initY = vs.height-50;
    int offX = 40;
    while(k > nodeNum) {
		CCLog("add Soldier");
        CCSprite *s = CCSprite::create("soldier3.png");
        s->setPosition(ccp(initX+offX*nodeNum, initY));
        s->setScale(0.5);
		addChild(s);
		s->runAction(CCRepeatForever::create(CCSequence::create(CCMoveBy::create(0.3, ccp(5, 0)), CCMoveBy::create(0.3, ccp(-5, 0)), NULL)));
		s->runAction(CCRepeatForever::create(CCSequence::create(CCRotateBy::create(0.4, -10), CCRotateBy::create(0.4, 10), NULL)));
        nodeNum++;
    }
}
void UpdateScene::update(float diff) {
    if(!updateYet) {
        updateYet = true;
	    //不需要更新文件
        CCUserDefault *def = CCUserDefault::sharedUserDefault();
        if(def->getStringForKey("update") != "0")
            ap->updateFiles();
        else  {
            progress = 200;
        }
    } else {
        localcount = localcount+1;
		CCLog("progress to load main %d", progress);
        if(progress == 200 && localcount >= 50) {
            CCUserDefault *def = CCUserDefault::sharedUserDefault();
            if(def->getStringForKey("update") != "0") {
                if(publicAssets != NULL) {
                    publicAssets->updateVersion();
                }
            }
            /*
			CCDictionary *dict = CCDictionary::create();
			CCDictionary *ads = CCDictionary::create();
			ads->setObject(CCString::create("SocialFacebook"), "name");
			dict->setObject(ads, "social");
			MyPlugins::getInstance()->loadPlugins(dict);
            */
		
			CCLuaEngine* pEngine = CCLuaEngine::defaultEngine();

			std::string path = CCFileUtils::sharedFileUtils()->fullPathForFilename("main.lua");
			pEngine->executeScriptFile(path.c_str());
		}else {
			loadPoint(progress);
		}
	}
}
