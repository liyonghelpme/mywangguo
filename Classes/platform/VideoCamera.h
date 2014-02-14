//
//  VideoCamera.h
//  nozomi
//
//  Created by  stc on 13-4-11.
//
//

#ifndef nozomi_VideoCamera_h
#define nozomi_VideoCamera_h
#include "ExtensionMacros.h"

#include "base_nodes/CCNode.h"
#include "cocos2d_ext_const.h"

using namespace cocos2d;

NS_CC_EXT_BEGIN

class VideoCamera : public CCNode{
private:
    //用于具体底层录制
    void *camera;
    
    bool m_bPaused;
    float m_fMaxTime;
    float m_fFrameRate;
    float m_fPassTime;
    float m_fTotalTime;
    
public:
    ~VideoCamera();
    
    virtual void update(float dt);
    
    bool init();
    void startRecord(CCNode *);
    void endRecord();
    
    static VideoCamera* create();
};

NS_CC_EXT_END

#endif
