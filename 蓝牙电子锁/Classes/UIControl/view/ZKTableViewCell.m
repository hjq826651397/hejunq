//
//  ZKTableViewCell.m
//  蓝牙电子锁
//
//  Created by mosaic on 2017/12/13.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import "ZKTableViewCell.h"

@implementation ZKTableViewCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *view = [[UIView alloc]init];
        UIImageView *iconImgV = [[UIImageView alloc]init];
        UILabel *titlelabel = [[UILabel alloc]init];
        UIImageView *accImgV = [[UIImageView alloc]init];
        [self addSubview:iconImgV];
        [self addSubview:titlelabel];
        [self addSubview:accImgV];
        [self addSubview:view];
        self.lineView = view;
        self.iconImgV = iconImgV;
        self.titleLabel = titlelabel;
        self.accImgV = accImgV;
    }
    return self;
}



-(void)drawRect:(CGRect)rect{
    
    [self.lineView setFrame:CGRectMake(0, 0, rect.size.width, relative_h(20))];
    [self.lineView setBackgroundColor:[UIColor colorWithHexString:@"F1F2F1"]];
    
    [self.iconImgV setFrame:CGRectMake(relative_w(80), (rect.size.height-relative_w(89))/2+CGRectGetMaxY(self.lineView.frame), relative_w(89), relative_h(89))];
    self.iconImgV.centerY =  (rect.size.height+CGRectGetMaxY(self.lineView.frame))/2;
    [self.titleLabel setFont:LabelFount(13)];
    [self.titleLabel setFrame:CGRectMake(relative_w(35)+CGRectGetMaxX(self.iconImgV.frame), 0, 0, 0)];
    [self.titleLabel sizeToFit];
    self.titleLabel.centerY = self.iconImgV.centerY;
    
    [self.accImgV setFrame:CGRectMake(rect.size.width-relative_w(80)-relative_w(29), 0, relative_w(29), relative_h(51))];
    self.accImgV.centerY = self.iconImgV.centerY;
    

    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
