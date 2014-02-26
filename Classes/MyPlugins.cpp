//
//  MyPlugins.cpp
//  nozomi
//
//  Created by  stc on 13-6-24.
//
//

#include "MyPlugins.h"
#include "PluginManager.h"
#include "support/CCNotificationCenter.h"
#include "support/user_default/CCUserDefault.h"
#include <string>

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#endif

using namespace std;
using namespace cocos2d::plugin;
using namespace cocos2d;

MyPlugins* MyPlugins::s_pPlugins = NULL;

MyPlugins::MyPlugins()
: m_pRetListener(NULL)
, m_pIAPPlugin(NULL)
, m_pSharePlugin(NULL)
, m_pIAPListener(NULL)
, m_pAds(NULL)
{
    
}

MyPlugins::~MyPlugins()
{
	unloadPlugins();
	CC_SAFE_DELETE(m_pRetListener);
}

MyPlugins* MyPlugins::getInstance()
{
	if (s_pPlugins == NULL) {
		s_pPlugins = new MyPlugins();
	}
	return s_pPlugins;
}

void MyPlugins::destroyInstance()
{
	CC_SAFE_DELETE (s_pPlugins);
	PluginManager::end();
}

void MyPlugins::loadPlugins(CCDictionary* dict)
{
	m_pPluginNames = CCArray::create();
	m_pPluginNames->retain();
	CCDictionary* pluginSetting;
	pluginSetting = (CCDictionary*) dict->objectForKey("social");
	if(pluginSetting!=NULL){
		m_pSharePlugin = dynamic_cast<ProtocolSocial*>(PluginManager::getInstance()->loadPlugin(pluginSetting->valueForKey("name")->getCString()));
		if (NULL != m_pSharePlugin)
		{
			m_pPluginNames->addObject(CCString::create(pluginSetting->valueForKey("name")->getCString()));

			TSocialDeveloperInfo pSocialInfo;
			CCDictionary* configDict = (CCDictionary*) pluginSetting->objectForKey("config");
			CCArray* configKeys = configDict->allKeys();
			CCObject* configKey;
			CCARRAY_FOREACH(configKeys, configKey)
			{
				const char* keyStr = ((CCString*)configKey)->getCString();
				pSocialInfo[keyStr] = configDict->valueForKey(keyStr)->getCString();
			}
			m_pSharePlugin->setDebugMode(false);
			m_pSharePlugin->configDeveloperInfo(pSocialInfo);
			if (m_pRetListener == NULL)
			{
				m_pRetListener = new MyShareResult();
			}
			m_pSharePlugin->setResultListener(m_pRetListener);
		}
	}
	pluginSetting = (CCDictionary*) dict->objectForKey("iap");
	if(pluginSetting!=NULL){
		m_pIAPPlugin = dynamic_cast<ProtocolIAP*>(PluginManager::getInstance()->loadPlugin(pluginSetting->valueForKey("name")->getCString()));
		if (NULL != m_pIAPPlugin)
		{
			m_pPluginNames->addObject(CCString::create(pluginSetting->valueForKey("name")->getCString()));

			TIAPDeveloperInfo pIAPInfo;
			CCDictionary* configDict = (CCDictionary*) pluginSetting->objectForKey("config");
			CCArray* configKeys = configDict->allKeys();
			CCObject* configKey;
			CCARRAY_FOREACH(configKeys, configKey)
			{
				const char* keyStr = ((CCString*)configKey)->getCString();
				pIAPInfo[keyStr] = configDict->valueForKey(keyStr)->getCString();
			}
			m_pIAPPlugin->setDebugMode(true);
			m_pIAPPlugin->configDeveloperInfo(pIAPInfo);
			if (m_pIAPListener == NULL)
			{
				m_pIAPListener = new MyPayResult();
			}
			m_pIAPPlugin->setResultListener(m_pIAPListener);
		}
	}
	pluginSetting = (CCDictionary*)dict->objectForKey("ads");
	if(pluginSetting!=NULL){
		m_pAds = dynamic_cast<ProtocolAds*>(PluginManager::getInstance()->loadPlugin(pluginSetting->valueForKey("name")->getCString()));
		if(m_pAds){
            TAdsDeveloperInfo devInfo;
            devInfo["AdmobID"] = "a15160fce7c2254";
            m_pAds->configDeveloperInfo(devInfo);
            m_pAds->setDebugMode(false);
			m_pPluginNames->addObject(CCString::create(pluginSetting->valueForKey("name")->getCString()));
		}
	}
}

void MyPlugins::unloadPlugins()
{
	m_pSharePlugin = NULL;
	m_pIAPPlugin = NULL;
	m_pAds = NULL;
	CCObject* pluginName;
	CCARRAY_FOREACH(m_pPluginNames, pluginName)
	{
		PluginManager::getInstance()->unloadPlugin(((CCString*)pluginName)->getCString());
	}
	CC_SAFE_RELEASE_NULL(m_pPluginNames);

}

void MyPlugins::share(const char* sharedText, const char* sharedImagePath)
{
    TShareInfo info;
    info["SharedText"] = sharedText;
    if(sharedImagePath!=NULL)
        info["SharedImagePath"] = sharedImagePath;
	if(m_pSharePlugin!=NULL)
	    m_pSharePlugin->share(info);
}

void MyPlugins::pay(const char* productId)
{
	TProductInfo info;
	info["productName"] = productId;
	char uid[20] = {};
	sprintf(uid, "%d", CCUserDefault::sharedUserDefault()->getIntegerForKey("userId"));
	info["payerId"] = std::string(uid);
	if(m_pIAPPlugin!=NULL)
		m_pIAPPlugin->payForProduct(info);
}

void MyPlugins::sendCmd(const char *cmd, const char *args) {
    CCLog("MyPlugins %s", cmd, args);
	string c(cmd); 
	if(m_pAds != NULL) {  
		  
		if(c == "showAds") {  
			m_pAds->showAds((ProtocolAds::AdsType)0, 0, (ProtocolAds::AdsPos)0);  
		} else if(c == "hideAds") {  
			m_pAds->hideAds((ProtocolAds::AdsType)0); 
		} else if(c == "moregames") {  
            m_pAds->spendPoints(0);  
		} else if(c == "hideMoreGames") {  
			m_pAds->spendPoints(1); 
		} else if(c == "showOffers") {
            m_pAds->spendPoints(2);
        } else if(c == "hideOffers") {
            m_pAds->spendPoints(3);
        } else if(c == "setUid") {
            TAdsDeveloperInfo info;
            info["uid"] = args;
            m_pAds->configDeveloperInfo(info);
        //初始化setPoints
        //获得奖励setpoints
        //消费掉奖励的时候 setPoints
        //通知lua改变金币数量
        //通知java 改变金币数量
        } else if(c == "spendGold") {
            TAdsDeveloperInfo info;
            info["cmd"] = "spendGold";
            info["gold"] = args;
            m_pAds->configDeveloperInfo(info);
        } else if(c == "feedback") {
            m_pAds->spendPoints(3);
        } else if(c == "freeCrystal") {
            m_pAds->spendPoints(4);
        } else if(c == "share") {
            m_pAds->spendPoints(5);
        } else if(c == "showSpot") {
            m_pAds->spendPoints(6);
        //根据设备号得到用户Uid
        } else if(c == "getUsername") {
            m_pAds->spendPoints(7);
        }
	}  
    //win32 测试uid
    #if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) 
    if(c == "getUsername") {
        srand(time(0));
        int uid = rand();
        char str[1000];
        sprintf(str, "%d", uid);
        cocos2d::CCUserDefault::sharedUserDefault()->setStringForKey("username", str); 
        CCUserDefault::sharedUserDefault()->flush();
        CCLog("setUsername %s", str);
    }
    #endif
}

void MyShareResult::onShareResult(ShareResultCode ret, const char* msg)
{
    if(ret == kShareSuccess){
        CCNotificationCenter::sharedNotificationCenter()->postNotification("EVENT_SHARE_SUCCESS");
    }
    else{
        CCNotificationCenter::sharedNotificationCenter()->postNotification("EVENT_SHARE_FAIL");
    }
}

void MyPayResult::onPayResult(PayResultCode ret, const char* msg, TProductInfo info)
{
    if(ret == kPaySuccess){
        CCNotificationCenter::sharedNotificationCenter()->postNotification("EVENT_BUY_SUCCESS");
    }
    else{
        CCNotificationCenter::sharedNotificationCenter()->postNotification("EVENT_BUY_FAIL");
    }
}
