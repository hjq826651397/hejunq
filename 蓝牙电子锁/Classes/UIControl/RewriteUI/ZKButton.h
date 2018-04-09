//
//  ZKButton.h
//  蓝牙电子锁
//
//  Created by mosaic on 2017/12/12.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZKButton : UIButton

@property (nonatomic,assign)CGRect imageFrame;
@property (nonatomic,assign)CGRect titleFrame;


-(void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)UIControlState;
@end
