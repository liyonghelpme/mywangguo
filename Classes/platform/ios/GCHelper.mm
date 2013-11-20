//
//  GCHelper.m
//  nozomi
//
//  Created by  stc on 13-2-26.
//
//

#import "GCHelper.h"
#import "support/user_default/CCUserDefault.h"
#import "CCDirector.h"

@implementation GCHelper

@synthesize gameCenterAvailable;

#pragma mark Initialization

static GCHelper* instance = nil;
+ (GCHelper *) sharedGameCenter {
    if (!instance){
        instance = [[GCHelper alloc] init];
    }
    return instance;
}

- (BOOL)isGameCenterAvailable {
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}
- (void) testLeaderBoard {
    return;
    NSString *name = [self getLeaderboardName];
    [self reportScore:1000 forLeaderboardID:name];
    //加载信息结束 测试 leaderboarder 显示
    //[self showLeaderboard:name rootController:self->myRoot];
}
-(void) testAchievements {
    //don't test
    return;
    for(int i = 1; i <= 14; i++) {
        [self reportAchievementIdentifier:[NSString stringWithFormat:@"task%d.1", i]  percentComplete:100];
        [self reportAchievementIdentifier:[NSString stringWithFormat:@"task%d.2", i]  percentComplete:100];
        [self reportAchievementIdentifier:[NSString stringWithFormat:@"task%d.3", i]  percentComplete:100];
    }
    
    [self showAchievements];
}
- (void)authenticationChanged {
    NSLog(@"authentication changed");
    if ([GKLocalPlayer localPlayer].isAuthenticated != userAuthenticated){
        userAuthenticated = !userAuthenticated;
        if (userAuthenticated){
            cocos2d::CCUserDefault *userDefault = cocos2d::CCUserDefault::sharedUserDefault();
            userDefault->setStringForKey("username", [[GKLocalPlayer localPlayer].playerID UTF8String]);
            userDefault->setBoolForKey("gamecenter", true);
            userDefault->setStringForKey("nickname", [[GKLocalPlayer localPlayer].alias UTF8String]);
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            if(![userDefaults boolForKey:@"UUIDSYN"])
            {
                NSString* uuid = [userDefaults stringForKey:@"UUID"];
                if(uuid!=nil){
                    userDefault->setStringForKey("tempname", [uuid UTF8String]);
                }
                [userDefaults setBool:YES forKey:@"UUIDSYN"];
            }
            NSLog(@"Player ID: %@", [GKLocalPlayer localPlayer].playerID);
        }
        //登陆之后加在leaderboard 信息
        //[self loadLeaderboardInfo];
        [self loadAchievement];
    }
}

- (id)init {
    if ((self = [super init])) {
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable) {
            userAuthenticated = FALSE;
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc addObserver:self selector:@selector(authenticationChanged) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
        }
    }
    return self;
}

#pragma mark User functions

- (void)authenticateLocalUser:(UIViewController*) rootController {
    NSLog(@"authenticate local user");
    self->myRoot = rootController;
    if (!gameCenterAvailable) return;
    
    NSLog(@"AVALAIBLE");
    GKLocalPlayer * player = [GKLocalPlayer localPlayer];
    NSLog(@"isAuthenticated? %c", player.isAuthenticated);
    if (player.isAuthenticated == NO) {
        NSLog(@"Not Authenticated");
        cocos2d::CCUserDefault::sharedUserDefault()->setStringForKey("username", "");
        cocos2d::CCUserDefault::sharedUserDefault()->setStringForKey("tempname", "");
        cocos2d::CCUserDefault::sharedUserDefault()->setStringForKey("nickname", "");
        //player.authenticateHandler =
        //UIViewController* controller, 
        [player authenticateWithCompletionHandler: ^(NSError *error){
            /*
            if (controller != nil)
            {
                [rootController presentViewController:controller animated:YES completion:nil];
            }
            else
            */
            if (error == nil) {
                NSLog(@"authenticate successful");
            }
            if (error != nil)
            {
                NSLog(@"Error msg:%@", [error localizedDescription]);
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setBool:NO forKey:@"UUIDSYN"];
                NSString* uuid = [userDefaults stringForKey:@"UUID"];
                if(uuid==nil)
                {
                    CFUUIDRef uuidRef = CFUUIDCreate(nil);
                    CFStringRef uuidString = CFUUIDCreateString(nil, uuidRef);
                    uuid = (NSString *)CFStringCreateCopy(NULL, uuidString);
                    [userDefaults setObject:uuid forKey:@"UUID"];
                    CFRelease(uuidRef);
                    CFRelease(uuidString);
                    [uuid autorelease];
                }
                cocos2d::CCUserDefault::sharedUserDefault()->setStringForKey("tempname", [uuid UTF8String]);
                cocos2d::CCUserDefault::sharedUserDefault()->setBoolForKey("gamecenter", false);
                /*
                NSString* alertText = [NSString stringWithFormat:@"If you don't use game center, your data will be lose .", [error localizedDescription]];
                UIAlertView* alertView = [[[UIAlertView alloc] initWithTitle:@"Game Center" message:alertText delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil] autorelease];
                [alertView show];*/
            }
        }];
    } else {
        //[self loadLeaderboardInfo];
        [self loadAchievement];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    cocos2d::CCDirector::sharedDirector()->end();
    exit(0);
}
//load leaderboard info
//show leaderboard info
//update leaderboard info
//游戏中 更新玩家积分

//ios 5 其它方法
-(void)loadLeaderboardInfo{
    NSLog(@"load leader board Info");
    [GKLeaderboard loadLeaderboardsWithCompletionHandler:^(NSArray *leaderboards, NSError *error) {
        self->leaderboards = leaderboards;
        [self testLeaderBoard];
    }];
    
}
-(void)reportScore:(int64_t)score forLeaderboardID:(NSString *)category {
    GKScore *scoreReporter = [[GKScore alloc] initWithCategory:category];
    scoreReporter.value = score;
    scoreReporter.context = 0;
    scoreReporter.shouldSetDefaultLeaderboard = YES;
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error){
        
    }];
}
-(NSString *)getLeaderboardName{
    GKLeaderboard *leader = (GKLeaderboard *)([self->leaderboards objectAtIndex:0]);
    return leader.category;
    //return [leader.category UTF8String];
}
//ios 5 其它方法
-(void) showLeaderboard:(NSString *)leaderBoardID rootController:(UIViewController *)rootController{
    GKGameCenterViewController *gamecenterController = [[GKGameCenterViewController alloc] init];
    if (gamecenterController != nil) {
        gamecenterController.gameCenterDelegate = self;
        gamecenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
        gamecenterController.leaderboardTimeScope = GKLeaderboardTimeScopeToday;
        gamecenterController.leaderboardCategory = leaderBoardID;
        [rootController presentViewController: gamecenterController animated : YES completion: nil];
    }
}
-(void) gameCenterViewControllerDidFinish : (GKGameCenterViewController *)gameCenterViewController {
    [self->myRoot dismissViewControllerAnimated:YES completion:nil];
}

-(void) reportAchievementIdentifier:(NSString *)identifier percentComplete:(float)percent {
    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
    if (achievement) {
        achievement.percentComplete = percent;
        [achievement reportAchievementWithCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"achieve report error %@", error);
            }
        }];
        
    }
}
-(void) loadAchievement {
    NSLog(@"load Achievement info");
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
        NSLog(@"achievements is %@ %@", achievements, error);
        if (error != nil) {
            NSLog(@"achievement error %@", error);
        }
        if (achievements != nil) {
            
            for (GKAchievement *a in achievements) {
                NSLog(@"achievemts is %@", a);
                NSLog(@"achieve id %@", a.identifier);
            }
        } else {
            
        }
        [self testAchievements];
    }];
}
-(void) resetAchievements {
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"reset error %@", error);
        }
    }];
}
/*
-(void) showAchievements {
    GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
    if (gameCenterController != nil) {
        gameCenterController.gameCenterDelegate = self;
        gameCenterController.viewState = GKGameCenterViewControllerStateAchievements;
        [self->myRoot presentViewController:gameCenterController animated:YES completion:nil];
    }
}
*/
-(void) showAchievements {
    GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];
    if (achievements != nil) {
        achievements.achievementDelegate = self;
        [self->myRoot presentViewController:achievements animated:YES completion:nil];
    }
}
-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController {
    [self->myRoot dismissViewControllerAnimated:YES completion:nil];
}
@end
