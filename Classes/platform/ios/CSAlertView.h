//
//  CSAlertView.h
//  nozomi
//
//  Created by  stc on 13-8-27.
//
//

#import <Foundation/Foundation.h>

@interface CSAlertView : NSObject<UIAlertViewDelegate>{
    int button[2];
}

- (id)initWithTitle:(NSString*)title content:(NSString*)content button1:(int)button1 button1Text:(NSString*)button1Text button2:(int)button2 button2Text:(NSString*)button2Text;
@end
