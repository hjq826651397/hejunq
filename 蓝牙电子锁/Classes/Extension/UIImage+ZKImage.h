//
//  UIImage+ZKImage.h
//  MosaicLightBLE
//
//  Created by mosaic on 2017/6/5.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ZKImage)
+(UIImage *)OriginImage:(UIImage *)image scaleToSize:(CGSize)size;//改变图片大小
+(UIImage*)createRoundedRectImage:(UIImage*)image size:(CGSize)size radius:(NSInteger)r;//生成圆角图片
+ (UIImage*)createImageWithColor:(UIColor*)color;//颜色转图片
- (UIImage *)imageWithRoundedCornersSize:(float)cornerRadius;
@end
