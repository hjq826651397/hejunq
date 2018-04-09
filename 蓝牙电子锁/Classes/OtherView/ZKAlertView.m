//
//  ZKAlertView.m
//  MosaicLightBLE
//
//  Created by mosaic on 2017/6/6.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import "ZKAlertView.h"
@interface ZKAlertView ()

@end
@implementation ZKAlertView


singleton_implementation(ZKAlertView)

-(void)showTitle:(NSString*)title message:(NSString*)message showOnVC:(UIViewController*)viewController{
    self.alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIViewController *customVC = [[UIViewController alloc] init];
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    [customVC.view addSubview:spinner];
    [customVC.view addConstraint:[NSLayoutConstraint
                                  constraintWithItem: spinner
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:customVC.view
                                  attribute:NSLayoutAttributeCenterX
                                  multiplier:1.0f
                                  constant:0.0f]];
    
    [customVC.view addConstraint:[NSLayoutConstraint
                                  constraintWithItem: spinner
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:customVC.view
                                  attribute:NSLayoutAttributeCenterY
                                  multiplier:1.0f
                                  constant:-10.0f]];
    
    
    [self.alertVC setValue:customVC forKey:@"contentViewController"];
    
    [viewController presentViewController: self.alertVC
                                 animated: true
                               completion: nil];
}


-(void)showTitle:(NSString*)title numMessage:(NSString*)message showOnVC:(UIViewController*)viewController handler:(cancelBlock)handler{
    
    self.alertVC = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [self.alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (handler) {
            handler();
        }
    }]];
    UIViewController *customVC = [[UIViewController alloc] init];
    UILabel *labelText = [[UILabel alloc]init];
    labelText.text = message;
    labelText.font = [UIFont systemFontOfSize:40];
    [labelText setContentMode:UIViewContentModeCenter];
    [labelText sizeToFit];
    [customVC.view addSubview:labelText];
    [customVC.view addConstraint:[NSLayoutConstraint
                                  constraintWithItem: labelText
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:customVC.view
                                  attribute:NSLayoutAttributeCenterX
                                  multiplier:1.0f
                                  constant:0.0f]];
    
    [customVC.view addConstraint:[NSLayoutConstraint
                                  constraintWithItem: labelText
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:customVC.view
                                  attribute:NSLayoutAttributeCenterY
                                  multiplier:1.0f
                                  constant:-10.0f]];
    
    
    [self.alertVC setValue:customVC forKey:@"contentViewController"];
    
    [viewController presentViewController: self.alertVC
                                 animated: true
                               completion: nil];
}

-(void)showTitle:(NSString*)title numMessage:(NSString*)message showOnVC:(UIViewController*)viewController handlerMsg:(NSString*)handlerMsg handler:(cancelBlock)handler confirmMsg:(NSString*)confirmMsg confirm:(confirm)confirm{
    self.alertVC = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [self.alertVC addAction:[UIAlertAction actionWithTitle:handlerMsg style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (handler) {
            handler();
        }
    }]];
    [self.alertVC addAction:[UIAlertAction actionWithTitle:confirmMsg style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (confirm) {
            confirm();
        }
    }]];
    UIViewController *customVC = [[UIViewController alloc] init];
    UILabel *labelText = [[UILabel alloc]init];
    labelText.text = message;
    labelText.font = [UIFont systemFontOfSize:40];
    [labelText setContentMode:UIViewContentModeCenter];
    [labelText sizeToFit];
    [customVC.view addSubview:labelText];
    [customVC.view addConstraint:[NSLayoutConstraint
                                  constraintWithItem: labelText
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:customVC.view
                                  attribute:NSLayoutAttributeCenterX
                                  multiplier:1.0f
                                  constant:0.0f]];
    
    [customVC.view addConstraint:[NSLayoutConstraint
                                  constraintWithItem: labelText
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:customVC.view
                                  attribute:NSLayoutAttributeCenterY
                                  multiplier:1.0f
                                  constant:-10.0f]];
    
    
    [self.alertVC setValue:customVC forKey:@"contentViewController"];
    
    [viewController presentViewController: self.alertVC
                                 animated: true
                               completion: nil];
}


-(void)showTitle:(NSString*)title message:(NSString*)message showOnVC:(UIViewController*)viewController handler:(cancelBlock)handler{
    
    self.alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [self.alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (handler) {
            handler();
        }
    }]];
    UIViewController *customVC = [[UIViewController alloc] init];
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    [customVC.view addSubview:spinner];
    [customVC.view addConstraint:[NSLayoutConstraint
                                  constraintWithItem: spinner
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:customVC.view
                                  attribute:NSLayoutAttributeCenterX
                                  multiplier:1.0f
                                  constant:0.0f]];
    
    [customVC.view addConstraint:[NSLayoutConstraint
                                  constraintWithItem: spinner
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:customVC.view
                                  attribute:NSLayoutAttributeCenterY
                                  multiplier:1.0f
                                  constant:-10.0f]];
    
    
    [self.alertVC setValue:customVC forKey:@"contentViewController"];
    
    [viewController presentViewController: self.alertVC
                     animated: true
                   completion: nil];
}


-(void)hiddeAlertCompletion:(completion)completion{
    if (self.alertVC) {
        [self.alertVC dismissViewControllerAnimated:YES completion:^{
            if (completion) {
                self.alertVC = nil;
                completion();
            }
        }];
    }
}

+(void)showError:(NSString*)message viewController:(UIViewController*) vc Completion:(completion)completion{
    ZKAlertView*zkalert = [ZKAlertView sharedZKAlertView];
    zkalert.alertVC = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIViewController *customVC = [[UIViewController alloc] init];
    
    UIImageView *spinner = [[UIImageView alloc]init];
    [spinner setImage:[UIImage imageNamed:@"error.png"]];
    [spinner setFrame:CGRectMake(0, 0, 30, 30)];
    [customVC.view addSubview:spinner];
    [customVC.view addConstraint:[NSLayoutConstraint
                                  constraintWithItem: spinner
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:customVC.view
                                  attribute:NSLayoutAttributeCenterX
                                  multiplier:1.0f
                                  constant:0.0f]];
    
    
    
    [customVC.view addConstraint:[NSLayoutConstraint
                                  constraintWithItem: spinner
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:customVC.view
                                  attribute:NSLayoutAttributeCenterY
                                  multiplier:1.0f
                                  constant:-10.0f]];
    
    
    [zkalert.alertVC setValue:customVC forKey:@"contentViewController"];
    
    [vc presentViewController:zkalert.alertVC animated:YES completion:^{
        
    }];
    
    [zkalert performSelector:@selector(hiddeAlertCompletion:) withObject:completion afterDelay:1.5];
}

+(void)showDisconnect:(NSString*)message viewController:(UIViewController*) vc Completion:(completion)completion{
    ZKAlertView*zkalert = [ZKAlertView sharedZKAlertView];
    zkalert.alertVC = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [zkalert.alertVC  addAction:[UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (completion) {
            completion();
        }
    }]];
    
    
    UIViewController *customVC = [[UIViewController alloc] init];
    

    UIImageView *spinner = [[UIImageView alloc]init];
    [spinner setImage:[UIImage imageNamed:@"error.png"]];
    [spinner setFrame:CGRectMake(0, 0, 30, 30)];
    [customVC.view addSubview:spinner];
    [customVC.view addConstraint:[NSLayoutConstraint
                                  constraintWithItem: spinner
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:customVC.view
                                  attribute:NSLayoutAttributeCenterX
                                  multiplier:1.0f
                                  constant:0.0f]];
    
    [customVC.view addConstraint:[NSLayoutConstraint
                                  constraintWithItem: spinner
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:customVC.view
                                  attribute:NSLayoutAttributeCenterY
                                  multiplier:1.0f
                                  constant:-10.0f]];
    
    
    [zkalert.alertVC setValue:customVC forKey:@"contentViewController"];
    
    [vc presentViewController:zkalert.alertVC animated:YES completion:^{
        
    }];
}


+(void)showSuccess:(NSString*)message viewController:(UIViewController*) vc Completion:(completion)completion{
    ZKAlertView*zkalert = [ZKAlertView sharedZKAlertView];
    zkalert.alertVC = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIViewController *customVC = [[UIViewController alloc] init];
    
    UIImageView *spinner = [[UIImageView alloc]init];
    [spinner setImage:[UIImage imageNamed:@"success.png"]];
    [spinner setFrame:CGRectMake(0, 0, 30, 30)];
    [customVC.view addSubview:spinner];
    [customVC.view addConstraint:[NSLayoutConstraint
                                  constraintWithItem: spinner
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:customVC.view
                                  attribute:NSLayoutAttributeCenterX
                                  multiplier:1.0f
                                  constant:0.0f]];
    
    
    
    [customVC.view addConstraint:[NSLayoutConstraint
                                  constraintWithItem: spinner
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:customVC.view
                                  attribute:NSLayoutAttributeCenterY
                                  multiplier:1.0f
                                  constant:-10.0f]];
    
    
    [zkalert.alertVC setValue:customVC forKey:@"contentViewController"];
    
    [vc presentViewController:zkalert.alertVC animated:YES completion:^{
        
    }];
    
    [zkalert performSelector:@selector(hiddeAlertCompletion:) withObject:completion afterDelay:1.5];
}


@end
