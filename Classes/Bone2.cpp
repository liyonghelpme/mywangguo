#include "Bone2.h"
//根据骨骼的rotate值 设定当前定点的矩阵
void setSpriteRotate(Bone *b, CCSprite3D *s){

}

void printMat4(kmMat4 *mat) {
    printf("matf\n");
    for(int i = 0; i < 4; i++) {
        for(int j=0; j < 4; j++) {
            printf("%f ", mat->mat[i+j*4]);
        }
        printf("\n");
    }

}
//当前骨骼的矩阵
void setBoneMatrix(Bone *root, Bone **allBone, kmMat4 *curMat) {
    kmMat4 rot;
    printf("boneId %d\n", root->id);
    kmMat4RotationQuaternion(&rot, &root->rotate);
    kmMat4Multiply(&root->mat, curMat, &rot);
    printMat4(&root->mat);
    
    kmMat4 nextCur;
    kmMat4 temp;
    kmMat4Translation(&temp, root->length, 0, 0);
    //先旋转还是先平移的问题
    //先在自身空间 旋转角度 接着 平移到目标位置  在local 空间的变换
    
    //这个表达式 绕着世界坐标 先平移到x 轴方向接着 整个旋转
    //invBoneMat[1] Identity 了 之后 则CCSprite3D 自身不用平移 只需要跟着骨骼一起平移即可
    //CCSprite3D 如果平移了 100 则 需要 调整invBoneMat 让将平移变换回去
    kmMat4Multiply(&nextCur, &root->mat, &temp);
    //kmMat4Assign(&nextCur, &temp);
    
    printf("nextCur\n");
    printMat4(&nextCur);

    for(int i=0; i<MAX_BONE_CHILDREN; i++) {
        if(root->child[i] == -1) {
            break;
        }
        Bone *b = allBone[root->child[i]];
        setBoneMatrix(b, allBone, &nextCur);
    }
}
