//
//  ZKMainTableCell.h
//  蓝牙电子锁
//
//  Created by mosaic on 2017/12/15.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZKMainTableCell : UITableViewCell

@property (nonatomic,copy)NSString *nameStr;
@property (nonatomic,copy)NSString *detailStr;

@property (nonatomic,weak)UIImageView *accImgV;
@property (nonatomic,weak)UIVisualEffectView * effe;
@end
