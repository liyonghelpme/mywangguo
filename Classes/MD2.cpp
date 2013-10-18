#include "MD2.h"
#include "string.h"
#include <map>

//vi * 10000 + ti 
static map<int, int> vItI;
static int maxIndex;

static unsigned char *fileCon;
static md2Header header;

static int md2ReadHeader(unsigned char *con, md2Header *header) {
    memcpy(header, con, sizeof(*header));
    if(header->magic != MD2_MAGIC_NO)
        return 1;
    return 0;
}

//triangle face  vertexIndex textureIndex 
static vector<md2Triangle> triData;
//vertex index light normal index 自己计算法向量 不要这个了
static vector<md2TriangleVertex> vertData;

//scale translate name vertices 每frame的 缩放 平移 和 定点
static vector<md2Frame> frameData;

static vector<md2TextureCoord> texData;

//初始化一些临时空间 放置数据
void md2InitData(md2Header *header){
    //texData  vector tex
    //triData  vector 
    //数据frame 数量 每frame 都有定点位置 数据 index --->pos
    /*
    for(int index=0; index<header->numFrames; index++) {
        
    }
    */
}
//纹理名称 
void md2LoadSkinNames() {

}
void dumpTextureCoord() {
    CCLog("%d %d", header.skinWidth, header.skinHeight);
    for(int i = 0; i < header.numTexCoords; i++) {
        CCLog("%d %d", texData[i].s, texData[i].t);
    }
}
void md2LoadTextureCoord() {
    CCLog("loadTextureCoord %d %d", header.offsetTexCoord, header.numTexCoords);
    //int index = 0;
    byte *buf_t = fileCon+header.offsetTexCoord;
    long totalNum = header.numTexCoords;
    texData.resize(totalNum);
    memcpy(&texData[0], buf_t, totalNum*sizeof(md2TextureCoord));
}
void dumpTriangles() {
    for(int i = 0; i < header.numTriangles; i++) {
        CCLog("%d %d %d", triData[i].vertexIndices[0], triData[i].vertexIndices[1], triData[i].vertexIndices[2] );
        CCLog("%d %d %d", triData[i].textureIndices[0], triData[i].textureIndices[1], triData[i].textureIndices[2]);
    }
}
//vert index
void md2LoadTriangles() {
    CCLog("loadTriangles  %d %d ", header.offsetTriangles, header.numTriangles);
    byte *buf_t = fileCon+header.offsetTriangles;
    long totalNum = header.numTriangles;
    triData.resize(totalNum);
    memcpy(&triData[0], buf_t, totalNum*sizeof(md2Triangle));
}

void dumpFrames() {
    for(int i = 0; i < header.numFrames; i++) {
        for(int j = 0; j < header.numVertices; j++) {
            CCLog("%d %d %d", frameData[i].pvertices[j].vertex[0], frameData[i].pvertices[j].vertex[1], frameData[i].pvertices[j].vertex[2]);
        }
    }
}
void md2LoadFrames() {
    CCLog("loadFrames %d %d", header.offsetFrames, header.numFrames);
    int index = 0;
    byte *buf_t = fileCon+header.offsetFrames;
    //long frameheaderSize = header.numFrames*sizeof(md2Frame);
    long frameVertSize = header.numVertices*sizeof(md2TriangleVertex);
    frameData.resize(header.numFrames);
    for(index = 0; index < header.numFrames; index++) {
        frameData[index].pvertices.resize(header.numVertices);
    }
    for(index = 0; index < header.numFrames; index++) {
        memcpy(&(frameData[index]), buf_t, FRAME_HEADER_SIZE);
        buf_t += FRAME_HEADER_SIZE;
        memcpy(&(frameData[index].pvertices[0]), buf_t, frameVertSize);
        buf_t += frameVertSize;
    }
}
void md2LoadGLCommands() {
}

void md2LoadData(md2Header *header) {
    md2LoadSkinNames();
    
    md2LoadTextureCoord();
    dumpTextureCoord();
    
    md2LoadTriangles();
    dumpTriangles();

    md2LoadFrames();
    dumpFrames();

    md2LoadGLCommands();
}

//put 0 frame data into pos with frame scale and translation
//put texData into tex
//put triangle data into ind
void md2ProcessData(vector<float> *pos, vector<float> *tex, vector<unsigned int> *ind) {
    if(header.numFrames > 0) {
        pos->clear();
        tex->clear();
        //pos->resize(header.numVertices*3);
        //tex->resize(header.numTexCoords*2);
        //判断 定点 和 纹理 索引的组合 如果是新的组合 则 生成一个 新的顶点 和 新的 纹理坐标
        ind->resize(header.numTriangles*3);
        for(int i = 0; i < header.numTriangles; i++) {
            int vti;
            vti = triData[i].vertexIndices[0]*10000+triData[i].textureIndices[0];
            int curIndex;
            if(vItI.count(vti) == 0) {
                curIndex = maxIndex;
                vItI[vti] = curIndex;

                int pi = triData[i].vertexIndices[0];
                float px = frameData[0].pvertices[pi].vertex[0]*frameData[0].scale[0]+frameData[0].translate[0];
                float py = frameData[0].pvertices[pi].vertex[1]*frameData[0].scale[1]+frameData[0].translate[1];
                float pz = frameData[0].pvertices[pi].vertex[2]*frameData[0].scale[2]+frameData[0].translate[2];
                pos->push_back(px);
                pos->push_back(py);
                pos->push_back(pz);

                int ti = triData[i].textureIndices[0];
                float ts = texData[ti].s/header.skinWidth;
                float tt = texData[ti].t/header.skinHeight;
                tex->push_back(ts); 
                tex->push_back(tt); 

                maxIndex++;
            } else {
                curIndex = vItI[vti];
            }

            (*ind)[i*3+0] = curIndex;

            vti = triData[i].vertexIndices[1]*10000+triData[i].textureIndices[1];
            if(vItI.count(vti) == 0) {
                curIndex = maxIndex;
                vItI[vti] = curIndex;

                int pi = triData[i].vertexIndices[1];
                float px = frameData[0].pvertices[pi].vertex[0]*frameData[0].scale[0]+frameData[0].translate[0];
                float py = frameData[0].pvertices[pi].vertex[1]*frameData[0].scale[1]+frameData[0].translate[1];
                float pz = frameData[0].pvertices[pi].vertex[2]*frameData[0].scale[2]+frameData[0].translate[2];
                pos->push_back(px);
                pos->push_back(py);
                pos->push_back(pz);

                int ti = triData[i].textureIndices[1];
                float ts = texData[ti].s/header.skinWidth;
                float tt = texData[ti].t/header.skinHeight;
                tex->push_back(ts); 
                tex->push_back(tt); 

                maxIndex++;
            } else {
                curIndex = vItI[vti];
            }
            (*ind)[i*3+1] = curIndex;

            vti = triData[i].vertexIndices[2]*10000+triData[i].textureIndices[2];
            if(vItI.count(vti) == 0) {
                curIndex = maxIndex;
                vItI[vti] = curIndex;

                int pi = triData[i].vertexIndices[2];
                float px = frameData[0].pvertices[pi].vertex[0]*frameData[0].scale[0]+frameData[0].translate[0];
                float py = frameData[0].pvertices[pi].vertex[1]*frameData[0].scale[1]+frameData[0].translate[1];
                float pz = frameData[0].pvertices[pi].vertex[2]*frameData[0].scale[2]+frameData[0].translate[2];
                pos->push_back(px);
                pos->push_back(py);
                pos->push_back(pz);

                int ti = triData[i].textureIndices[2];
                float ts = texData[ti].s/header.skinWidth;
                float tt = texData[ti].t/header.skinHeight;
                tex->push_back(ts); 
                tex->push_back(tt); 

                maxIndex++;
            } else {
                curIndex = vItI[vti];
            }

            (*ind)[i*3+2] = curIndex;
        }

        /*
        int vNum = head.numVertices;
        //different Frame use different pos data
        for(int i = 0; i < vNum; i++) {
            (*pos)[i*3+0] = frameData[0].pvertices[i].vertex[0]*frameData[0].scale[0]+frameData[0].translate[0];
            (*pos)[i*3+1] = frameData[0].pvertices[i].vertex[1]*frameData[0].scale[1]+frameData[0].translate[1];
            (*pos)[i*3+2] = frameData[0].pvertices[i].vertex[2]*frameData[0].scale[2]+frameData[0].translate[2];
        }
        
        tex->resize(head.numTexCoords*2);
        for(int i = 0; i < head.numTexCoords; i++) {
            (*tex)[i*2+0] = texData[i].s/header.skinWidth;
            (*tex)[i*2+1] = texData[i].t/header.skinHeight;
        }
        */

    }
}
static void dumpHeader() {
    CCLog("magic    %d", header.magic);
    CCLog("version  %d", header.version);
    CCLog("skinWidth    %d", header.skinWidth);
    CCLog("skinHeight   %d", header.skinHeight);
    CCLog("frameSize    %d", header.frameSize);
    CCLog("numSkins %d", header.numSkins);
    CCLog("numVertices  %d", header.numVertices);
    CCLog("numTexCoords %d", header.numTexCoords);
    CCLog("numTriangles %d", header.numTriangles);
    CCLog("numGl    %d", header.numGlCommands);
    CCLog("numFrames    %d", header.numFrames);
    CCLog("offsetSkins  %d", header.offsetSkins);
    CCLog("offsetTexCoord   %d", header.offsetTexCoord);
    CCLog("offsetTriangles  %d", header.offsetTriangles);
    CCLog("offsetFrames %d", header.offsetFrames);
    CCLog("offsetGlCommands %d", header.offsetGlCommands);
    CCLog("offsetEnd    %d", header.offsetEnd);
}

void readMD2(vector<float> *pos, vector<float> *tex, vector<unsigned int> *ind, unsigned char *con) {
    vItI.clear();
    maxIndex = 0;

    fileCon = con;
    CCLog("before load");
    int res = md2ReadHeader(con, &header);
    dumpHeader();

    md2InitData(&header);
    md2LoadData(&header);
    md2ProcessData(pos, tex, ind);

    CCLog("finish load md2");
}

