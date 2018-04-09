//
//  ZKEmp2Button.m
//  蓝牙电子锁
//
//  Created by mosaic on 2017/12/14.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import "ZKEmp2Button.h"
@interface ZKEmp2Button ()
@property (nonatomic,weak)ZKButton *button;
@property (nonatomic,weak)UIImageView *iconImgV;
@end
@implementation ZKEmp2Button

-(instancetype)init{
    self = [super init];
    if (self) {
        ZKButton *button = [[ZKButton alloc]init];
        [self addSubview:button];
        self.button = button;
        
        UILabel*titileLabel = [[UILabel alloc]init];
        titileLabel.font = LabelFount(14);
        [titileLabel setTextColor:[UIColor blackColor]];
        [self addSubview:titileLabel];
        self.tLabel = titileLabel;
        
        UILabel *detailLabel = [[UILabel alloc]init];
        detailLabel.font = LabelFount(14);
        [detailLabel setTextColor:[UIColor blackColor]];

        [self addSubview:detailLabel];
        self.dLabel = detailLabel;
        
        UIImageView *iconImgV = [[UIImageView alloc]init];
        [iconImgV setImage:[UIImage imageNamed:@"下一级按钮.png"]];
        [self addSubview:iconImgV];
        self.iconImgV = iconImgV;
    }
    return self;
}
-(void)setFrame:(CGRect)frame{

    [self.button setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self.iconImgV setFrame:CGRectMake(frame.size.width-relative_w(80)-relative_w(29), 0, relative_w(29), relative_h(51))];
    self.iconImgV.centerY = frame.size.height/2;
    [self.dLabel sizeToFit];
    [self.tLabel sizeToFit];
    self.tLabel.x = rel_View_w(81, frame.size.width);
    self.tLabel.centerY = frame.size.height/2;
    self.dLabel.x =self.iconImgV.x - relative_w(40)-self.dLabel.width;
    self.dLabel.centerY = frame.size.height/2;
    [super setFrame:frame];
}

-(void)refresh{
    [self setFrame:self.frame];

}

- (void)addTarget:(nullable id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents{
    [self.button addTarget:target action:action forControlEvents:controlEvents];
}


@end
