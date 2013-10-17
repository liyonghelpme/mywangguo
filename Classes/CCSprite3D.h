#ifndef __CCSPRITE3D_H__
#define __CCSPRITE3D_H__
#include "cocos2d.h"
#include <vector>
//分配的 buffer 大小 由 加载的文件决定 先加载一个8个定点的矩形实验一下
//使用client side array
//第一步 绘制一个矩形
using namespace cocos2d;
using namespace std;
class CCSprite3D : public CCNode { // public CCNodeRGBA, public CCTextureProtocol {
public:
    static CCSprite3D *create();
    CCSprite3D();

    virtual ~CCSprite3D();
    virtual bool init(void);
    
    /*
    //CCTextureProtocol
    virtual CCTexture2D *getTexture(void);
    inline void setBlendFunc(ccBlendFunc blendFunc) {m_sBlendFunc = blendFunc;}
    inline ccBlendFunc getBlendFunc(void) { return m_sBlendFunc; }

    //CCNode
    virtual void setScaleX(float fScaleX);
    virtual void setScaleY(float fScaleY);
    virtual void setPosition(const CCPoint& pos);
    virtual void setRotation(float fRotation);
    virtual void setRotationX(float fRotationX);
    virtual void setRotationY(float fRotationY);
    virtual void setSkewX(float sx);
    virtual void setSkewY(float sy);
    virtual void removeChild(CCNode* pChild, bool bCleanup);
    virtual void removeAllChildrenWithCleanup(bool bCleanup);
    virtual void reorderChild(CCNode *pChild, int zOrder);
    virtual void addChild(CCNode *pChild);
    virtual void addChild(CCNode *pChild, int zOrder);
    virtual void addChild(CCNode *pChild, int zOrder, int tag);
    virtual void sortAllChildren();
    virtual void setScale(float fScale);
    virtual void setVertexZ(float fVertexZ);
    virtual void setAnchorPoint(const CCPoint& anchor);
    virtual void ignoreAnchorPointForPosition(bool value);
    virtual void setVisible(bool bVisible);
    //CCNodeRGBA
    virtual void setColor(const ccColor3B& color3);
    virtual void updateDisplayedColor(const ccColor3B& parentColor);
    virtual void setOpacity(GLubyte opacity);
    virtual void setOpacityModifyRGB(bool modify);
    virtual bool isOpacityModifyRGB(void);
    virtual void updateDisplayedOpacity(GLubyte parentOpacity);

    //Batch 暂时不用
    virtual void updateTransform(void);

    
    //包围盒子 box 


    //dirty SpriteNode 是否脏点
    inline virtual bool isDirty(void) { return m_bDirty; }
    */

    void stdTransform();
    virtual void draw(void);
    virtual void setTexture(CCTexture2D *texture);
    void setTextureRect();
    void initProgram();


    //绕X 轴旋转 按照角度旋转
    // 缩放  平移   旋转
    void rotateX(float x);
    void rotateY(float y);
    void rotateZ(float z);

    void tranX(float x);
    void tranY(float y);
    void tranZ(float z);

    void scaleX(float x);
    void scaleY(float y);
    void scaleZ(float z);
    
    /** 
     * Makes the Sprite to be updated in the Atlas.
     */
    //inline virtual void setDirty(bool bDirty) { m_bDirty = bDirty; }

    //纹理坐标 定点 颜色信息 暂时不用法向量
    //定点数量不定 
    //使用vector 数组可以处理 直接向opengl 发送数据
    //定点坐标使用 char 类型存储数据

    virtual void initModel();


protected:
    ccBlendFunc m_sBlendFunc;
    //CCTexture2D *m_pobTexture;//使用的纹理编号


    vector<float> pos;
    vector<float> tex;
    vector<unsigned char> col;
    vector<unsigned char> index;

    //attribute only for draw in RenderTexture then render sprite in 2d Scene  
    float xRot, yRot, zRot;
    float x, y, z;
    
    float sx, sy, sz;

    GLuint pmat, mvmat, mvpmat;

    CCTexture2D *pTex;

    int vertNum;
};
#endif
