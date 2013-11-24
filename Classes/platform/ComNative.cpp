#include "CCNative.h"
#include "cocos2d.h"
#include <stdlib.h>
using namespace cocos2d;
using namespace std;
float getNow()
{
    struct timeval val;
    //struct timezone zone;
    gettimeofday(&val, NULL);
	return val.tv_sec+val.tv_usec/1000000.0;
}

void writeFile(const char *fname, const char *content, int size) {
    FILE *nf = fopen(fname, "wb");
    fwrite(content, 1, size, nf);
    fclose(nf);
}
string getFileData(const char *fname) {
    unsigned long size;
    unsigned char *con = CCFileUtils::sharedFileUtils()->getFileData(fname, "r", &size);
    string str((char*)con, size);
    //删除返回的文件数据
    delete [] con;
    return str;
}
//复用shader程序
int setGLProgram(CCSprite *sp) {
    CCShaderCache *sc = CCShaderCache::sharedShaderCache();
    CCGLProgram *prog = (CCGLProgram*)sc->programForKey("hsvShader");
    if(prog == NULL) {
        GLchar *fragSource = (GLchar*)CCString::createWithContentsOfFile(CCFileUtils::sharedFileUtils()->fullPathForFilename("myfrag.h").c_str())->getCString();
        GLchar *vertSource = (GLchar*)CCString::createWithContentsOfFile(CCFileUtils::sharedFileUtils()->fullPathForFilename("myvert.h").c_str())->getCString();
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
        sc->addProgram(prog, "hsvShader");
    } else {
        sp->setShaderProgram(prog);
    }
    return (int)glGetUniformLocation(prog->getProgram(), "offset");
}
//每次渲染前需要调用设定offset函数
//shader 不复用那么
void setOffset(CCSprite *sp, float off) {
    MySprite *mp = (MySprite*)sp;
    mp->offset = off;
}
CCSprite *createSprite(char *fn) {
    MySprite *sp = new MySprite();
    sp->initWithFile(fn);
    sp->autorelease();
    sp->offset = 0;
    sp->offUni = setGLProgram(sp);
    return sp;
}

