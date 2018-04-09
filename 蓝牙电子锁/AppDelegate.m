
//
//  AppDelegate.m
//  蓝牙电子锁
//
//  Created by mosaic on 2017/11/14.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import "AppDelegate.h"
#import "ZKAddBLEController.h"
@interface AppDelegate ()
@property (nonatomic,assign)UIBackgroundTaskIdentifier bgTask;
@property (nonatomic,strong)NSTimer *timer;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if ([[UIApplication sharedApplication] currentUserNotificationSettings].types != UIUserNotificationTypeNone) {
        [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];
    } else{
        //用户注册通知，注册后才能收到通知，这会给用户一个弹框，提示用户选择是否允许发送通知
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }

    
    //获取保存的BLE状态
    [ZKCommonData sharedZKCommonData];
    [[ZKBleManager alloc]initWithLaunchOptions:launchOptions];
    [ZKBleManager sharedZKBleManager];
    
    //
//    ZKAddBLEController *addvc = [[ZKAddBLEController alloc]init];
    ZKMainViewController*mainVC = [[ZKMainViewController alloc]init];
    //根控制器
    ZKNavigationController*navVC = [[ZKNavigationController alloc]initWithRootViewController:mainVC];
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.rootViewController = navVC;
    [window makeKeyAndVisible];
    self.window = window;
    return YES;
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    ZKLog(@"通知:%@",notification);
}

/**
 *  删除当前的通知
 */

- (void)cancelNSNotification{
    
    //   手动删除通知
    //   这里我们要根据我们添加时设置的key和自定义的ID来删
    NSArray *narry=[[UIApplication sharedApplication] scheduledLocalNotifications];
    NSUInteger acount=[narry count];
    if (acount>0)
    {
        // 遍历找到对应nfkey和notificationtag的通知
        for (int i=0; i<acount; i++)
        {
            UILocalNotification *myUILocalNotification = [narry objectAtIndex:i];
            
            ZKLog(@"%@",myUILocalNotification.alertBody);
                // 删除本地通知
                [[UIApplication sharedApplication] cancelLocalNotification:myUILocalNotification];
                break;
            
        }
    }
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    //保存前台时的状态
    [ZKBleManager sharedZKBleManager].restoreState = [ZKBleManager sharedZKBleManager].scanType;
    //设置为后台状态
    [ZKBleManager sharedZKBleManager].scanType = BLEBackgroundScanning;
    UIDevice*device = [UIDevice currentDevice];
    BOOL backgroundSupported = NO;
        if([device respondsToSelector:@selector(isMultitaskingSupported)]) {
            backgroundSupported =YES;
        }
    
    __block UIBackgroundTaskIdentifier bgTaskId = [application beginBackgroundTaskWithExpirationHandler:^{
        
        [application endBackgroundTask:bgTaskId];
        bgTaskId =UIBackgroundTaskInvalid;
        
    }];
    
    if(backgroundSupported) {
        
        [application endBackgroundTask:bgTaskId];
        bgTaskId =UIBackgroundTaskInvalid;
//
//        __block int i =0;//这个值是用来测试后台用运行情况，
//
//        if (@available(iOS 10.0, *)) {
//            self.timer= [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer*_Nonnulltimer) {
//
//                //执行蓝牙相关操作...
//
//                ZKLog(@"%d",i ++);
//
//            }];
//        } else {
//
//        }
//
//        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
//
//        [self.timer fire];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
//                       {
//                           dispatch_async(dispatch_get_main_queue(), ^
//                                          {
//                                              if (bgTaskId != UIBackgroundTaskInvalid)
//                                              {
//                                                  [application endBackgroundTask:bgTaskId];
//
//                                                  bgTaskId = UIBackgroundTaskInvalid;
//
//                                              }
//                                          });
//                       });
    }
        
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    //恢复状态
    [ZKBleManager sharedZKBleManager].scanType = [ZKBleManager sharedZKBleManager].restoreState;

}


- (void)applicationDidBecomeActive:(UIApplication *)application {

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
