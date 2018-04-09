//
//  ZKButton.m
//  蓝牙电子锁
//
//  Created by mosaic on 2017/12/12.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import "ZKButton.h"
@interface ZKButton ()
@property (nonatomic,strong)UIColor* hColor;
@property (nonatomic,strong)UIColor* nColor;

@end
@implementation ZKButton

-(instancetype)init{
    self = [super init];
    if (self) {
        [self addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    UIButton *button = (UIButton *)object;
    if ([keyPath isEqualToString:@"highlighted"]) {
        if (button.highlighted) {
            if (self.hColor) {
                [button setBackgroundColor:self.hColor];
            }
            return;
        }
        if (self.nColor) {
            [button setBackgroundColor:self.nColor];
        }
    }
}
-(void)dealloc{
    [self removeObserver:self forKeyPath:@"highlighted"];
}

-(void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)UIControlState{
    if (UIControlState == UIControlStateNormal ) {
        [self setBackgroundColor:backgroundColor];
        self.nColor = backgroundColor;
    }
    if (UIControlState == UIControlStateHighlighted) {
        self.hColor = backgroundColor;
    }
}

-(void)setImageFrame:(CGRect)imageFrame{
    _imageFrame = imageFrame;
}
-(void)setTitleFrame:(CGRect)titleFrame{
    _titleFrame = titleFrame;
}


- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    if (self.imageFrame.size.width>0&&self.imageFrame.size.height>0) {
        return self.imageFrame;//图片的位置大小
    }else{
        return [super imageRectForContentRect:contentRect];
    }
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    if (self.titleFrame.size.width>0&&self.titleFrame.size.height>0) {
        return self.titleFrame;//文本的位置大小
    }else{
        return [super titleRectForContentRect:contentRect];
    }
}

@end
