//
//  GCHelper.h
//  nozomi
//
//  Created by  stc on 13-2-26.
//
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface GCHelper : NSObject <GKGameCenterControllerDelegate, UIAlertViewDelegate, GKAchievementViewControllerDelegate>{
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
    NSArray *leaderboards;
    UIViewController *myRoot;
}

@property (assign, readonly) BOOL gameCenterAvailable;

+ (GCHelper *)sharedGameCenter;
- (void)authenticationChanged;
- (void)authenticateLocalUser:(UIViewController*) rootController;
- (void)loadLeaderboardInfo;
- (void)reportScore:(int64_t) score forLeaderboardID: (NSString *)category;
- (NSString *)getLeaderboardName;
- (void)showLeaderboard : (NSString *)leaderBoardID rootController:(UIViewController *)rootController;
- (void) testLeaderBoard;


- (void) reportAchievementIdentifier: (NSString *)identifier percentComplete : (float) percent;
- (void) loadAchievement;
- (void) resetAchievements;
- (void) testAchievements;
- (void) showAchievements;
@end
