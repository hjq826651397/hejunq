//
//  ZKAlertView.h
//  MosaicLightBLE
//
//  Created by mosaic on 2017/6/6.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^cancelBlock)(void);
typedef void (^completion)(void);
typedef void (^confirm)(void);
@interface ZKAlertView : NSObject
@property(strong,nonatomic)UIAlertController*alertVC;

singleton_interface(ZKAlertView)

-(void)showTitle:(NSString*)title numMessage:(NSString*)message showOnVC:(UIViewController*)viewController handler:(cancelBlock)handler;

-(void)showTitle:(NSString*)title numMessage:(NSString*)message showOnVC:(UIViewController*)viewController handlerMsg:(NSString*)handlerMsg handler:(cancelBlock)handler confirmMsg:(NSString*)confirmMsg confirm:(confirm)confirm;

-(void)showTitle:(NSString*)title message:(NSString*)message showOnVC:(UIViewController*)viewController handler:(cancelBlock)handler;

-(void)hiddeAlertCompletion:(completion)completion;

+(void)showError:(NSString*)message viewController:(UIViewController*) vc Completion:(completion)completion;

-(void)showTitle:(NSString*)title message:(NSString*)message showOnVC:(UIViewController*)viewController;

+(void)showDisconnect:(NSString*)message viewController:(UIViewController*) vc Completion:(completion)completion;
+(void)showSuccess:(NSString*)message viewController:(UIViewController*) vc Completion:(completion)completion;
@end
