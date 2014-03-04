#include "Bone2.h"
//根据骨骼的rotate值 设定当前定点的矩阵
void setSpriteRotate(Bone *b, CCSprite3D *s){

}

//当前骨骼的矩阵
void setBoneMatrix(Bone *root, Bone **allBone, kmMat4 *curMat) {
    kmMat4 rot;
    kmMat4RotationQuaternion(&rot, &root->rotate);
    kmMat4Multiply(&root->mat, curMat, &rot);
    
    kmMat4 nextCur;
    kmMat4 temp;
    kmMat4Translation(&temp, root->length, 0, 0);
    kmMat4Multiply(&nextCur, &root->mat, &temp);

    for(int i=0; i<MAX_BONE_CHILDREN; i++) {
        if(root->child[i] == -1) {
            break;
        }
        Bone *b = allBone[root->child[i]];
        setBoneMatrix(b, allBone, &nextCur);
    }
}
