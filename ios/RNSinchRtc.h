
#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#else
#import "RCTBridgeModule.h"
//#import "RCTEventEmitter.h"
#endif

#import "NotificationsHandlerable.h"
#import "MessagesHandlerable.h"

@interface RNSinchRtc : RCTEventEmitter <RCTBridgeModule>

#pragma mark - Setup
+ (void) initialize:(NSDictionary *)properties;

#pragma mark - Notifications
#pragma mark Notification Requesting
+ (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings;
+ (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
+ (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

#pragma mark Notification Handling
+ (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;
+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
@end
  
