//
//  ZKEmp3Button.m
//  蓝牙电子锁
//
//  Created by mosaic on 2017/12/14.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import "ZKEmp3Button.h"
@interface ZKEmp3Button ()
//@property (nonatomic,weak)ZKButton *button;


@end
@implementation ZKEmp3Button

-(instancetype)init{
    self = [super init];
    if (self) {
        ZKButton *button = [[ZKButton alloc]init];
        [self addSubview:button];
        self.clickButton = button;
        
        UILabel*tLabel = [[UILabel alloc]init];
        tLabel.font = LabelFount(14);
        [tLabel setTextColor:[UIColor blackColor]];
        [self addSubview:tLabel];
        self.tLabel = tLabel;
        
        UISwitch *autoUnlockSwitch = [[UISwitch alloc]init];
        [autoUnlockSwitch setOn:YES];
        [self addSubview:autoUnlockSwitch];
        self.autoUnlockSwitch = autoUnlockSwitch;
        
    }
    return self;
}


-(void)setFrame:(CGRect)frame{
    self.autoUnlockSwitch.x = frame.size.width - relative_w(80)-self.autoUnlockSwitch.width;
    self.autoUnlockSwitch.centerY = frame.size.height/2;
    
    [self.clickButton setFrame:CGRectMake(0, 0,self.autoUnlockSwitch.x, frame.size.height)];
    
    [self.tLabel sizeToFit];
    self.tLabel.x = rel_View_w(81, frame.size.width);
    self.tLabel.centerY = frame.size.height/2;
    
    [super setFrame:frame];
}

-(void)refresh{
    [self setFrame:self.frame];
}

@end
