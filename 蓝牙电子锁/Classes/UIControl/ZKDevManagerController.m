//
//  ZKDevManagerController.m
//  蓝牙电子锁
//
//  Created by mosaic on 2018/1/12.
//  Copyright © 2018年 mosaic. All rights reserved.
//

#import "ZKDevManagerController.h"
#import "ZKTableViewCell.h"
#import "ZKKeyManageController.h"
#import "ZKUpgradeViewController.h"
#import "ZKKeyboardLockController.h"
#import "ZKAboutBleController.h"
@interface ZKDevManagerController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation ZKDevManagerController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
}
-(void)createUI{
    self.title = @"管理设备";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.view setBackgroundColor:[UIColor colorWithHexString:@"F1F2F1"]];
    [self.tableview setBackgroundColor:[UIColor clearColor]];
    [self.tableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
}
#pragma mark ==UITableViewDataSource==

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 4;
}

- (ZKTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * identify = @"ZKDevManagerController";
    ZKTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[ZKTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
   
    if (indexPath.row==0) {
        [cell.iconImgV setImage:[UIImage imageNamed:@"键盘开锁图标.png"]];
        [cell.titleLabel setText:[NSString stringWithFormat:@"键盘开锁管理"]];
    }else if (indexPath.row==1){
        [cell.iconImgV setImage:[UIImage imageNamed:@"钥匙管理.png"]];
        [cell.titleLabel setText:[NSString stringWithFormat:@"电子钥匙管理"]];
    }else if (indexPath.row==2){
        [cell.iconImgV setImage:[UIImage imageNamed:@"升级图标.png"]];
        [cell.titleLabel setText:[NSString stringWithFormat:@"在线升级"]];
    }else{
        [cell.iconImgV setImage:[UIImage imageNamed:@"关于.png"]];
        [cell.titleLabel setText:[NSString stringWithFormat:@"关于"]];
    }
    [cell.titleLabel sizeToFit];
    [cell.accImgV setImage:[UIImage imageNamed:@"下一级按钮.png"]];
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return relative_h(150);
}
#pragma mark ==UITableViewDelegate==
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        ZKKeyboardLockController *keyLockVC = [[ZKKeyboardLockController alloc]init];
        keyLockVC.perip = self.perip;
        [self.navigationController pushViewController:keyLockVC animated:YES];
    }
    if (indexPath.row==1) {
        ZKKeyManageController *keyManagerVC = [[ZKKeyManageController alloc]init];
        keyManagerVC.perip = self.perip;
        [self.navigationController pushViewController:keyManagerVC animated:YES];
    }
    if (indexPath.row==2) {
        ZKUpgradeViewController*UpgradeVC = [[ZKUpgradeViewController alloc]init];
        UpgradeVC.peri = self.perip;
        [self.navigationController pushViewController:UpgradeVC animated:YES];
    }
    if (indexPath.row==3) {
        ZKAboutBleController*aboutBleVC = [[ZKAboutBleController alloc]init];
        aboutBleVC.peri = self.perip;
        [self.navigationController pushViewController:aboutBleVC animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)dealloc{
    ZKLog(@"ZKDevManagerController释放了");
}
@end
