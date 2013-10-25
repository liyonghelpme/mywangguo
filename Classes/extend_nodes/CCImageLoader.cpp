#include "CCImageLoader.h"
#include "textures/CCTextureCache.h"
#include "sprite_nodes/CCSpriteFrameCache.h"

#include <string.h>

NS_CC_EXT_BEGIN

CCImageLoader::CCImageLoader(void)
: m_uBufferSize(0),
m_uTotalImages(0),
m_uLoadedImages(0)
{
}

CCImageLoader::~CCImageLoader(void)
{
	if(m_uBufferSize>0){
		for(int i=0;i<m_uTotalImages;i++)
		{
			LoadImageItem* item = m_pLoadList+i;
			delete[] item->imageFile;
			if(item->plistFile!=NULL)
			{
				delete[] item->plistFile;
			}
		}
		delete[] m_pLoadList;
	}
}

CCImageLoader* CCImageLoader::create()
{
    CCImageLoader *pobNode = new CCImageLoader();
    if (pobNode && pobNode->init())
    {
        pobNode->autorelease();
        return pobNode;
    }
    CC_SAFE_DELETE(pobNode);
    return NULL;
}

bool CCImageLoader::init()
{
	m_uBufferSize = 100;
	m_pLoadList = new LoadImageItem[100];
	return true;
}

void CCImageLoader::addImage(const char* pszFileName, const char* plistFileName, CCTexture2DPixelFormat format)
{
	LoadImageItem* item = m_pLoadList + (m_uTotalImages++);
	item->imageFile = new char[100];
	strcpy(item->imageFile, pszFileName);
	if(plistFileName!=NULL){
		item->plistFile = new char[100];
		strcpy(item->plistFile, plistFileName);
	}
	else{
		item->plistFile = NULL;
	}
	item->format = format;
}

void CCImageLoader::onEnter()
{
	CCNode::onEnter();
	this->scheduleUpdate();
}

void CCImageLoader::update(float dt)
{
	CCNode::update(dt);
	CCTextureCache* cache = CCTextureCache::sharedTextureCache();
	while(m_uLoadedImages<m_uTotalImages)
	{
		LoadImageItem* item = m_pLoadList+m_uLoadedImages;
		CCTexture2D* texture = cache->textureForKey(item->imageFile);
		if(texture!=NULL)
		{
			m_uLoadedImages++;
			continue;
		}
		//if(strstr(item.imageFile, ".pvr")!=NULL)
		//{
			CCTexture2D::setDefaultAlphaPixelFormat(item->format);
			texture = cache->addImage(item->imageFile);
			CCTexture2D::setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888);
			if(texture!=NULL && item->plistFile!=NULL)
			{
				CCSpriteFrameCache::sharedSpriteFrameCache()->addSpriteFramesWithFile(item->plistFile, texture);
			}
			m_uLoadedImages++;
			return;
		//}
		//else{
		//	cache->addImageAsync(item.imageFile, this, this->update);
		//}
	}
	this->removeFromParentAndCleanup(true);
}

NS_CC_EXT_END