#import "AppDelegate.h"
@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)options {
    NSLog(@"[CS2iOS] startup");
    return YES;
}
- (void)applicationDidEnterBackground:(UIApplication *)application { NSLog(@"[CS2iOS] background"); }
- (void)applicationWillEnterForeground:(UIApplication *)application { NSLog(@"[CS2iOS] foreground"); }
@end
