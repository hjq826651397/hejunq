//
//  ZKProgressView.h
//  进度条
//
//  Created by mosaic on 2017/6/21.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, ZKProgressType) {
    ZKProgressHorizontalType = 0,
    ZKProgressVerticalType
    
};
@interface ZKProgressView : UIView

@property(nonatomic,assign)CGFloat ratio;
@property(nonatomic,strong)UIColor* baseColor;
@property(nonatomic,strong)UIColor* progressColor;

@property(nonatomic,weak)UIView *progressView;

-(instancetype)initWithFrame:(CGRect)frame baseColor:(UIColor*)baseColor progressColor:(UIColor*)progressColor ratio:(CGFloat)ratio withType:(ZKProgressType)type;



@end
