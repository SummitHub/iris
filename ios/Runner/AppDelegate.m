#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
@import Firebase;
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[FIRMessaging messaging] subscribeToTopic:@"allDevices"
    completion:^(NSError * _Nullable error) {
        NSLog(@"Subscribed to allDevices");
    }];
  [FIRApp configure];
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
