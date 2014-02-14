//
//  RemoveTempVideo.m
//  libav2
//
//  Created by  stc on 13-5-2.
//
//

#import "RemoveTempVideo.h"

@implementation RemoveTempVideo
-(void) finishCopy:(NSString *)videoPath error:(NSError *)error context:(void *)context {
    NSLog(@"finish copy error %@", error);
    NSError *temp;
    [[NSFileManager defaultManager] removeItemAtPath:videoPath error:&temp];
    //NSLog(@"remove Error %@", temp);
}
@end
