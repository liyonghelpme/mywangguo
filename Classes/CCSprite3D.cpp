#include "CCSprite3D.h"
#include "MD2.h"
#include "Bone2.h"
#include "MyData.h"

CCSprite3D *CCSprite3D::create() {
    CCSprite3D *pSprite = new CCSprite3D();
    if(pSprite && pSprite->init()) {
        pSprite->autorelease();
        return pSprite;
    }
    CC_SAFE_DELETE(pSprite);
    return NULL;
}

CCSprite3D::CCSprite3D() {
}
CCSprite3D::~CCSprite3D() {
    CC_SAFE_RELEASE(pTex);
    CC_SAFE_RELEASE(pNor);
}
void CCSprite3D::initModel() {
    /*
    float p[] = {
        //bottom
       -0.5, -0.5, 0.5,  
       0.5, -0.5, 0.5, 
       0.5, -0.5, -0.5, 
       -0.5, -0.5, -0.5, 
    
        //top
       -0.5, 0.5, 0.5, 
       0.5, 0.5, 0.5, 
       0.5, 0.5, -0.5, 
       -0.5, 0.5, -0.5, 

        //front
       -0.5, -0.5, 0.5, //0 
       0.5, -0.5, 0.5,  //1
       -0.5, 0.5, 0.5,  //4
       0.5, 0.5, 0.5,   //5
        
        //back
        //3 2 6 7
       -0.5, -0.5, -0.5,//12 
       0.5, -0.5, -0.5, 
       0.5, 0.5, -0.5, 
       -0.5, 0.5, -0.5, 

        //right
       //1, 2, 6, 5
       0.5, -0.5, 0.5, //16
       0.5, -0.5, -0.5, 
       0.5, 0.5, -0.5, 
       0.5, 0.5, 0.5, 

        //left
        //0, 4, 7, 3
       -0.5, -0.5, 0.5,//20 
       -0.5, 0.5, 0.5, 
       -0.5, 0.5, -0.5, 
       -0.5, -0.5, -0.5, 
        
    };    
    vertNum = 24;
    pos.assign(p, p+vertNum*3);

    unsigned int i[] = {
        //bottom
        1, 0, 3,
        1, 3, 2,
        
        //front
        //0, 1, 5,
        //0, 5, 4,
        8, 9, 11,
        8, 11, 10,
        
        //back
        16, 17, 18, 
        16, 18, 19,
        
        //right
        13, 12, 15,
        13, 15, 14,
            
        //left
        20, 21, 22,
        20, 22, 23,


        //top
        4, 5, 6, 
        4, 6, 7,
    };
    index.assign(i, i+12*3);

    unsigned char c[] = {
        255, 0, 0, 255, 
        0, 0, 255, 255, 
        0, 255, 0, 255, 
        255, 0, 0, 255, 

        0, 0, 255, 255, 
        0, 255, 0, 255, 
        255, 0, 0, 255, 
        0, 255, 255, 255, 

        255, 0, 0, 255, 
        0, 0, 255, 255, 
        0, 0, 255, 255, 
        0, 255, 0, 255, 

        0, 0, 255, 255, 
        0, 255, 0, 255, 
        0, 0, 255, 255, 
        0, 255, 0, 255, 

        0, 0, 255, 255, 
        0, 255, 0, 255, 
        0, 0, 255, 255, 
        0, 255, 0, 255, 

        0, 0, 255, 255, 
        0, 255, 0, 255, 
        0, 0, 255, 255, 
        0, 255, 0, 255, 
    };
    col.assign(c, c+4*vertNum);

    //y 方向的纹理 坐标需要 flip 1-x
    float t[] = {
        //bottom
        0, 0,
        1, 0,
        1, 1,
        0, 1,
        
        //front
        0, 0,
        1, 0,
        1, 1,
        0, 1,

        //front
        0, 0,
        1, 0,
        0, 1,
        1, 1,
        
        //back
        1, 0,
        0, 0,
        0, 1,
        1, 1,
        //right
        0, 0,
        1, 0,
        1, 1,
        0, 1,
        
        //left
        //0 4 7 3
        1, 0,
        1, 1,
        0, 1,
        0, 0,
        
    };
    tex.assign(t, t+2*vertNum);
    */

    //CCTexture2D *text = CCTextureCache::sharedTextureCache()->addImage("test.png");
    initProgram();
    setTexture(NULL);
    setTextureRect();
}
void CCSprite3D::generatePoint() {
    inPoint = true;
    for(int i=0; i < pos.size(); i++) {
        pointInd.push_back(i);
    }
}
void CCSprite3D::generateLine() {
    inLine = true;
    for(int i = 0; i < index.size(); i += 3) {
        int p1 = index[i];
        int p2 = index[i+1];
        int p3 = index[i+2];
        lineInd.push_back(p1);
        lineInd.push_back(p2);
        lineInd.push_back(p2);
        lineInd.push_back(p3);
        lineInd.push_back(p3);
        lineInd.push_back(p1);
    }
}
//调用父亲类的 init  方法
bool CCSprite3D::init() {
    m_sBlendFunc.src = GL_ONE;
    m_sBlendFunc.dst = GL_ONE_MINUS_SRC_ALPHA;

    inLine = false;
    inPoint = false;
    //root Matrix 变换
    kmMat4Identity(&boneMat);
    xRot = 0;
    yRot = 0;
    zRot = 0;
    x = y= z = 0;
    sx = sy = sz = 1;
    pTex = NULL;
    pNor = NULL;
    passTime = 0;

    initModel();
    scheduleUpdate();
    return true;
}
void CCSprite3D::update(float diff) {
    passTime = passTime+diff;

    //y 旋转骨骼
    kmVec3 axis;
    kmVec3Fill(&axis, 1, 0, 0);
    //kmQuaternionRotationAxis(&bone[0].rotate, &axis, kmDegreesToRadians(45*passTime));
    //kmQuaternionRotationAxis(&bone[0].rotate, &axis, kmDegreesToRadians(35*sin(kmPI*passTime)));
    //kmQuaternionRotationAxis(&bone[1].rotate, &axis, kmDegreesToRadians(45*passTime));
    
    //变换 root 骨骼 parent = -1
    kmMat4 curMat;
    kmMat4Identity(&curMat);
    setBoneMatrix(&bone[0], &bone, &curMat);
    setBoneMatrix(&bone[1], &bone, &curMat);
    //根据骨骼修正顶点数值

    for(int i =0; i<allBoneMat.size(); i++) {
        kmMat4Multiply(&allBoneMat[i], &invBoneMat[i], &(bone[i].mat));
    }

    for(int i=0; i <wv.size(); i++) {
        kmVec3 v;
        kmVec3Fill(&v, pos[i*3], pos[i*3+1], pos[i*3+2]);
        kmVec3 out;
        kmVec3Zero(&out);
        for(int j=0; j < bone.size(); j++) {
            //骨骼权重 > 0 骨骼编号 和 相应的权重 只生成相关的骨骼 相关的不用关心
            if(wv[i].wei[j] > 0) {
                kmVec3 temp;
                kmVec3Transform(&temp, &v, &allBoneMat[j]);
                kmVec3Scale(&temp, &temp, wv[i].wei[j]);
                kmVec3Add(&out, &out, &temp);
            }
        }
        renderPos[i*3] = out.x;
        renderPos[i*3+1] = out.y;
        renderPos[i*3+2] = out.z;
    }
}

void CCSprite3D::rotateX(float deg) {
    xRot = deg;
}

void CCSprite3D::rotateY(float deg) {
    yRot = deg;
}

void CCSprite3D::rotateZ(float deg) {
    zRot = deg;
}
void CCSprite3D::tranX(float d) {
    x = d;
}

void CCSprite3D::tranY(float d) {
    y = d;
}

void CCSprite3D::tranZ(float d) {
    z = d;
}
void CCSprite3D::scaleX(float x) {
    sx = x;
}
void CCSprite3D::scaleY(float y) {
    sy = y;
}
void CCSprite3D::scaleZ(float z) {
    sz = z;
}

void CCSprite3D::stdTransform() {

    CCGLProgram *prog = getShaderProgram(); 
    kmMat4 matrixP;
    kmMat4 matrixMV;
    kmMat4 matrixMVP;

    kmGLGetMatrix(KM_GL_PROJECTION, &matrixP);
    kmGLGetMatrix(KM_GL_MODELVIEW, &matrixMV);

    //将对象 平移到屏幕中心位置
    matrixMV.mat[12] = 0;
    matrixMV.mat[13] = 0;
    //z 方向会影响缩放比例
    matrixMV.mat[14] = -300;

    //kmMat4 rotation;
    //kmMat4RotationPitchYawRoll(&rotation, xRot, yRot, zRot);

    kmMat4 translation;
    kmMat4Translation(&translation, x, y, z);

    kmMat4 scale;
    kmMat4Scaling(&scale, sx, sy, sz);

    kmMat4Multiply(&matrixMV, &matrixMV, &translation);
    kmMat4Multiply(&matrixMV, &matrixMV, &scale);
    
    kmMat4 rotx;
    kmVec3 axis = {1, 0, 0};
    kmMat4RotationAxisAngle(&rotx, &axis, xRot*kmPI/180);
    kmMat4Multiply(&matrixMV, &matrixMV, &rotx);
    
    kmMat4 roty;
    kmVec3 axis2 = {0, 1, 0};
    kmMat4RotationAxisAngle(&roty, &axis2, yRot*kmPI/180);
    kmMat4Multiply(&matrixMV, &matrixMV, &roty);

    kmMat4 rotz;
    kmVec3 axis3 = {0, 0, 1};
    kmMat4RotationAxisAngle(&rotz, &axis3, zRot*kmPI/180);
    kmMat4Multiply(&matrixMV, &matrixMV, &rotz);

    //矩阵缩放各个维度  0 0 0 默认的 0 0 0 坐标在 -200 x方向 -140 y 方向 -415 z 方向
    
    //printf("matrixMV\n");
    //printMat4(&matrixMV);
    
    //顶点位置 再做变换最后做还是再之前做
    //先做 局部骨骼旋转 接着做 MV 变换

    //先做本地变动接着 做骨骼变动 这样 本地变动就在局部空间进行了
    kmMat4Multiply(&matrixMV, &boneMat, &matrixMV);
    
    //printf("mmv bone\n");
    //printMat4(&matrixMV);


    kmMat4Multiply(&matrixMVP, &matrixP, &matrixMV);

    kmMat3 normalMatrix;
    /*
    kmMat4 inv4;
    kmMat4Inverse(&inv4, &matrixMV);
    kmMat4Transpose(&inv4, &inv4);

    kmMat4ExtractRotation(&normalMatrix, &inv4);
    */
    /*
    float det = kmMat3Determinant(&normalMatrix);
    kmMat3Inverse(&normalMatrix, det, &normalMatrix);
    kmMat3Transpose(&normalMatrix, &normalMatrix);
    */

    kmVec3 l;
    kmVec3Fill(&l, 200, 200, 200);
    

    prog->setUniformLocationWithMatrix4fv(pmat, matrixP.mat, 1);
    prog->setUniformLocationWithMatrix4fv(mvmat, matrixMV.mat, 1);
    prog->setUniformLocationWithMatrix4fv(mvpmat, matrixMVP.mat, 1);
    
    //bool updated = prog->updateUniformLocation(nmat, normalMatrix.mat, sizeof(float)*9*1);
    //if(updated) {
        glUniformMatrix3fv(nmat, 1, GL_FALSE, normalMatrix.mat);
    //}


    prog->setUniformLocationWith3f(light, l.x, l.y, l.z);
}

//模型经常在屏幕上面旋转移动
//模型的光照
void CCSprite3D::draw() {

    //CC_NODE_DRAW_SETUP();
    ccGLEnable(m_eGLServerState);
    getShaderProgram()->use();

    stdTransform();
    
    CCDirector::sharedDirector()->setDepthTest(true);
    //ccGLBlendFunc(m_sBlendFunc.src, m_sBlendFunc.dst);
    glDisable(GL_BLEND);

    if (pTex != NULL)
    {
        ccGLBindTexture2D( pTex->getName() );
        ccGLEnableVertexAttribs( kCCVertexAttribFlag_PosColorTex );
    }
    else
    {
        ccGLBindTexture2D(0);
        ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_Color );
    }
    //bind normal纹理数据到 1号槽位置
    //1号槽位置 对应 shader 中的normalmap
    if(pNor != NULL) {
        ccGLBindTexture2DN(1, pNor->getName());
        //enable normal array
        glEnableVertexAttribArray(3);
    }


    glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, 0, &renderPos[0]);
    if (pTex != NULL)
    {
        // texCoods
        glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, &tex[0]);
    }
    //暂时不要颜色
    //glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, &col[0]);
    if(pNor != NULL) {
        glVertexAttribPointer(3, 3, GL_FLOAT, GL_FALSE, 0, &normal[0]);
    }

    if(inPoint) {
        glDrawElements(GL_POINTS, pointInd.size(), GL_UNSIGNED_INT, &pointInd[0]);
        //glPointSize(10);
        //glDrawArrays(GL_POINTS, 0, 4);
    }else if(inLine) {
        glDrawElements(GL_LINES, lineInd.size(), GL_UNSIGNED_INT, &lineInd[0]);
    } else {
        glDrawElements(GL_TRIANGLES, index.size(), GL_UNSIGNED_INT, &index[0]);
    }
    
    CCDirector::sharedDirector()->setDepthTest(false);
    glEnable(GL_BLEND);
}

void CCSprite3D::loadData(const char *vert, const char *face, const char *boned) {
    unsigned long size;
    unsigned char *fcon = CCFileUtils::sharedFileUtils()->getFileData(vert, "rb", &size);
    readVert(fcon, &pos, &wv);
    delete fcon;

    fcon = CCFileUtils::sharedFileUtils()->getFileData(face, "rb", &size);
    readFace(fcon, &index);
    delete fcon;

    fcon = CCFileUtils::sharedFileUtils()->getFileData(boned, "rb", &size);
    readBone(fcon, &bone);
    delete fcon;

    allBoneMat.resize(bone.size());
    initRenderPos();
    
    //当前骨骼状态 的逆 用于标注骨骼的默认姿态
    for(int i=0; i < bone.size(); i++) {
        kmMat4 mat;
        //offset set 接着 rotate
        kmMat4RotationQuaternion(&mat, &bone[i].rotate);
        mat.mat[12] = bone[i].offset.x;
        mat.mat[13] = bone[i].offset.y;
        mat.mat[14] = bone[i].offset.z;
        kmMat4Inverse(&mat, &mat);
        invBoneMat.push_back(mat);
    }
}

void CCSprite3D::initRenderPos() {
    renderPos = pos;
}


void CCSprite3D::loadMd2(const char *fileName) {
    unsigned long size;
    unsigned char *fcon = CCFileUtils::sharedFileUtils()->getFileData(fileName, "rb", &size);
    readMD2(&pos, &tex, &index, &animations, &normal, fcon);
    pos = animations[0]; 
    delete fcon;
}

void CCSprite3D::setNormalMap(CCTexture2D *nm) {
    if(pNor != nm) {
        CC_SAFE_RETAIN(nm);
        CC_SAFE_RELEASE(pNor);
        pNor = nm;
    }
}
void CCSprite3D::setTexture(CCTexture2D *texture) {
    //initProgram();
    if(pTex != texture) {
        CC_SAFE_RETAIN(texture);
        CC_SAFE_RELEASE(pTex);
        pTex = texture;
        //updateBlendFunc();
    }
}
void CCSprite3D::setTextureRect() {
    
}
void CCSprite3D::initProgram() {
    GLchar * fragSource = (GLchar*) CCString::createWithContentsOfFile(
                                CCFileUtils::sharedFileUtils()->fullPathForFilename("D3frag.h").c_str())->getCString();

    GLchar * vertSource = (GLchar*) CCString::createWithContentsOfFile(
                                CCFileUtils::sharedFileUtils()->fullPathForFilename("D3ver.h").c_str())->getCString();

    CCGLProgram *prog = new CCGLProgram();
    prog->initWithVertexShaderByteArray(vertSource, fragSource);
    setShaderProgram(prog);
    prog->release();

    CHECK_GL_ERROR_DEBUG();
    
    //0 1 2 3
    getShaderProgram()->addAttribute(kCCAttributeNamePosition, kCCVertexAttrib_Position);
    getShaderProgram()->addAttribute(kCCAttributeNameColor, kCCVertexAttrib_Color);
    getShaderProgram()->addAttribute(kCCAttributeNameTexCoord, kCCVertexAttrib_TexCoords);
    getShaderProgram()->addAttribute("a_normal", 3);
    CHECK_GL_ERROR_DEBUG();

    getShaderProgram()->link();
    
    CHECK_GL_ERROR_DEBUG();
    getShaderProgram()->updateUniforms();

    CHECK_GL_ERROR_DEBUG();
    

    pmat = glGetUniformLocation( getShaderProgram()->getProgram(), "CC_PMatrix");
    mvmat = glGetUniformLocation( getShaderProgram()->getProgram(), "CC_MVMatrix");
    mvpmat = glGetUniformLocation( getShaderProgram()->getProgram(), "CC_MVPMatrix");
    nmat = glGetUniformLocation(getShaderProgram()->getProgram(), "u_normalMatrix");
    light = glGetUniformLocation(getShaderProgram()->getProgram(), "light");
    nmap = glGetUniformLocation(getShaderProgram()->getProgram(), "u_normalMap");
    //使用第一个纹理槽
    getShaderProgram()->setUniformLocationWith1i(nmap, 1);
}
