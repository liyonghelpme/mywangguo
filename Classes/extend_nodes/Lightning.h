#ifndef __LIGHTNING_H__
#define __LIGHTNING_H__
#include "cocos2d.h"
#include "kazmath/vec3.h"
#include "string"
/*
�ο�ʵ�� http://gamedev.tutsplus.com/tutorials/implementation/how-to-generate-shockingly-good-2d-lightning-effects/
������λ�ƶ��������ɴӵ�100,200 ����150,200 ������ͼ�� ��ʼƫ������100 
Lightning *lightning = Lightning::create(NULL, 100, 20.0, 10.0, 20.0);
lightning->midDisplacement(100, 200, 150, 200, 100.0);
this->addChild(lightning);

capacity ����CCSpriteBatchNode �ܹ����ɵ��߶�����
*/
using namespace std;
using namespace cocos2d;
class Lightning;

class Line : public CCSprite
{
public:
    Lightning *lightning;
    kmVec3 a, b;
    static Line *create(const char *fileName, kmVec3 &a, kmVec3 &b, float thickness, float deg, ccColor3B c, kmVec3 &temp, Lightning *lightning);
};

class Lightning : public CCSpriteBatchNode
{
public:
    static Lightning *create(const char *fileImage, unsigned int capacity, float detail, float thickness, float displace);
    ~Lightning();
    void midDisplacement(float x1, float y1, float x2, float y2, float displace);
    void testLine(float x1, float y1, float x2, float y2);
    virtual void draw();
    virtual void update(float delta);

	void setColor(const ccColor3B& color);
	void setFadeOutRate(float rate);

private:

    CCArray *lines;

    float detail; //����ķֶγ���
    float thickness; //����Ĵ�ϸ
    float displace; //����������
    ccColor3B color;
    float alpha;
    float fadeOutRate;

    string fileName;
};
#endif
