//
//  ZKNotificationView.h
//  ZKNSNotificationView
//
//  Created by mosaic on 2017/4/29.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^NotificationViewFinished)(void);

typedef void (^NotificationViewWillShow)(void);
typedef void (^NotificationViewDidShow)(void);

@interface ZKNotificationView : UIView



+(void)show:(NSString*)msg willShowBlock:(NotificationViewWillShow)notifiViewWill Tapblock:(NotificationViewFinished)finishBlock didShowBlock:(NotificationViewDidShow)didShow;//需要调用hidden隐藏,点击隐藏,触发block
+(void)show:(NSString *)msg delay:(NSTimeInterval)time willShowBlock:(NotificationViewWillShow)notifiViewWill Tapblock:(NotificationViewFinished)finishBlock didShowBlock:(NotificationViewDidShow)didShow;//自定义显示时间,调用hidden可以提前结束显示

+(void)showViewName:(NSString*)showName icon:(NSString*)imageName msg:(NSString*)msg willShowBlock:(NotificationViewWillShow)notifiViewWill Tapblock:(NotificationViewFinished)finishBlock didShowBlock:(NotificationViewDidShow)didShow;//自定义显示icon 和title 默认为app的icon与name 

+(void)showViewName:(NSString*)showName icon:(NSString*)imageName msg:(NSString*)msg delay:(NSTimeInterval)time willShowBlock:(NotificationViewWillShow)notifiViewWill Tapblock:(NotificationViewFinished)finishBlock didShowBlock:(NotificationViewDidShow)didShow;

+(void)hidden;


+(void)ShowLocalNotification:(NSString*)showMsg;

@end
