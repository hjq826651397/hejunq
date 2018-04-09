//
//  ZKEmp2Button.h
//  蓝牙电子锁
//
//  Created by mosaic on 2017/12/14.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZKEmp2Button : UIView
@property (nonatomic,weak)UILabel * _Nullable tLabel;
@property (nonatomic,weak)UILabel * _Nullable dLabel;

- (void)addTarget:(nullable id)target action:(SEL _Nullable )action forControlEvents:(UIControlEvents)controlEvents;
-(void)refresh;

@end
