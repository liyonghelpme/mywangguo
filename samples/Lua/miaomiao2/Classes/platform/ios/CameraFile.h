//
//  CameraFile.h
//  nozomi
//
//  Created by  stc on 13-4-11.
//
//

#ifndef nozomi_CameraFile_h
#define nozomi_CameraFile_h

#import <AVFoundation/AVFoundation.h>

#import "RemoveTempVideo.h"
#import "ExtensionMacros.h"

NS_CC_EXT_BEGIN

class CameraFile{
public:
    CameraFile();
    ~CameraFile();
    const char *getFileName();
    void savedToCamera();
    void initWriter();
    void startWork(int width, int height);
    void compressFrame(void);
    void stopWork(void);
private:
    uint8_t *frameData;
    AVAssetWriter *assetWriter;
    int width;
    int height;
    AVAssetWriterInput *assetWriterVideoInput;
    AVAssetWriterInputPixelBufferAdaptor *assetWriterPixelBufferInput;
    NSDate *startTime;
    
    //NSString *fn;
    int ct;
    void createDataFBO();
    void destroyDataFBO();
    
    GLuint movieFrameBuffer;
    CVOpenGLESTextureCacheRef coreVideoTextureCache;
    EAGLContext *context;
    CVPixelBufferRef renderTarget;
    CVOpenGLESTextureRef renderTexture;
    
    RemoveTempVideo *removeTempVideo;
};

NS_CC_EXT_END

#endif
