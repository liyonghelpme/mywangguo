#include "MyData.h"
#include <map>
#include "CCSprite3D.h"
unsigned char *readLine(unsigned char *con) {
    while(*con != '\n' && *con != '\r' && *con != EOF) {
        con++;
    }
    //读取换行符
    if(*con == '\n' || *con == '\r') {
        con++;
    }
    return con;
}

void dumpPosData(vector<float> *pos) {
    for(int i=0; i < pos->size(); i+=3) {
        CCLog("%f %f %f\n", (*pos)[i], (*pos)[i+1], (*pos)[i+2]);
    }
}
//显示简单顶点模型 无纹理
void readVert(unsigned char *con, vector<float> *pos, vector<VertexWeight> *wv) {
    int vnum;
    sscanf((char*)con, "%d", &vnum); 
    //读取一行数据 到下一行开始
    con = readLine(con);
    pos->clear();
    for(int i=0; i < vnum; i++) {
        float x, y, z;
        sscanf((char*)con, "%f %f %f", &x, &y, &z);
        con = readLine(con);
        pos->push_back(x); 
        pos->push_back(y); 
        pos->push_back(z); 
    }
    CCLog("pos data");
    dumpPosData(pos);

    int boneNum;
    sscanf((char*)con, "%d", &boneNum);
    con = readLine(con);
    for(int i=0; i < vnum; i++) {
        float a, b, c, d;
        //最多4个骨骼
        sscanf((char*)con, "%f %f %f %f", &a, &b, &c, &d);
        con = readLine(con);
        float w[] = {a, b, c, d};
        VertexWeight vv;
        int j;
        for(j=0; j < boneNum; j++) {
            vv.wei[j] = w[j];
        }   
        if(j < MAX_WEI_NUM) {
            vv.wei[j] = -1;
        }
        wv->push_back(vv);
    }
}

void dumpFaceData(vector<unsigned int> *ind) {
    CCLog("index Data");
    for(int i=0; i < ind->size(); i+=3) {
        CCLog("%d %d %d", (*ind)[i], (*ind)[i+1], (*ind)[i+2]);
    }
}
void readFace(unsigned char *con, vector<unsigned int> *ind) {
    ind->clear();

    int fnum;
    sscanf((char*)con, "%d", &fnum);
    con = readLine(con);
    for(int i=0; i < fnum; i++) {
        int a, b, c;
        sscanf((char*)con, "%d %d %d", &a, &b, &c);
        con = readLine(con);
        ind->push_back(a);
        ind->push_back(b);
        ind->push_back(c);
    }
    dumpFaceData(ind);
}
void dumpBoneData(vector<Bone> *bone) {
    CCLog("Bone Data");
    for(int i=0; i < bone->size(); i++) {
        CCLog("rotate", (*bone)[i].rotate.x);
    }
}
void scanLine(unsigned char **con, char *fmt, ...) {
    va_list argptr;
    va_start(argptr, fmt);
    vsscanf((char*)*con, fmt, argptr);
    va_end(argptr);
    *con = readLine(*con);
}

void dumpAniData(vector<KeyframeData> *key) {
    CCLog("ani");
    for(int i = 0; i < key->size(); i++) {
        CCLog("%d", (*key)[i].fnum);
        for(int j = 0; j < (*key)[i].bones.size(); j++) {
            CCLog("%f", (*key)[i].bones[j].rotate.x);
        }
    }
}
//读取动画数据
void readAni(unsigned char *con, vector<KeyframeData > *key) {
    int anum;
    scanLine(&con, "%d", &anum);    
    //动画数量
    for(int i = 0; i < anum; i++) {
        KeyframeData kd;
        key->push_back(kd);
    
        KeyframeData *pk = &(key->back());
        scanLine(&con, "%d", &pk->fnum);
        int bnum;
        scanLine(&con, "%d", &bnum);
        //每阵的骨骼数量
        for(int j=0; j < bnum; j++) {
            float x, y, z, w;
            scanLine(&con, "%f %f %f %f", &x, &y, &z, &w);
            float len;
            scanLine(&con, "%f", &len);
            float ox, oy, oz;
            scanLine(&con, "%f %f %f", &ox, &oy, &oz);
            int parent;
            scanLine(&con, "%d", &parent);
            
            Bone b;
            b.rotate.x = x;
            b.rotate.y = y;
            b.rotate.z = z;
            b.rotate.w = w;
            b.length = len;
            kmVec3Fill(&b.offset, ox, oy, oz);
            b.parent = parent;
            b.setChild();
            kmMat4Identity(&b.mat);
            b.id = i;
            //写入骨骼中
            pk->bones.push_back(b);
        }
    }
    dumpAniData(key);
}

unsigned char* readBone(unsigned char *con, vector<Bone> *bone) {
    int bnum;
    sscanf((char*)con, "%d", &bnum);
    con = readLine(con);
    map<int, vector<int> > pToChild;

    for(int i=0; i < bnum; i++) {
        float x, y, z, w;
        sscanf((char*)con, "%f %f %f %f", &x, &y, &z, &w);
        con = readLine(con);
        float len;
        sscanf((char*)con, "%f", &len);
        con = readLine(con);
        float ox, oy, oz;
        sscanf((char*)con, "%f %f %f", &ox, &oy, &oz);
        con = readLine(con);
        int parent;
        sscanf((char*)con, "%d", &parent);
        con = readLine(con);

        Bone b;
        b.rotate.x = x;
        b.rotate.y = y;
        b.rotate.z = z;
        b.rotate.w = w;
        b.length = len;
        kmVec3Fill(&b.offset, ox, oy, oz);
        b.parent = parent;
        b.setChild();
        kmMat4Identity(&b.mat);
        b.id = i;
        bone->push_back(b);

        if(parent != -1) {
            if(pToChild.count(parent) == 0) {
                vector<int> v;
                pToChild[parent] = v;
            }
            pToChild[parent].push_back(i);
        }
    }
    for(map<int, vector<int> >::iterator it=pToChild.begin(); it != pToChild.end(); it++) {
        Bone *pb = &((*bone)[it->first]);
        for(unsigned int i=0; i < it->second.size(); i++) {
            pb->child[i] = it->second[i];
        }
    }
    return con;
}


