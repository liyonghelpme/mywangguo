#include "platform/VideoCamera.h"

NS_CC_EXT_BEGIN

VideoCamera::~VideoCamera()
{
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
    //camera = new CameraFile();
	camera = NULL;
    
    scheduleUpdate();
    return true;
}

void VideoCamera::startRecord(CCNode *noUse)
{
    m_bPaused = false;
    m_fTotalTime = 0.0f;
    m_fPassTime = 0.0f;
    //CCSize size = cocos2d::CCDirector::sharedDirector()->getVisibleSize();
    //((CameraFile*)camera)->startWork((int)size.width, (int)size.height);
}

void VideoCamera::endRecord()
{
    m_bPaused = true;
    //((CameraFile*)camera)->stopWork();
}

void VideoCamera::update(float dt)
{
    if(!m_bPaused){
        if(m_fTotalTime < m_fMaxTime){
            m_fTotalTime += dt;
            m_fPassTime += dt;
            if(m_fPassTime > m_fFrameRate){
                m_fPassTime -= m_fFrameRate;
                //((CameraFile*)camera)->compressFrame();
            }
        }
    }
}
NS_CC_EXT_END