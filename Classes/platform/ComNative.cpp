#include "CCNative.h"
#include "cocos2d.h"
#include <stdlib.h>
using namespace cocos2d;
using namespace std;


void setScriptTouchPriority(CCLayer *lay, int pri){
    CCLog("setScriptTouchPriority %d", pri);
    CCTouchScriptHandlerEntry *st = lay->getScriptTouchHandlerEntry();
    st->setPriority(pri);
    CCLog("priority %d %d", st->getPriority(), st->getSwallowsTouches());
    /*
    lay->retain();
    CCNode *par = lay->getParent();
    lay->removeFromParent();
    par->addChild(lay);
    lay->release();
    */
    lay->setTouchPriority(pri);
}

string getFileData(const char *fname) {
    unsigned long size;
    unsigned char *con = CCFileUtils::sharedFileUtils()->getFileData(fname, "r", &size);
    string str((char*)con, size);
    //删除返回的文件数据
    delete [] con;
    return str;
}
void pauseAction(CCNode *n) {
    
}

void setTextureRect(CCSprite *sp, CCRect rect, bool rotated, CCSize size) {
    sp->setTextureRect(rect, rotated, size);
}
void enableShadow(CCLabelTTF *lab, CCSize sz, float so, float sb, bool up, int r, int g, int b) {
    CCLog("enableShadow %d %d %d", r, g, b);
    lab->enableShadow(sz, so, sb, up);//, r, g, b
}
void setFontFillColor(CCLabelTTF *lab, ccColor3B c, bool u) {
    lab->setFontFillColor(c, u);
}

int setGLProgram(CCSprite *sp) {
    CCShaderCache *sc = CCShaderCache::sharedShaderCache();
    CCGLProgram *prog = (CCGLProgram*)sc->programForKey("waveGrass");
    if(prog == NULL) {
        GLchar *fragSource = (GLchar*)CCString::createWithContentsOfFile(CCFileUtils::sharedFileUtils()->fullPathForFilename("Frag.h").c_str())->getCString();
        GLchar *vertSource = (GLchar*)CCString::createWithContentsOfFile(CCFileUtils::sharedFileUtils()->fullPathForFilename("Vert.h").c_str())->getCString();
        CCLog("Frag File");
        //CCLog("%s", fragSource);
        CCLog("Vert File");
        //CCLog("%s", vertSource);

        prog = new CCGLProgram();
        prog->initWithVertexShaderByteArray(vertSource, fragSource);
        sp->setShaderProgram(prog);
        prog->release();

        CHECK_GL_ERROR_DEBUG();
        prog->addAttribute(kCCAttributeNamePosition, kCCVertexAttrib_Position);
        prog->addAttribute(kCCAttributeNameColor, kCCVertexAttrib_Color);
        prog->addAttribute(kCCAttributeNameTexCoord, kCCVertexAttrib_TexCoords);
        CHECK_GL_ERROR_DEBUG();

        prog->link();
        CHECK_GL_ERROR_DEBUG();
        prog->updateUniforms();
        CHECK_GL_ERROR_DEBUG();
        sc->addProgram(prog, "waveGrass");
    } else {
        sp->setShaderProgram(prog);
    }
    //return (int)glGetUniformLocation(prog->getProgram(), "offset");
    return 0;
}
