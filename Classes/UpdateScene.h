#ifndef __UPDATE_SCENE_H__
#define __UPDATE_SCENE_H__
#include "cocos2d.h"
#include "AppDelegate.h"
using namespace cocos2d;

class UpdateScene : public CCScene  {
public:
    static UpdateScene *create(AppDelegate*);
    bool init();
    void update(float);
    bool updateYet;
    /*
    virtual void onProgress(int parent);
    virtual void onError(AssetsManager::ErrorCode errorCode);
    virtual void onSuccess();
    */
private:
    AppDelegate *ap;
};
#endif
