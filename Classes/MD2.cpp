#include "MD2.h"
#include "string.h"
#include <map>

//MD2 模型有scale 比例缩放尺寸了


//vi * 10000 + ti 
static map<int, int> vItI;
static int maxIndex;

//新的顶点索引对应的旧的顶点索引
//用于将 顶点数据 写入到 pos里面
//0---> maxIndex-1
static map<int, int> newVI2Old;


static unsigned char *fileCon;
static md2Header header;
static float stdScale = 10;

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

static vector<float> normalData;

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
        CCLog("vert index %d %d %d", triData[i].vertexIndices[0], triData[i].vertexIndices[1], triData[i].vertexIndices[2] );
        CCLog("tex index %d %d %d", triData[i].textureIndices[0], triData[i].textureIndices[1], triData[i].textureIndices[2]);
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

static void dumpFrames() {
    for(int i = 0; i < header.numFrames; i++) {
        CCLog("frameData %f %f %f", frameData[i].scale[0], frameData[i].scale[1], frameData[i].scale[2]);
        CCLog("frameData %f %f %f", frameData[i].translate[0], frameData[i].translate[1], frameData[i].translate[2]);
        for(int j = 0; j < header.numVertices; j++) {
            CCLog("%d %d %d", frameData[i].pvertices[j].vertex[0], frameData[i].pvertices[j].vertex[1], frameData[i].pvertices[j].vertex[2]);
        }
    }
}
static void md2LoadFrames() {
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
static void md2LoadGLCommands() {
}

static void md2LoadData(md2Header *header) {
    md2LoadSkinNames();
    
    md2LoadTextureCoord();
    dumpTextureCoord();
    
    md2LoadTriangles();
    dumpTriangles();

    md2LoadFrames();
    dumpFrames();

    md2LoadGLCommands();
}

static void dumpPosAndTex(vector<float> *pos, vector<float> *tex, vector<unsigned int> *ind, vector< vector<float> > *animations, vector<float> *normal) {
    CCLog("Pos %d", pos->size());
    for(int i = 0; i < pos->size()/3; i++) {
        CCLog("%f %f %f", (*pos)[i*3+0], (*pos)[i*3+1], (*pos)[i*3+2]);
    }
    CCLog("texCoord %d", tex->size());
    for(int i = 0; i < tex->size()/2; i++) {
        CCLog("%f %f", (*tex)[i*2+0], (*tex)[i*2+1]);
    }
    
    CCLog("ind %d", ind->size());
    for(int i = 0; i < ind->size(); i++) {
        CCLog("%d", (*ind)[i]);
    }
    CCLog("animations %d", animations->size());
    for(int i = 0; i < animations->size(); i++) {
        for(int j = 0; j < ((*animations)[i]).size()/3; j++) {
            CCLog("%f %f %f", ((*animations)[i])[j*3+0], ((*animations)[i])[j*3+1], ((*animations)[i])[j*3+2] );
        }
    }
    CCLog("normal %d", normal->size()/3);
    for(int i = 0; i < normal->size()/3; i++) {
        CCLog("%f %f %f", (*normal)[i*3+0], (*normal)[i*3+1], (*normal)[i*3+2]);
    }
}
//put 0 frame data into pos with frame scale and translation
//put texData into tex
//put triangle data into ind

//-1000 1000 的范围 显示的话 将 比例缩放一下 未 100 * 100 的比例尺即可
static void md2ProcessData(vector<float> *pos, vector<float> *tex, vector<unsigned int> *ind, vector< vector<float> >*animations, vector<float> *normal ) {
    if(header.numFrames > 0) {
        pos->clear();
        tex->clear();
        //pos->resize(header.numVertices*3);
        //tex->resize(header.numTexCoords*2);
        //判断 定点 和 纹理 索引的组合 如果是新的组合 则 生成一个 新的顶点 和 新的 纹理坐标
        ind->resize(header.numTriangles*3);
        float maxx, maxy, maxz, minx, miny, minz;
        maxx = maxy = maxz = -9999999;
        minx = miny = minz = 9999999;
        //scale to 100*100 
        // three point 
        //each vertex 
        //normal->resize(header.numTriangles);
        //3*numTriangles for point and texCoord
        
        //faceNum * 3 point * 3 coordinate
        //normal->resize(header.numTriangles*3*3);
        normal->clear();
        kmVec3 p1, p2, p3;

        //p2 - p1
        //p3 - p1
        //cross
        //frameData point for triangles frame 0
        //scale x y z don't change normal direction
        //model view matrix change 
        for(int i = 0; i < header.numTriangles; i++) {
            //int vti;
            //vti = triData[i].vertexIndices[0]*10000+triData[i].textureIndices[0];
            int curIndex;
            int pi;
            float px, py, pz, ts, tt;
            int ti;
            //face * 3 = ver num

            //if(vItI.count(vti) == 0) {
                curIndex = maxIndex;
            //    vItI[vti] = curIndex;
                
                pi = triData[i].vertexIndices[0];

                px = (frameData[0].pvertices[pi].vertex[0]*frameData[0].scale[0]+frameData[0].translate[0]);
                py = (frameData[0].pvertices[pi].vertex[1]*frameData[0].scale[1]+frameData[0].translate[1]);
                pz = (frameData[0].pvertices[pi].vertex[2]*frameData[0].scale[2]+frameData[0].translate[2]);
                maxx = std::max(maxx, px);
                maxy = std::max(maxy, py);
                maxz = std::max(maxz, pz);
                minx = std::min(minx, px);
                miny = std::min(miny, py);
                minz = std::min(minz, pz);
                /*
                pos->push_back(px);
                pos->push_back(py);
                pos->push_back(pz);
                */
                newVI2Old[curIndex] = pi;

                ti = triData[i].textureIndices[0];
                ts = (float)(texData[ti].s)/header.skinWidth;
                tt = (float)(texData[ti].t)/header.skinHeight;
                tex->push_back(ts); 
                tex->push_back(tt); 
                
                kmVec3Fill(&p1, px, py, pz);
                maxIndex++;
            //} else {
            //    curIndex = vItI[vti];
            //}

            (*ind)[i*3+0] = curIndex;

            //vti = triData[i].vertexIndices[1]*10000+triData[i].textureIndices[1];
            //if(vItI.count(vti) == 0) {
                curIndex = maxIndex;
                //vItI[vti] = curIndex;

                pi = triData[i].vertexIndices[1];
                px = (frameData[0].pvertices[pi].vertex[0]*frameData[0].scale[0]+frameData[0].translate[0]);
                py = (frameData[0].pvertices[pi].vertex[1]*frameData[0].scale[1]+frameData[0].translate[1]);
                pz = (frameData[0].pvertices[pi].vertex[2]*frameData[0].scale[2]+frameData[0].translate[2]);
                /*
                pos->push_back(px);
                pos->push_back(py);
                pos->push_back(pz);
                */
                newVI2Old[curIndex] = pi;
                ti = triData[i].textureIndices[1];
                ts = ((float)texData[ti].s)/header.skinWidth;
                tt = ((float)texData[ti].t)/header.skinHeight;
                tex->push_back(ts); 
                tex->push_back(tt); 
                
                kmVec3Fill(&p2, px, py, pz);
                maxIndex++;
            //} else {
            //    curIndex = vItI[vti];
            //}
            (*ind)[i*3+1] = curIndex;

            //vti = triData[i].vertexIndices[2]*10000+triData[i].textureIndices[2];
            //if(vItI.count(vti) == 0) {
                curIndex = maxIndex;
                //vItI[vti] = curIndex;

                pi = triData[i].vertexIndices[2];
                px = (frameData[0].pvertices[pi].vertex[0]*frameData[0].scale[0]+frameData[0].translate[0]);
                py = (frameData[0].pvertices[pi].vertex[1]*frameData[0].scale[1]+frameData[0].translate[1]);
                pz = (frameData[0].pvertices[pi].vertex[2]*frameData[0].scale[2]+frameData[0].translate[2]);
                /*
                pos->push_back(px);
                pos->push_back(py);
                pos->push_back(pz);
                */
                newVI2Old[curIndex] = pi;

                ti = triData[i].textureIndices[2];
                ts = ((float)texData[ti].s)/header.skinWidth;
                tt = ((float)texData[ti].t)/header.skinHeight;
                tex->push_back(ts); 
                tex->push_back(tt); 
                
                kmVec3Fill(&p3, px, py, pz);
                maxIndex++;
            //} else {
            //    curIndex = vItI[vti];
            //}

            (*ind)[i*3+2] = curIndex;
            
            kmVec3 nor;
            kmVec3Subtract(&p2, &p2, &p1);
            kmVec3Subtract(&p3, &p3, &p1);
            kmVec3Cross(&nor, &p3, &p2);
            kmVec3Normalize(&nor, &nor);

            //memcpy ok
            /*
            float *arr = (float*)&nor;
            normal->insert(normal->end(), arr, arr+3);
            normal->insert(normal->end(), arr, arr+3);
            normal->insert(normal->end(), arr, arr+3);
            */
            float temp[] = {nor.x, nor.y, nor.z};
            normal->insert(normal->end(), temp, temp+3);
            normal->insert(normal->end(), temp, temp+3);
            normal->insert(normal->end(), temp, temp+3);
        }
        //animations 里面放置所有的 frame的数据 pos 里面不用放置数据了
        //pos 里面放置显示的数据
        
        float dx = (maxx-minx);
        float dy = (maxy-miny);
        float dz = (maxz-minz);
        float scx = dx/200;
        float scy = dy/200;
        float scz = dz/200;
        //limit sx sy sz -100 100 range
        stdScale = std::min(scx, scy);
        stdScale = std::min(stdScale, scz);

        animations->resize(header.numFrames); 
        for(int i=0;  i < header.numFrames; i++) {
            (*animations)[i].resize(maxIndex*3);
            for(int j = 0; j < maxIndex; j++) {
                int pi = newVI2Old[j];
                float px = (frameData[i].pvertices[pi].vertex[0]*frameData[i].scale[0]+frameData[i].translate[0])/stdScale;
                float py = (frameData[i].pvertices[pi].vertex[1]*frameData[i].scale[1]+frameData[i].translate[1])/stdScale;
                float pz = (frameData[i].pvertices[pi].vertex[2]*frameData[i].scale[2]+frameData[i].translate[2])/stdScale;
                
                (*animations)[i][j*3+0] = px;     
                (*animations)[i][j*3+1] = py;     
                (*animations)[i][j*3+2] = pz;     
            }
        }

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

void readMD2(vector<float> *pos, vector<float> *tex, vector<unsigned int> *ind, vector< vector<float> > *animations,  vector<float> *normal , unsigned char *con) {
    vItI.clear();
    maxIndex = 0;

    fileCon = con;
    CCLog("before load");
    int res = md2ReadHeader(con, &header);
    dumpHeader();

    md2InitData(&header);
    md2LoadData(&header);
    md2ProcessData(pos, tex, ind, animations, normal);
    dumpPosAndTex(pos, tex, ind, animations, normal);

    CCLog("finish load md2");
}

