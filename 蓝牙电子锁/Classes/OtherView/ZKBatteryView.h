//
//  ZKBatteryView.h
//  仿苹果电池
//
//  Created by mosaic on 2018/1/18.
//  Copyright © 2018年 mosaic. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, ZKBatteryType) {
    ZKBatteryHorizontalType = 0,
    ZKBatteryVerticalType
};
@interface ZKBatteryView : UIView
@property(nonatomic,assign)CGFloat ratio;
@property(nonatomic,strong)UIColor* backColor;
@property(nonatomic,strong)UIColor* progressColor;
@property(nonatomic,strong)UIColor* bordColor;

@end
