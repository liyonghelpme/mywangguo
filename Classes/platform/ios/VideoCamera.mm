//
//  VideoCamera.mm
//  nozomi
//
//  Created by  stc on 13-4-11.
//
//

#include "VideoCamera.h"
#include "CameraFile.h"
#include "CCDirector.h"
#include "misc_nodes/CCRenderTexture.h"

NS_CC_EXT_BEGIN

VideoCamera::~VideoCamera()
{
    //when call savedToCamera remove camera
    if (camera!=NULL) {
        //delete (CameraFile*)camera;
    }
}

VideoCamera* VideoCamera::create()
{
    VideoCamera* pRet = new VideoCamera();
    pRet->init();
    pRet->autorelease();
    return pRet;
}

bool VideoCamera::init()
{
    m_bPaused = true;
    m_fMaxTime = 1000.0f;
    m_fFrameRate = 1.0f/25;
    camera = new CameraFile();
    
    scheduleUpdate();
    return true;
}

void VideoCamera::startRecord(CCNode *showScene)
{
    CCDirector *director = CCDirector::sharedDirector();
    CCRenderTexture *render = CCRenderTexture::create(director->getWinSizeInPixels().width, director->getWinSizeInPixels().height, kTexture2DPixelFormat_RGBA8888);
    render->beginWithClear(0, 0, 0, 0, 0);
    this->getParent()->visit();
    render->end();
    
    CCSprite *ns = CCSprite::createWithTexture(render->getSprite()->getTexture());
    ns->setFlipY(true);
    ns->setAnchorPoint(CCPointMake(0, 0));
    showScene->addChild(ns, -1);
    
    director->setRenderLayer(this->getParent());
    director->setShowLayer(showScene);
    
    m_bPaused = false;
    m_fTotalTime = 0.0f;
    m_fPassTime = 0.0f;
    //视频的大小 和 屏幕的大小不同
    //根据传入的屏幕大小 来 调整视频的比例
    CCSize size = cocos2d::CCDirector::sharedDirector()->getVisibleSize();
    ((CameraFile*)camera)->startWork((int)size.width, (int)size.height);
}

void VideoCamera::endRecord()
{
    m_bPaused = true;
    ((CameraFile*)camera)->stopWork();
}

void VideoCamera::update(float dt)
{
    if(!m_bPaused){
        if(m_fTotalTime < m_fMaxTime){
            m_fTotalTime += dt;
            m_fPassTime += dt;
            if(m_fPassTime > m_fFrameRate){
                m_fPassTime -= m_fFrameRate;
                ((CameraFile*)camera)->compressFrame();
            }
        }
    }
}

NS_CC_EXT_END