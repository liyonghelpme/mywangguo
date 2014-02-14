//
//  RemoveTempVideo.h
//  libav2
//
//  Created by  stc on 13-5-2.
//
//

#import <Foundation/Foundation.h>

@interface RemoveTempVideo : NSObject
-(void)finishCopy:(NSString *)videoPath error : (NSError *)error context:(void*)context;
@end
