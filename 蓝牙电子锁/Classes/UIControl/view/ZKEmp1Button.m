//
//  ZKEmp1Button.m
//  蓝牙电子锁
//
//  Created by mosaic on 2017/12/14.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import "ZKEmp1Button.h"

@implementation ZKEmp1Button

-(instancetype)init{
    self = [super init];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithHexString:@"FF3956"] forState:UIControlStateNormal];
        [self setBackgroundColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [self.titleLabel setFont:LabelFount(15)];
        [self setClipsToBounds:YES];
    }
    return self;
}


-(void)drawRect:(CGRect)rect{
    [self.layer setCornerRadius:rect.size.height/2];
}

@end
