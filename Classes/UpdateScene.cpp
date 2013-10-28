#include "UpdateScene.h"
#include "MyPlugins.h"
#include "CCLuaEngine.h"
UpdateScene *UpdateScene::create(AppDelegate *a) {
    UpdateScene *p = new UpdateScene();
    p->ap = a;
    p->init();
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
    float sca = (std::max)(vs.width/sz.width, vs.height/sz.height);

    lm->setScale(sca);

    updateYet = false;
    scheduleUpdate();
	return true;
}
void UpdateScene::update(float diff) {
    if(!updateYet) {
        updateYet = true;
        CCUserDefault *def = CCUserDefault::sharedUserDefault();
	    if(def->getStringForKey("update") != "0")
            ap->updateFiles();


        CCDictionary *dict = CCDictionary::create();
        CCDictionary *ads = CCDictionary::create();
        ads->setObject(CCString::create("AdsAdmob"), "name");
        dict->setObject(ads, "ads");
        MyPlugins::getInstance()->loadPlugins(dict);
        
		
		CCLuaEngine* pEngine = CCLuaEngine::defaultEngine();

        std::string path = CCFileUtils::sharedFileUtils()->fullPathForFilename("main.lua");
        pEngine->executeScriptFile(path.c_str());
    }
}
