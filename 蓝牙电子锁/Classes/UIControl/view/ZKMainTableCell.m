//
//  ZKMainTableCell.m
//  蓝牙电子锁
//
//  Created by mosaic on 2017/12/15.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import "ZKMainTableCell.h"
@interface ZKMainTableCell ()

@property (nonatomic,weak)UILabel *nameLab;
@property (nonatomic,weak)UILabel *detailLab;
@end
@implementation ZKMainTableCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIBlurEffect * blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView * effe = [[UIVisualEffectView alloc]initWithEffect:blur];
        [self addSubview:effe];
        self.effe =effe;
        
        UILabel *nameLab = [[UILabel alloc]init];
        UILabel *detailLab = [[UILabel alloc]init];
        [detailLab setTextColor:[UIColor colorWithWhite:0.3 alpha:1]];

        UIImageView *accImgV = [[UIImageView alloc]init];
        [self addSubview:nameLab];
        [self addSubview:detailLab];
        [self addSubview:accImgV];
        self.nameLab = nameLab;
        self.detailLab = detailLab;
        self.accImgV = accImgV;
    }
    return self;
}


-(void)drawRect:(CGRect)rect{
    
    [self.effe setFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    
    [self.nameLab setFont:LabelFount(13)];
    [self.detailLab setFont:LabelFount(13)];
    [self.nameLab setFrame:CGRectMake(relative_w(43), 0, 0, 0)];
    [self.nameLab sizeToFit];
    self.nameLab.centerY = rect.size.height/2;
    
    [self.detailLab setFrame:CGRectMake(0, 0, 0, 0)];
    [self.detailLab sizeToFit];
    self.detailLab.centerY = rect.size.height/2;
    self.detailLab.x = rect.size.width - relative_w(83)-self.detailLab.width;
    
    CGFloat accImgV_W = relative_w(29);
    CGFloat accImgV_H = relative_h(51);
    CGFloat accImgV_x = rect.size.width - relative_w(33)-accImgV_W;
    [self.accImgV setFrame:CGRectMake(accImgV_x, 0, accImgV_W, accImgV_H)];
    self.accImgV.centerY = rect.size.height/2;
}


-(void)setNameStr:(NSString *)nameStr{
    _nameStr = nameStr;
    self.nameLab.text = nameStr;
    [self.nameLab setFrame:CGRectMake(relative_w(43), 0, 0, 0)];
    [self.nameLab sizeToFit];
    self.nameLab.centerY = self.height/2;
}


-(void)setDetailStr:(NSString *)detailStr{
    _detailStr = detailStr;
    self.detailLab.text = detailStr;
    [self.detailLab sizeToFit];
    self.detailLab.centerY = self.height/2;
    self.detailLab.x = self.width - relative_w(83)-self.detailLab.width;
}

@end
