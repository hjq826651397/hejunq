//
//  ZKBatteryView.m
//  仿苹果电池
//
//  Created by mosaic on 2018/1/18.
//  Copyright © 2018年 mosaic. All rights reserved.
//

#define proportion_header (3.0/61.0)
#define proportion_space  (1.0/61.0)
#define proportion_body  (57.0/61.0)
#define wide  270.0
#define high  110.0
#define proportion_header_H (38.0/110)
#define radian_body (15.0/110.0)
//#define radian_header (12.0/38.0)

#import "ZKBatteryView.h"
@interface ZKBatteryView  ()
@property(nonatomic,weak)UIView *batteryBodyView;
@property(nonatomic,weak)UIView *batteryHeaderView;

@property(nonatomic,weak)UIView *bodyBackgroundView;
@property(nonatomic,weak)UIView *headerBackgroundView;

@end
@implementation ZKBatteryView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _ratio = 0;
        _backColor = [UIColor whiteColor];
        _bordColor = [UIColor blackColor];
        _progressColor = [UIColor greenColor];
        //背景
        UIView *bodyBackgroundView = [[UIView alloc]init];
        [self addSubview:bodyBackgroundView];
        self.bodyBackgroundView = bodyBackgroundView;
        
        UIView *headerBackgroundView = [[UIView alloc]init];
        [self addSubview:headerBackgroundView];
        self.headerBackgroundView = headerBackgroundView;
        
   
        UIView *batteryBodyView = [[UIView alloc]init];
        [self.bodyBackgroundView addSubview:batteryBodyView];
        self.batteryBodyView = batteryBodyView;
        
        UIView *batteryHeaderView = [[UIView alloc]init];
        [self.headerBackgroundView addSubview:batteryHeaderView];
        self.batteryHeaderView = batteryHeaderView;
        
        
        
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    self.bodyBackgroundView.backgroundColor = _backColor;
    self.headerBackgroundView.backgroundColor = _backColor;
    self.bodyBackgroundView.layer.borderWidth = 1;
    self.bodyBackgroundView.layer.borderColor = [_bordColor CGColor];
    self.bodyBackgroundView.clipsToBounds=YES;
    self.batteryBodyView.backgroundColor = _progressColor;
    self.batteryHeaderView.backgroundColor = _progressColor;

    
    [self.bodyBackgroundView setFrame:CGRectMake(0, 0, rect.size.width*proportion_body, rect.size.height)];
    CGFloat batteryView_w = proportion_header*rect.size.width;
    CGFloat batteryView_h = proportion_header_H*rect.size.height;
    [self.headerBackgroundView setFrame:CGRectMake(rect.size.width-batteryView_w, (rect.size.height-batteryView_h)/2, batteryView_w, batteryView_h)];
    [self.bodyBackgroundView.layer setCornerRadius:radian_body*rect.size.height];
    //圆角
    CGFloat batteryView_Radius =batteryView_w;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.headerBackgroundView.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(batteryView_Radius,batteryView_Radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.headerBackgroundView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.headerBackgroundView.layer.mask = maskLayer;
    
    //添加border
    CAShapeLayer*borderLayer = [[CAShapeLayer alloc]init];
    borderLayer.frame = self.headerBackgroundView.bounds;
    borderLayer.path = maskPath.CGPath;
    borderLayer.lineWidth = 2;
    borderLayer.strokeColor = [_bordColor CGColor];
    borderLayer.fillColor =[[UIColor clearColor] CGColor];
    NSArray *layers = [self.headerBackgroundView.layer sublayers];
    
    if ([layers.lastObject isKindOfClass:[CAShapeLayer class]]) {
        [layers.lastObject removeFromSuperlayer];
    }
    [self.headerBackgroundView.layer addSublayer:borderLayer];
    CGFloat progress_body_W;
    CGFloat progress_header_W;
    if (self.ratio<=0.95) {
        progress_body_W = self.ratio/0.95*self.bodyBackgroundView.frame.size.width;
        progress_header_W = 0;
    }else{
        progress_body_W = self.bodyBackgroundView.frame.size.width;
        CGFloat headr_mu =(self.ratio - 0.95)/0.05;
        progress_header_W = headr_mu*self.headerBackgroundView.frame.size.width;
    }
    [self.batteryBodyView setFrame:CGRectMake(0, 0, progress_body_W, self.bodyBackgroundView.frame.size.height)];
    [self.batteryHeaderView setFrame:CGRectMake(0, 0, progress_header_W, self.headerBackgroundView.frame.size.height)];

    
    NSLog(@"drawRect 被调用了");
}


-(void)setRatio:(CGFloat)ratio{
    _ratio = ratio;
    CGFloat progress_body_W;
    CGFloat progress_header_W;
    if (self.ratio<=0.95) {
        progress_body_W = self.ratio/0.95*self.bodyBackgroundView.frame.size.width;
        progress_header_W = 0;
    }else{
        progress_body_W = self.bodyBackgroundView.frame.size.width;
        CGFloat headr_mu =(self.ratio - 0.95)/0.05;
        progress_header_W = headr_mu*self.headerBackgroundView.frame.size.width;
    }
        [self.batteryBodyView setFrame:CGRectMake(0, 0, progress_body_W, self.bodyBackgroundView.frame.size.height)];
        [self.batteryHeaderView setFrame:CGRectMake(0, 0, progress_header_W, self.headerBackgroundView.frame.size.height)];
}

-(void)setBackColor:(UIColor *)backColor{
    _backColor = backColor;
    [self setNeedsDisplay];
}

-(void)setBordColor:(UIColor *)bordColor{
    _bordColor = bordColor;
    [self setNeedsDisplay];
}

-(void)setProgressColor:(UIColor *)progressColor{
    _progressColor = progressColor;
    [self setNeedsDisplay];
}

@end
