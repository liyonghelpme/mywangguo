#ifndef	__CAESARS_NODE_CCIMAGELOADER_H__
#define __CAESARS_NODE_CCIMAGELOADER_H__

#include "cocos2d_ext_const.h"
#include "base_nodes/CCNode.h"
#include "textures/CCTexture2D.h"

NS_CC_EXT_BEGIN

typedef struct
{
	char* imageFile;
	char* plistFile;
	CCTexture2DPixelFormat format;
} LoadImageItem;

class CCImageLoader: public CCNode
{
private:
	LoadImageItem* m_pLoadList;
	unsigned int m_uBufferSize;
	unsigned int m_uTotalImages;
	unsigned int m_uLoadedImages;
public:
	static CCImageLoader* create();
public:
	CCImageLoader();
	~CCImageLoader();

	bool init();
	void addImage(const char* pszFileName, const char* plistFileName, CCTexture2DPixelFormat format);

	virtual void onEnter();
	virtual void update(float diff);
};

NS_CC_EXT_END

#endif //__CAESARS_NODE_CCIMAGELOADER_H__