//
//  ZKEmp3Button.h
//  蓝牙电子锁
//
//  Created by mosaic on 2017/12/14.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZKEmp3Button : UIView
@property (nonatomic,weak)UILabel  *tLabel;
@property (nonatomic,weak)UISwitch *autoUnlockSwitch;
@property (nonatomic,weak)UIButton *clickButton;
-(void)refresh;
@end
