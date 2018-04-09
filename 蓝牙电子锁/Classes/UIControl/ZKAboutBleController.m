//
//  ZKAboutBleController.m
//  蓝牙电子锁
//
//  Created by mosaic on 2018/1/16.
//  Copyright © 2018年 mosaic. All rights reserved.
//

#import "ZKAboutBleController.h"

@interface ZKAboutBleController ()
@property (nonatomic,weak)ZKButton *imageButton;
@end

@implementation ZKAboutBleController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
}

-(void)createUI{
    self.title = @"关于镶阳蓝牙锁";
    [self.view setBackgroundColor:[UIColor colorWithHexString:@"F1F2F1"]];

    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    NSString *icon = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
    CGFloat imageButton_w = relative_h(130);
    CGFloat imageButton_y = relative_h(110)+64;
    CGFloat imageButton_x = (ZKSCREEN_W-imageButton_w)/2;
    ZKButton *imageButton = [[ZKButton alloc]init];
    [imageButton setFrame:CGRectMake(imageButton_x, imageButton_y, imageButton_w, imageButton_w)];
    [imageButton setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    [imageButton setClipsToBounds:YES];
    [imageButton.layer setCornerRadius:8];
    [self.view addSubview:imageButton];
    self.imageButton = imageButton;
    
    UILabel *nameLabel = [[UILabel alloc]init];
    nameLabel .text = @"镶阳蓝牙锁";
    nameLabel.font = LabelFount(13);
    [nameLabel setFrame:CGRectMake(0, relative_h(10)+CGRectGetMaxY(imageButton.frame), 0, 0)];
    [nameLabel sizeToFit];
    nameLabel.centerX = ZKSCREEN_W/2;
    [self.view addSubview:nameLabel];
    
    UIView *sysView = [[UIView alloc]init];
    [sysView setBackgroundColor:[UIColor whiteColor]];
    [sysView setFrame:CGRectMake(0, CGRectGetMaxY(nameLabel.frame)+relative_h(110), ZKSCREEN_W, relative_h(130))];
    [self.view addSubview:sysView];
    
    UILabel *sysLabel = [[UILabel alloc]init];
    [sysLabel setText:@"系统版本"];
    sysLabel.x = relative_w(80);
    [sysLabel sizeToFit];
    [sysView addSubview:sysLabel];
    sysLabel.centerY = sysView.height/2;

    UILabel *sysVersionLabel = [[UILabel alloc]init];
    [sysVersionLabel setFont:LabelFount(14)];
    [sysVersionLabel setText:self.peri.firmware];
    [sysVersionLabel sizeToFit];
    [sysView addSubview:sysVersionLabel];
    sysVersionLabel.x = ZKSCREEN_W - sysVersionLabel.width-relative_w(50);
    sysVersionLabel.centerY = sysView.height/2;
}

@end
