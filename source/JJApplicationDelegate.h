@import Cocoa;
@import UserNotifications;

@interface JJApplicationDelegate:NSObject<NSApplicationDelegate, UNUserNotificationCenterDelegate>
-(void)openLicense:(nullable id)sender;
-(void)openMacAppStore:(nullable id)sender;
-(void)openMainWindow:(nullable id)sender;
-(void)openWebSite:(nullable id)sender;
@end

extern NSString*_Null_unspecified JJApplicationName;
