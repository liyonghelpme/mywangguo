#include "HelloWorldScene.h"
#include "AppMacros.h"
#include "CCSprite3D.h"
//#include "Bone.h"
#include "MD2.h"
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
    CCSprite* pSprite = CCSprite::create("HelloWorld.png");

    // position the sprite on the center of the screen
    pSprite->setPosition(ccp(visibleSize.width/2 + origin.x, visibleSize.height/2 + origin.y));

    //pSprite->setRotationY(50);

    // add the sprite as a child to this layer
    this->addChild(pSprite, 0);
    
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
    CCSprite3D *m3 = CCSprite3D::create();
    this->addChild(m3, 2);
    m33 = m3;

    //scale 导致 transform 的位置也已经被scale掉了 先平移 再scale 不过平移没有用了 貌似
    //m3->setScale(100);
    //m3->setPosition(ccp(100, 100));
    //m3->rotateX(100);
    m3->tranX(400); 
    m3->tranY(240); 
    m3->tranZ(-400);
    m3->scaleX(200);
    m3->scaleY(200);
    m3->scaleZ(200);
    //m3->rotateX(135); 
    //m3->rotateY(-45); 

    ccDirectorProjection p = CCDirector::sharedDirector()->getProjection(); 
    CCLog("Direction %d", p);
    frameNum = 0;


    //Bone *root;
    //root = Bone::create();
    vector<float> pos, tex;
    vector<unsigned int> ind;
    unsigned long size;
    readMD2(&pos, &tex, &ind, CCFileUtils::sharedFileUtils()->getFileData("test.md2", "rb", &size));
    scheduleUpdate();
    return true;
}

void HelloWorld::update(float diff) {
    //render Success fully use CCReadPixel
    //save as 
    if(frameNum == 1) {
    } else if(frameNum == 2) {
    }
    frameNum++; 
    m33->rotateY(frameNum);
}

void HelloWorld::menuCloseCallback(CCObject* pSender)
{
    CCDirector::sharedDirector()->end();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    exit(0);
#endif
}
