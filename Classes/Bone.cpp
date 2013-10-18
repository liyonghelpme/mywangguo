#include "Bone.h"
Bone *Bone::create() {
    Bone *pb = new Bone();
    if(pb && pb->init()) {
        pb->autorelease();
        return 
    }
    CC_SAFE_DELETE(pb);
    return NULL;
}
Bone::Bone() {
    
}
bool Bone::init() {
    if(CCSprite3D::init()) {
        a = b = c = 0;        
        return true;
    }
    return false;
}
void Bone::initModel() {
    
}

void Bone::draw() {
    
}

void Bone::addChild(Bone *b) {
    CCNode::addChild(b);    
}


void Bone::loadBone(char *b) {
    
}

void dumpTree(Bone *root, int level) {
    if(!root)
        return;
    for(int i=0; i<level; i++) {
        printf("#");
    }
    printf(" %4.4f %4.4f %4.4f %4.4f %4.4f %4.4f %4.4f %d %s\n", root->x, root->y, root->z,
               root->a, root->b, root->c, root->l, root->flags, root->name);
    CCArray *arr = root->getChildren();
    int n = arr->getChildrenCount();
    for(int i=0; i<n; i++) {
        Bone *temp = (Bone *)arr->objectAtIndex(i);
        dumpTree(temp, level+1);
    }
}

