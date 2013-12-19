//
//  CameraFile.mm
//  nozomi
//
//  Created by  stc on 13-4-11.
//
//

#include "CameraFile.h"
#include "cocos2d.h"
#include "EAGLView.h"
using namespace cocos2d;

NS_CC_EXT_BEGIN

//视频的保存时间作为名字放置重叠
CameraFile::CameraFile() {
    NSDate *curTime = [NSDate date];
    ct = int([curTime timeIntervalSince1970]);
    removeTempVideo = [[RemoveTempVideo alloc] init];
    NSLog(@"removeTempVideo %@", removeTempVideo);
    movieFrameBuffer = 0;
}

CameraFile::~CameraFile() {
    NSLog(@"CameraFile remove");
    [removeTempVideo release];
}

const char *CameraFile::getFileName() {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    //NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *document = [path objectAtIndex:0];
    
    NSString *s = [NSString stringWithFormat:@"%d-test.mov", ct];
    NSString *appFile = [document stringByAppendingPathComponent: s ];
    
    NSLog(@"appfile is %@", appFile);
    
    NSArray *testPath = NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, YES);
    for (int i = 0; i < [testPath count]; i++) {
        NSLog(@"testPath %@", [testPath objectAtIndex:i]);
    }
    
    
    
    return [appFile UTF8String];
}
void CameraFile::destroyDataFBO() {
    if (movieFrameBuffer) {
        glDeleteFramebuffers(1, &movieFrameBuffer);
        movieFrameBuffer = 0;
    }
    if (coreVideoTextureCache) {
        CFRelease(coreVideoTextureCache);
    }
    if (renderTexture) {
        CFRelease(renderTexture);
    }
    if (renderTarget) {
        CVPixelBufferRelease(renderTarget);
    }
    
}
//生成TextureCache 管理器
//pixelBuffer renderTarget  内存中  依赖 writePixelBuffer 管理器
//texture    renderTexture  显卡中
void CameraFile::createDataFBO() {
    NSLog(@"createDataFBO");
    context = [[EAGLView sharedEGLView] context];
    GLint oldFBO;
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFBO);
    
    glGenFramebuffers(1, &movieFrameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, movieFrameBuffer);
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, context, NULL, &coreVideoTextureCache);
    if(err) {
        NSLog(@"create FBO fail");
        exit(1);
    }
    CVPixelBufferPoolCreatePixelBuffer(NULL, [assetWriterPixelBufferInput pixelBufferPool], &renderTarget);
    CVOpenGLESTextureCacheCreateTextureFromImage (kCFAllocatorDefault, coreVideoTextureCache, renderTarget,
                                                  NULL, // texture attributes
                                                  GL_TEXTURE_2D,
                                                  GL_RGBA, // opengl format
                                                  (int)width,
                                                  (int)height,
                                                  GL_BGRA, // native iOS format
                                                  GL_UNSIGNED_BYTE,
                                                  0,
                                                  &renderTexture);
    
    glBindTexture(CVOpenGLESTextureGetTarget(renderTexture), CVOpenGLESTextureGetName(renderTexture));
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, CVOpenGLESTextureGetName(renderTexture), 0);
    
    glBindFramebuffer(GL_FRAMEBUFFER, oldFBO);
    CCDirector::sharedDirector()->startRecording();
}
void CameraFile::savedToCamera() {
    NSLog(@"cameraFIle ");
    const char *fileName = this->getFileName();
    NSLog(@"saveFileName %s", fileName);
    
    UISaveVideoAtPathToSavedPhotosAlbum([NSString stringWithFormat:@"%s",  fileName], removeTempVideo, @selector(finishCopy:error:context:), nil);
    NSLog(@"count num %lu", (unsigned long)[removeTempVideo retainCount]);
    delete this;
    //[[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%s", fileName] error:nil];
}
void CameraFile::startWork(int w, int h) {
    //根据屏幕尺寸设定视频尺寸
    if(w == 2048) {
        this->width = 1024;
        this->height = 768;
    } else {
        this->width = w;
        this->height = h;
    }
    
    //frameData = (uint8_t*)malloc(this->width*4);
    const char *fileName = this->getFileName();
    //fn = [NSString stringWithFormat:@"%s", fileName];
    NSError *error = nil;
    NSURL *url = [[NSURL alloc] initFileURLWithPath:[NSString stringWithFormat:@"%s", fileName] isDirectory:false];
    [url autorelease];
    
    assetWriter = [[AVAssetWriter alloc] initWithURL:url fileType:AVFileTypeAppleM4V error:&error];
    if(error != nil) {
        NSLog(@"assetWriter Error %@", error);
        NSLog(@"url %@ %s", url, fileName);
        exit(1);
    }
    NSLog(@"CameraFile startWork %@", url);
    
    NSMutableDictionary *outputSettings = [[NSMutableDictionary alloc] init];
    [outputSettings autorelease];
    
    [outputSettings setObject:AVVideoCodecH264 forKey:AVVideoCodecKey];
    [outputSettings setObject:[NSNumber numberWithInt:this->width] forKey:AVVideoWidthKey];
    [outputSettings setObject:[NSNumber numberWithInt:this->height] forKey:AVVideoHeightKey];
    
    assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSettings];
    [assetWriterVideoInput retain];
    
    assetWriterVideoInput.expectsMediaDataInRealTime = true;
    
    
    NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
                                                           [NSNumber numberWithInt:this->width], kCVPixelBufferWidthKey,
                                                           [NSNumber numberWithInt:this->height], kCVPixelBufferHeightKey,
                                                           nil];
    assetWriterPixelBufferInput = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:assetWriterVideoInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    [assetWriterPixelBufferInput retain];
    
    
    [assetWriter addInput:assetWriterVideoInput];
    startTime = [NSDate date];
    [startTime retain];
    
    
    [assetWriter startWriting];
    [assetWriter startSessionAtSourceTime:kCMTimeZero];
    NSLog(@"startWork");
    
    //必须要等待 startWriting 才能 分配renderTarget
    this->createDataFBO();
}
void CameraFile::compressFrame() {
    if (!assetWriterVideoInput.readyForMoreMediaData)
    {
        NSLog(@"Had to drop a video frame");
        return;
    }
    //结束绘制 导出数据
    //glFinish();
    //NSLog(@"compressFrame in Camera");
    //NSLog(@"lock pixel_buffer %@", renderTarget);
    CVPixelBufferRef pixel_buffer = NULL;
    
    pixel_buffer = renderTarget;
    
    //直接读取Framebuffer 中的数据
    CVPixelBufferLockBaseAddress(pixel_buffer, 0);
    
    GLint oldFBO;
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFBO);
    glBindFramebuffer(GL_FRAMEBUFFER, movieFrameBuffer);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    //需要调整ScaleY 用于显示
    //测试播放动画
    CCSize winSize = CCDirector::sharedDirector()->getVisibleSize();
    CCSprite *recordSprite = CCDirector::sharedDirector()->getRecordSprite();
    //recordSprite->setAnchorPoint(ccp(0, 0));
    //recordSprite->setPosition(ccp(0, 0));
    float sx = this->width/winSize.width;
    float sy = this->height/winSize.height;
    recordSprite->setScaleX(sx);
    recordSprite->setScaleY(sy);
    //CCDirector::sharedDirector()->getRecordSprite()->setScaleY(1);
    recordSprite->visit();
    //CCDirector::sharedDirector()->getRecordSprite()->setScaleY(-1);
    recordSprite->setAnchorPoint(ccp(0.5, 0.5));
    recordSprite->setPosition(ccp(winSize.width/2, winSize.height/2));
    recordSprite->setScaleX(1);
    recordSprite->setScaleY(-1);
                              
    glFlush();
    
    glBindFramebuffer(GL_FRAMEBUFFER, oldFBO);
    
    CMTime currentTime = CMTimeMakeWithSeconds([[NSDate date] timeIntervalSinceDate:startTime], 120);
    if (![assetWriterPixelBufferInput appendPixelBuffer:pixel_buffer withPresentationTime:currentTime]) {
        NSLog(@"Problem appending pixel buffer at time: %lld", currentTime.value);
    } else {
        
    }
    CVPixelBufferUnlockBaseAddress(pixel_buffer, 0);
    //不能释放 pixel_buffer
    //CVPixelBufferRelease(pixel_buffer);
    
}
void CameraFile::stopWork() {
    CCDirector::sharedDirector()->stopRecording();
    
    [assetWriterVideoInput markAsFinished];
     
    [assetWriter finishWritingWithCompletionHandler:^(){savedToCamera();}];
    NSLog(@"stopWork");
    
    [assetWriter release];
    [assetWriterVideoInput release];
    [assetWriterPixelBufferInput release];
    [startTime release];
    //free(frameData);
    destroyDataFBO();
}

NS_CC_EXT_END