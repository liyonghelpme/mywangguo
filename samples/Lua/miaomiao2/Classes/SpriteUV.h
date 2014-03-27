#ifndef __SpriteUV_H__
#define __SpriteUV_H__

#include "cocos2d.h"

//Sprite class where you can set a texture offset. Helps if you do UV animation on CCSprite's
//by @hermanjakobi, 2013 Jan

//Note:: Might not work with Texture Atlases or fliped sprites yet

class SpriteUV :  public cocos2d::CCSprite
{
    
    void setupTexParameters();
   
public:

	SpriteUV();
	virtual ~SpriteUV();

    // Here's a difference. Method 'init' in cocos2d-x returns bool, instead of returning 'id' in cocos2d-iphone
    virtual bool initWithFile(const char *pszFilename);
    virtual bool initWithSpriteFrameName(const char *framename);
    
    void setTextureOffset(cocos2d::CCPoint offset);
        
    // implement the "static node()" method manually
    CREATE_FUNC(SpriteUV);
};

#endif 
