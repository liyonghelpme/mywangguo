#ifndef __MYDATA_H__
#define __MYDATA_H__
#include <vector>
#include <stdio.h>
#include "Bone2.h"
struct VertexWeight;

using namespace std;
void readVert(unsigned char *con, vector<float> *pos, vector<VertexWeight> *wv);
void readFace(unsigned char *con, vector<unsigned int> *ind);
unsigned char* readBone(unsigned char *con, vector<Bone> *bone);
void readAni(unsigned char *con, vector<KeyframeData > *key);
#endif
