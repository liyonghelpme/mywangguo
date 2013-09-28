#include "cocos2d.h"
#include "AppDelegate.h"
#include "SimpleAudioEngine.h"
#include "script_support/CCScriptSupport.h"
#include "CCLuaEngine.h"
#include "cocos2d_ext_tolua.h"
#include "iniReader.h"
#include "ImageUpdate.h"



USING_NS_CC;
using namespace CocosDenshion;

AppDelegate::AppDelegate()
{
    // fixed me
    //_CrtSetDbgFlag(_CRTDBG_ALLOC_MEM_DF|_CRTDBG_LEAK_CHECK_DF);
}

AppDelegate::~AppDelegate()
{
    // end simple audio engine here, or it may crashed on win32
    SimpleAudioEngine::sharedEngine()->end();
    //CCScriptEngineManager::purgeSharedManager();
}

bool AppDelegate::applicationDidFinishLaunching()
{
    // initialize director
    CCDirector *pDirector = CCDirector::sharedDirector();
    pDirector->setOpenGLView(CCEGLView::sharedOpenGLView());
	CCSize winSize = pDirector->getVisibleSize();
	CCEGLView::sharedOpenGLView()->setDesignResolutionSize(winSize.width, winSize.height, kResolutionNoBorder);

    // turn on display FPS
    pDirector->setDisplayStats(false);

    // set FPS. the default value is 1.0/60 if you don't call this
    pDirector->setAnimationInterval(1.0 / 60);

    // register lua engine
    CCLuaEngine* pEngine = CCLuaEngine::defaultEngine();
    lua_State *state = pEngine->getLuaStack()->getLuaState();
    tolua_MyExt_open(state);
    //LuaScript 首先在cache 中寻找
    //接着在资源包里面寻找
	//pEngine->addSearchPath(CCFileUtils::sharedFileUtils()->getWritablePath().c_str());
    //文件没有在resource 根目录
    //pEngine->addSearchPath("LuaScript");

    CCScriptEngineManager::sharedManager()->setScriptEngine(pEngine);

    //根据config.ini 配置UserDefault 
    unsigned long fsize;
    unsigned char *data = CCFileUtils::sharedFileUtils()->getFileData("config.ini", "r", &fsize);
    map<string, string> *nm = handleIni((char*)data, fsize); 
    delete []data;
    CCUserDefault *def = CCUserDefault::sharedUserDefault();
    for(map<string, string>::iterator it=nm->begin(); it!=nm->end(); it++) {
		def->setStringForKey(it->first.c_str(), it->second);
    }
    delete nm;

    //搜索文件路径
    CCFileUtils::sharedFileUtils()->addSearchPath(CCFileUtils::sharedFileUtils()->getWritablePath().c_str());
    CCFileUtils::sharedFileUtils()->addSearchPath("LuaScript");
    CCFileUtils::sharedFileUtils()->addSearchPath("images");
    
    updateFiles();

    
    std::string path = CCFileUtils::sharedFileUtils()->fullPathForFilename("main.lua");
    pEngine->executeScriptFile(path.c_str());
    return true;
}
//更新脚本
//更新图片
static AssetsManager *pAssetsManager = NULL;
static ImageUpdate *pImageUpdate = NULL;
void AppDelegate::updateFiles() {
    pathToSave = CCFileUtils::sharedFileUtils()->getWritablePath();
    CCLog("pathToSave %s", pathToSave.c_str());
    if(pAssetsManager == NULL) {
        CCUserDefault *def = CCUserDefault::sharedUserDefault();
		pAssetsManager = new AssetsManager((def->getStringForKey("codeUrl")+def->getStringForKey("zipFile")).c_str(), (def->getStringForKey("codeUrl")+def->getStringForKey("versionFile")).c_str());
    }
    bool suc = false;
    if(pAssetsManager->checkUpdate()) {
        if(pAssetsManager->update()) {
            suc = true;
            CCLog("update Script successfully");
        } else {
            CCLog("update Script Fail");
        }
    }
    
    
    if(pImageUpdate == NULL) {
        CCUserDefault *def = CCUserDefault::sharedUserDefault();
		pImageUpdate = new ImageUpdate(def->getStringForKey("baseUrl").c_str(), (def->getStringForKey("imageVer")).c_str(), def->getStringForKey("localVer").c_str());
    }
    suc = false;
    if(pImageUpdate->checkUpdate()) {
        if(pImageUpdate->update()) {
            suc = true;
            CCLog("update Image successfully");
        } else {
            CCLog("update Image fail");
		}
    }
}


// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    CCDirector::sharedDirector()->stopAnimation();
    SimpleAudioEngine::sharedEngine()->pauseBackgroundMusic();
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    CCDirector::sharedDirector()->startAnimation();
    SimpleAudioEngine::sharedEngine()->resumeBackgroundMusic();
}
