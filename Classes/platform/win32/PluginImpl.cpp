#include "PluginManager.h"
#include "PluginProtocol.h"
#include "ProtocolSocial.h"
#include "ProtocolAds.h"
#include "ProtocolIAP.h"

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

void ProtocolIAP::setResultListener(PayResultListener* pListener)
{
}

void ProtocolIAP::configDeveloperInfo(TIAPDeveloperInfo devInfo){
}

void ProtocolIAP::payForProduct(TIAPDeveloperInfo devInfo){
}

void ProtocolSocial::onShareResult(ShareResultCode ret, const char* msg)
{

}




void ProtocolAds::configDeveloperInfo(TAdsDeveloperInfo devInfo){
}

void ProtocolAds::showAds(AdsType type, int sizeEnum , AdsPos pos) {
}

void ProtocolAds::hideAds(AdsType type){
}

void ProtocolAds::spendPoints(int points) {
}

void ProtocolAds::setAdsListener(AdsListener* pListener) {
}

void ProtocolAds::onAdsResult(AdsResultCode code, const char* msg){
}
void ProtocolAds::onPlayerGetPoints(int points) {
}

ProtocolAds::~ProtocolAds()
{
}


}}
