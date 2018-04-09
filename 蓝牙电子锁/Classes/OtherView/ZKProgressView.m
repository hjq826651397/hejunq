//
//  ZKProgressView.m
//  进度条
//
//  Created by mosaic on 2017/6/21.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import "ZKProgressView.h"
@interface ZKProgressView ()
@property(nonatomic,assign)ZKProgressType type;

@end
@implementation ZKProgressView


-(instancetype)initWithFrame:(CGRect)frame baseColor:(UIColor*)baseColor progressColor:(UIColor*)progressColor ratio:(CGFloat)ratio withType:(ZKProgressType)type{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor lightGrayColor]];
        self.baseColor = baseColor;
        self.progressColor = progressColor;
        self.ratio = ratio;
        self.type = type;
        UIView *progressView = [[UIView alloc]init];
        if (type == ZKProgressHorizontalType) {
            CGFloat progressView_H = frame.size.height*self.ratio;
            CGFloat progressView_Y =frame.size.height - progressView_H;
            [progressView setFrame:CGRectMake(0, progressView_Y, frame.size.width, progressView_H)];
        }else{
            CGFloat progressView_W = frame.size.width*self.ratio;
            CGFloat progressView_H =frame.size.height ;
            [progressView setFrame:CGRectMake(0,0,progressView_W, progressView_H)];
        }
       
        [progressView setBackgroundColor:self.progressColor];
        [self addSubview:progressView];
        self.progressView = progressView;
    }
    return self;
}


-(void)setRatio:(CGFloat)ratio{
    if (ratio>1) ratio=1;
    if (ratio<0) ratio=0;
    _ratio = ratio;
    if (self.type == ZKProgressHorizontalType) {
        CGFloat progressView_H = self.frame.size.height*ratio;
        CGFloat progressView_Y =self.frame.size.height - progressView_H;
        [UIView animateWithDuration:0.5 animations:^{
            [self.progressView setFrame:CGRectMake(0,progressView_Y, self.frame.size.width, progressView_H)];
        }];
    }else{
        CGFloat progressView_W = self.frame.size.width*ratio;
        CGFloat progressView_H =self.frame.size.height;
        [UIView animateWithDuration:0.5 animations:^{
            [self.progressView setFrame:CGRectMake(0,0, progressView_W, progressView_H)];
        }];
    }
    
    
}

-(void)setBaseColor:(UIColor *)baseColor{
    _baseColor = baseColor;
    [self setBackgroundColor:baseColor];
}

-(void)setProgressColor:(UIColor *)progressColor{
    _progressColor = progressColor;
    [self.progressView setBackgroundColor:progressColor];
}

@end
