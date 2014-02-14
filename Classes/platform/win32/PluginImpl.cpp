#include "PluginManager.h"
#include "PluginProtocol.h"
#include "ProtocolSocial.h"
#include "ProtocolIAP.h"
#include "ProtocolAds.h"

/* add this EMPTY implement to keep the codes the same in both win32 and movable-platform */
/* The plugins wasn't active in win32 */

namespace cocos2d { namespace plugin {

PluginManager* m_instance=NULL;
PluginManager::~PluginManager(){}

PluginManager* PluginManager::getInstance(){
	if(m_instance==NULL){
		m_instance = new PluginManager();
	}
	return m_instance;
}

void PluginManager::end(){}
    
PluginProtocol* PluginManager::loadPlugin(const char* name){ return NULL;}

void PluginManager::unloadPlugin(const char* name){}

PluginManager::PluginManager(void){}

PluginProtocol::~PluginProtocol()
{
}

void PluginProtocol::setDebugMode(bool isDebugMode)
{
}

ProtocolSocial::~ProtocolSocial()
{
}

void ProtocolSocial::configDeveloperInfo(TSocialDeveloperInfo devInfo)
{
}

void ProtocolSocial::share(TShareInfo info)
{
}

void ProtocolSocial::setResultListener(ShareResultListener* pListener)
{
}

void ProtocolSocial::onShareResult(ShareResultCode ret, const char* msg)
{
}

void ProtocolIAP::setResultListener(PayResultListener* pListener)
{
}

void ProtocolIAP::configDeveloperInfo(TIAPDeveloperInfo devInfo)
{
}

void ProtocolIAP::payForProduct(TProductInfo info)
{
}
void ProtocolAds::configDeveloperInfo(TAdsDeveloperInfo devInfo){
}
void ProtocolAds::showAds(AdsType type, int sizeEnum, AdsPos pos){
}
void ProtocolAds::hideAds(AdsType type){}

    /**
    @brief Spend the points.
           Use this method to notify server spend points.
    @param points Need spend number of points
    */
    void ProtocolAds::spendPoints(int points){
	}

    /**
     @brief set the Ads listener
    */
	void ProtocolAds::setAdsListener(AdsListener* pListener){}

    // For the callbak methods
	void ProtocolAds::onAdsResult(AdsResultCode code, const char* msg){}
	void ProtocolAds::onPlayerGetPoints(int points){}
}}