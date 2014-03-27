#include "SpriteUV.h"

using namespace cocos2d;

SpriteUV::SpriteUV()
{
	
}


SpriteUV::~SpriteUV()
{
	
}

void SpriteUV::setupTexParameters(){

    ccTexParams params = { GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT };
    this->getTexture()->setTexParameters(&params);

}

bool SpriteUV::initWithFile(const char *pszFilename)
{
    if( CCSprite::initWithFile(pszFilename) ) 
    {
        setupTexParameters();
      
        return true;
    }
    
    return false;
}


bool SpriteUV::initWithSpriteFrameName(const char *pszFilename)
{
    if( CCSprite::initWithSpriteFrameName(pszFilename) ) 
    {
        setupTexParameters();
       
        return true;
    }
    
    return false;
}


void SpriteUV::setTextureOffset(cocos2d::CCPoint offset){

    ccV3F_C4B_T2F_Quad quad=this->getQuad();
   
    //change UV coords
    quad.tl.texCoords.u+=offset.x;
    quad.bl.texCoords.u+=offset.x;
    quad.tr.texCoords.u+=offset.x;
    quad.br.texCoords.u+=offset.x;
    
    quad.tl.texCoords.v+=offset.y;
    quad.bl.texCoords.v+=offset.y;
    quad.tr.texCoords.v+=offset.y;
    quad.br.texCoords.v+=offset.y;

    //write quad back
    this->m_sQuad=quad;

}
