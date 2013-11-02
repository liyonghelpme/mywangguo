#include "UpdateScene.h"
#include "MyPlugins.h"
#include "CCLuaEngine.h"
#include "AssetsManager.h"
UpdateScene *UpdateScene::create() {
    UpdateScene *p = new UpdateScene();
    p->init();
    p->autorelease();
    return p;
}
bool UpdateScene::init() {
    CCScene::init();
	CCDirector *pDirector = CCDirector::sharedDirector();
    CCSprite *lm = CCSprite::create("loadMain.png");
    addChild(lm);
    CCSize vs = pDirector->getVisibleSize();
    lm->setPosition(ccp(vs.width/2, vs.height/2));
    CCSize sz = lm->getContentSize();

    lm->setScaleX(vs.width/sz.width);
    lm->setScaleY(vs.height/sz.height);

    updateYet = false;
    scheduleUpdate();
    nodeNum = 0;

	return true;
}
//每10个百分点 增加1个点
void UpdateScene::loadPoint(int p) {
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
        CCUserDefault *def = CCUserDefault::sharedUserDefault();
	    //不需要更新文件
        if(def->getStringForKey("update") != "0")
            ap->updateFiles();
        else  {
            progress = 200;
        }
    } else {
		if(progress == 200) {
			CCDictionary *dict = CCDictionary::create();
			CCDictionary *ads = CCDictionary::create();
			ads->setObject(CCString::create("AdsAdmob"), "name");
			dict->setObject(ads, "ads");
			MyPlugins::getInstance()->loadPlugins(dict);
        
		
			CCLuaEngine* pEngine = CCLuaEngine::defaultEngine();

			std::string path = CCFileUtils::sharedFileUtils()->fullPathForFilename("main.lua");
			pEngine->executeScriptFile(path.c_str());
		}else {
			loadPoint(progress);
		}
	}
}
