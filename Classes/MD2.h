#ifndef __MD2_H__
#define __MD2_H__
#include "cocos2d.h"
#include <vector>
using namespace cocos2d;
using namespace std;
//加载 顶点  纹理坐标 数据到 vector 里面
//传入一个vector 指针
#define MD2_MAGIC_NO    ('I'+('D'<<8)+('P'<<16)+('2'<<24))
#define MAX_NO_SKIN		5
#define MAX_SKIN_NAME	64
#define FRAME_HEADER_SIZE	(sizeof(float)*6+16)

typedef unsigned char	byte;
typedef short*	pshort;

typedef struct _md2Header
{
	int		magic;
	int		version;
	int		skinWidth;
	int		skinHeight;
	int		frameSize;

	int		numSkins;
	int		numVertices;
	int		numTexCoords;
	int		numTriangles;
	int		numGlCommands;
	int		numFrames;

	int		offsetSkins;
	int		offsetTexCoord;
	int		offsetTriangles;
	int		offsetFrames;
	int		offsetGlCommands;
	int		offsetEnd;
}md2Header,*pmd2Header;

typedef struct _md2TriangleVertex
{
	byte	vertex[3];
	byte	lightNormalIndex;
}md2TriangleVertex,*pmd2TriangleVertex;

//6+16 HEADER SIZE
typedef struct _md2Frame
{
	float				scale[3];
	float				translate[3];
	char				name[16];
	//pmd2TriangleVertex	pvertices;
    vector<md2TriangleVertex> pvertices;
}md2Frame,*pmd2Frame;


typedef struct _md2Triangle
{
	short	vertexIndices[3];
	short	textureIndices[3];
}md2Triangle,*pmd2Triangle;

typedef struct _md2TextureCoord
{
	short	s,t;
}md2TextureCoord,*pmd2TextureCoord;

typedef struct _md2GLCommand
{
	float	s,t;
	int		vertexIndex;
}md2GLCommand,*pmd2GLCommand;

typedef struct _md2GLVertex
{
	float	x,y,z;
}md2GLVertex,*pmd2GLVertex;


// 读取模型文件 写入 位置 纹理 一frame 静态动画
void readMD2(vector<float> *pos, vector<float> *tex, vector<unsigned int> *ind, unsigned char *);

#endif
