//
//  ZKTableViewCell.h
//  蓝牙电子锁
//
//  Created by mosaic on 2017/12/13.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZKTableViewCell : UITableViewCell
@property   (nonatomic,weak) UIImageView *iconImgV;
@property   (nonatomic,weak) UILabel *titleLabel;
@property   (nonatomic,weak) UIImageView *accImgV;
@property   (nonatomic,weak) UIView *lineView;
@property   (nonatomic,weak)UIView *selColorView;
@end
