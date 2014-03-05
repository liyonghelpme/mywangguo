#include "HelloWorldScene.h"
#include "AppMacros.h"
#include "CCSprite3D.h"
//#include "Bone.h"
#include "MD2.h"
#include "Bone2.h"
#include "math.h"

USING_NS_CC;


CCScene* HelloWorld::scene()
{
    // 'scene' is an autorelease object
    CCScene *scene = CCScene::create();
    
    // 'layer' is an autorelease object
    HelloWorld *layer = HelloWorld::create();

    // add layer as a child to scene
    scene->addChild(layer);

    // return the scene
    return scene;
}

// on "init" you need to initialize your instance
bool HelloWorld::init()
{
    //////////////////////////////
    // 1. super init first
    if ( !CCLayer::init() )
    {
        return false;
    }
    
    CCSize visibleSize = CCDirector::sharedDirector()->getVisibleSize();
    CCPoint origin = CCDirector::sharedDirector()->getVisibleOrigin();

    /////////////////////////////
    // 2. add a menu item with "X" image, which is clicked to quit the program
    //    you may modify it.

    // add a "close" icon to exit the progress. it's an autorelease object
    CCMenuItemImage *pCloseItem = CCMenuItemImage::create(
                                        "CloseNormal.png",
                                        "CloseSelected.png",
                                        this,
                                        menu_selector(HelloWorld::menuCloseCallback));
    
	pCloseItem->setPosition(ccp(origin.x + visibleSize.width - pCloseItem->getContentSize().width/2 ,
                                origin.y + pCloseItem->getContentSize().height/2));

    // create menu, it's an autorelease object
    CCMenu* pMenu = CCMenu::create(pCloseItem, NULL);
    pMenu->setPosition(CCPointZero);
    this->addChild(pMenu, 1);

    /////////////////////////////
    // 3. add your codes below...

    // add a label shows "Hello World"
    // create and initialize a label
    
    CCLabelTTF* pLabel = CCLabelTTF::create("Hello World", "Arial", TITLE_FONT_SIZE);
    
    // position the label on the center of the screen
    pLabel->setPosition(ccp(origin.x + visibleSize.width/2,
                            origin.y + visibleSize.height - pLabel->getContentSize().height));

    // add the label as a child to this layer
    this->addChild(pLabel, 1);

    // add "HelloWorld" splash screen"
    /*
    CCSprite* pSprite = CCSprite::create("HelloWorld.png");

    // position the sprite on the center of the screen
    pSprite->setPosition(ccp(visibleSize.width/2 + origin.x, visibleSize.height/2 + origin.y));

    //pSprite->setRotationY(50);

    // add the sprite as a child to this layer
    this->addChild(pSprite, 0);
    */
    
    /*
    sp = CCSprite::create("HelloWorld.png"); 
    CCSize sz = sp:getContentSize();
    ccBlendFunc bf = {GL_ONE, GL_ZERO};
    sp->setBlendFunc(bf);
    sp->setPosition(ccp(sz.width/2, sz.height/2));
    */
    
    /*
    CCRenderTexture *rt = CCRenderTexture:create(sz.width, sz.height);
    rt->begin();
    sp->visit();
    rt->end();
    CCTexture2D *tex = rt->getSprite()->getTexture();
    GLuint tid = tex->getName();
    */
    /*
    CCSprite3D *m3 = CCSprite3D::create();
    m3->loadMd2("test2.md2");
    m3->setTexture(CCTextureCache::sharedTextureCache()->addImage("test.png"));
    this->addChild(m3, 2);
    m33 = m3;

    m3->tranX(400); 
    m3->tranY(240); 
    m3->tranZ(0);
    
    m3->scaleX(0.5);
    m3->scaleY(0.5);
    m3->scaleZ(0.5);
    m3->rotateX(40); 
    */

    sprintf(b1.name, "b1");
    sprintf(b2.name, "b2");
    
    //骨骼的bind位置 和 朝向
    kmQuaternionIdentity(&b1.rotate); 
    b1.length = 100;
    kmVec3Fill(&b1.offset, 0, 0, 0);
    b1.child[0] = 1;
    b1.child[1] = -1;
    b1.parent = -1;
    kmMat4Identity(&b1.mat);
    b1.id = 0;


    kmQuaternionIdentity(&b2.rotate); 
    b2.length = 100;
    kmVec3Fill(&b2.offset, 0, 0, 0);
    b2.child[0] = -1;
    b2.child[1] = -1;
    b2.parent = 0;
    kmMat4Identity(&b2.mat);
    b2.id = 1;

    allBone[0] = &b1;
    allBone[1] = &b2;

    kmMat4 *m1 = &invBoneMat[0];
    kmMat4Identity(m1);
    /*
    kmMat4 temp;
    kmMat4Translation(&temp, 50, 100, 0);
    kmMat4Multiply(m1, m1, &temp);
    kmMat4Inverse(m1, m1);
    */

    //mesh 绑定的 骨骼的时候 骨骼的逆向变换
    //只有x 方向 平移100
    kmMat4Identity(&invBoneMat[1]);
    /*
    kmMat4 *m2 = &invBoneMat[1];
    kmMat4Translation(m2, 100, 100, 0);
    kmMat4Inverse(m2, m2);
    */

    rb1 = CCSprite3D::create();
    rb1->loadMd2("test2.md2");
    rb1->setTexture(CCTextureCache::sharedTextureCache()->addImage("test.png"));
    this->addChild(rb1, 3);
    rb1->tranX(50);
    rb1->tranY(0);
    rb1->tranZ(0);

    //缩放有问题 首先需要在局部空间进行缩放
    //缩放操作 在 旋转操作之后 作用在世界空间里面了
    //先正则缩放 接着 再旋转 即可
    //缩放发生在本地空间里面
    //矩阵乘积的顺序 旋转 * 缩放 = 先缩放 再旋转 本地空间
    rb1->scaleX(0.5);
    rb1->scaleY(0.2);
    rb1->scaleZ(0.1);

    rb2 = CCSprite3D::create();
    rb2->loadMd2("test2.md2");
    rb2->setTexture(CCTextureCache::sharedTextureCache()->addImage("test.png"));
    this->addChild(rb2, 3);
    //骨骼表示 x 方向平移50 则和骨骼的左边对其了
    rb2->tranX(50);
    rb2->tranY(0);
    rb2->tranZ(0);
    

    //先缩放再 mv 导致平移问题 平移空间有问题
    rb2->scaleX(0.5);
    rb2->scaleY(0.2);
    rb2->scaleZ(0.1);



    //scale 导致 transform 的位置也已经被scale掉了 先平移 再scale 不过平移没有用了 貌似
    //m3->setScale(100);
    //m3->setPosition(ccp(100, 100));
    //m3->rotateX(100);


    ccDirectorProjection p = CCDirector::sharedDirector()->getProjection(); 
    CCLog("Direction %d", p);
    frameNum = 0;


    //Bone *root;
    //root = Bone::create();
    /*
    vector<float> pos, tex;
    vector<unsigned int> ind;
    unsigned long size;
    readMD2(&pos, &tex, &ind, CCFileUtils::sharedFileUtils()->getFileData("test.md2", "rb", &size));
    */



    passTime = 0;

    scheduleUpdate();
    return true;
}

void HelloWorld::update(float diff) {
    //render Success fully use CCReadPixel
    //save as 
    /*
    if(frameNum == 1) {
    } else if(frameNum == 2) {
    }
    frameNum++; 
    m33->rotateY(frameNum);
    */
    //m33->rotateZ(frameNum);
    
    passTime = passTime+diff;
    //第一个个骨骼绕着z 方向旋转
    
    //每s 旋转45角度
    kmVec3 axis;
    kmVec3Fill(&axis, 0, 0, 1);
    kmQuaternionRotationAxis(&b1.rotate, &axis, kmDegreesToRadians(45*passTime));

    //b2 骨骼绕着z轴 上下摆动旋转
    //T = 2
    //kmQuaternionRotationAxis(&b2.rotate, &axis, kmDegreesToRadians(45*passTime));
    kmQuaternionRotationAxis(&b2.rotate, &axis, kmDegreesToRadians(45*sin(kmPI*passTime)));

    kmMat4 curMat;
    kmMat4Identity(&curMat);
    setBoneMatrix(&b1, allBone, &curMat);

    printf("invBone\n");
    printMat4(&invBoneMat[0]);
    kmMat4 boneMat[2];
    for(int i=0; i < 2; i++) {
        kmMat4Multiply(&boneMat[i], &invBoneMat[i], &allBone[i]->mat);
    }
    printf("boneMat\n");
    printMat4(&boneMat[0]);

    //rb1->rotateZ(45*passTime);
    //对于所有顶点进行矩阵计算

    //对于b2 对象 先平移100个x 方向 接着使用骨骼的矩阵
    //平移100

    //kmMat4 temp;
    //kmMat4Translation(&temp, 100, 0, 0);

    printMat4(&invBoneMat[1]);
    printf("boneMat 111\n");
    printMat4(&boneMat[1]);
    kmMat4Assign(&rb1->boneMat, &boneMat[0]);
    kmMat4Assign(&rb2->boneMat, &boneMat[1]);
}

void HelloWorld::menuCloseCallback(CCObject* pSender)
{
    CCDirector::sharedDirector()->end();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    exit(0);
#endif
}
