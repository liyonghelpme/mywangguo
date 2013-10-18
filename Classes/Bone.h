#ifndef __BONE_H__
#define __BONE_H__
#include "cocos2d.h"
using namespace cocos2d;

class Bone : public CCSprite3D {
public:
    char name[20];

    static Bone *create();
    Bone();
    virtual bool init();

    virtual void draw();

    //bone id parent = -1  root 
    int id; 

    unsigned char flags;
    
    //addChild  another bound
    virtual void addChild(Bone *);

    //dumpTree  this is root
    //void dumpTree();


    //line equation
    //x = x0+at y = y0+bt z = z0+ct angel
    float a, b, c;
    
    //length
    float l;

    virtual void initModel();
};

void dumpTree(Bone *root, int level);
Bone *loadBone(char *);
#endif
