#ifndef BONE2_H
#define BONE2_H
#include "cocos2d.h"
#include <vector>
using namespace std;
using namespace cocos2d;
class CCSprite3D;
#define MAX_BONE_CHILDREN 4
class Bone {
public:
    kmQuaternion rotate;
    kmVec3 offset;
    float length;
    int child[MAX_BONE_CHILDREN];
    int parent;
    char name[32];
    kmMat4 mat;
    int id;

    void setChild(){
        for(int i=0; i < MAX_BONE_CHILDREN; i++) {
            child[i] = -1;
        }
    }

};

class Keyframe {
public:
    int fnum;
    kmQuaternion rotate;
};


//当前bone的Id
//void setBoneMatrix(Bone *b, Bone **arr, kmMat4*);
void setBoneMatrix(Bone *b, vector<Bone> *arr, kmMat4*);

void setSpriteRotate(Bone *b, CCSprite3D *s);

void printMat4(kmMat4 *mat);
#endif

