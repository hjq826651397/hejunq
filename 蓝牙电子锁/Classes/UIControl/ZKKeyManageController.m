//
//  ZKKeyManageController.m
//  蓝牙电子锁
//
//  Created by mosaic on 2017/12/16.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import "ZKKeyManageController.h"
#import "ZKUpgradeViewController.h"
#import "ZKEmp1Button.h"
#import "ZKTableViewCell.h"
@interface ZKKeyManageController ()<UITableViewDelegate,UITableViewDataSource,ZKPeripheralDelegate,ZKBleManagerDelegate>
@property (nonatomic,weak)ZKEmp1Button *codeButton;
@property (nonatomic,weak)ZKEmp1Button *upgradeButton;
@property (nonatomic,weak)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *keyArray;
@property (nonatomic,weak)ZKBleManager *bleManager;
@end

@implementation ZKKeyManageController{
    NSIndexPath *_deleteIndexPath;
    BOOL _isAutoConnect;//控制此界面的自动连接
    
}

-(NSMutableArray *)keyArray{
    if (!_keyArray) {
        _keyArray = [NSMutableArray array];
    }
    return _keyArray;
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _isAutoConnect = YES;
    self.perip.peripheralDelegate = self;
    self.bleManager = [ZKBleManager sharedZKBleManager];
    self.bleManager.scanType = BLEAutoConnectOnVC;
    self.bleManager.centralDelegate = self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
    [self reloadPeri];

}
-(void)createUI{
    self.title = @"钥匙管理";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];

    [self.view setBackgroundColor:[UIColor colorWithHexString:@"F1F2F1"]];
    ZKEmp1Button *codeButton = [[ZKEmp1Button alloc]init];
    [codeButton setFrame:CGRectMake(0, ZKSCREEN_H-relative_h(420), relative_w(612), relative_h(110))];
    codeButton.centerX = ZKSCREEN_W/2;
    [codeButton setBackgroundColor:[UIColor colorWithHexString:@"000000"] forState:UIControlStateNormal];
    [codeButton setTitle:@"生成配匙码" forState:UIControlStateNormal];
    [self.view addSubview:codeButton];
    self.codeButton = codeButton;
    [codeButton setHidden:YES];
    
    ZKEmp1Button *upgradeButton = [[ZKEmp1Button alloc]init];
    [upgradeButton setFrame:CGRectMake(0,CGRectGetMaxY(codeButton.frame)+relative_h(50) , relative_w(612), relative_h(110))];
    upgradeButton.centerX = ZKSCREEN_W/2;
    [upgradeButton setTitle:@"生成配匙码" forState:UIControlStateNormal];
    [self.view addSubview:upgradeButton];
    self.upgradeButton = upgradeButton;
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, ZKSCREEN_W, ZKSCREEN_H-64-relative_h(420)) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    //事件 生成配匙码
//    [self.codeButton addTarget:self action:@selector(codeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    //在线升级
    [self.upgradeButton addTarget:self action:@selector(codeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    //查询钥匙
    [self.perip sendQueryKeyCode];
}

-(void)codeButtonClick:(ZKEmp1Button*)sender{
    if (self.perip.peripheral.state == CBPeripheralStateConnected) {
        [self.perip sendCodeForAddKey];
    }else{
        [self.bleManager connectPeripheral:self.perip.peripheral];
        [[ZKAlertView sharedZKAlertView]showTitle:@"提示" message:@"正在连接蓝牙" showOnVC:self handler:^{
        }];
    }
}

-(void)upgradeButtonClick:(ZKEmp1Button*)sender{
//    ZKUpgradeViewController*UpgradeVC = [[ZKUpgradeViewController alloc]init];
//    UpgradeVC.peri = self.perip;
//    [self.navigationController pushViewController:UpgradeVC animated:YES];
}

-(void)reloadPeri{
    if (self.keyArray.count<1) {
        [self.perip sendQueryKeyCode];
        [self performSelector:@selector(reloadPeri) withObject:nil afterDelay:5];
    }else{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadPeri) object:nil];
    }
}
#pragma mark ==UITableViewDataSource==

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    if (self.keyArray.count<1) {
//        [self reloadPeri];
//    }
    return self.keyArray.count;
}

- (ZKTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * identify = @"ZKKeyManageController";
    ZKTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[ZKTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    NSData*data = self.keyArray[indexPath.row];
    int keyNum = 0;
    [data getBytes:&keyNum range:NSMakeRange(0, 1)];
    ZKLog(@"%@  %@ %d",self.keyArray,data,keyNum);
    [cell.iconImgV setImage:[UIImage imageNamed:@"钥匙管理.png"]];
    if (indexPath.row==0) {
        [cell.titleLabel setText:[NSString stringWithFormat:@"管理员钥匙"]];
    }else{
        [cell.titleLabel setText:[NSString stringWithFormat:@"钥匙%d",keyNum]];
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
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
//        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:nil];
    }else{
        [self.perip sendDeleteCode:self.keyArray[indexPath.row]];
        _deleteIndexPath = indexPath;
    }
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        return UITableViewCellEditingStyleNone;
    }else{
        return UITableViewCellEditingStyleDelete;
    }
    
}
/**
 *  修改Delete按钮文字为“删除”
 */
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        return nil;
    }
    return @"删除";
}
#pragma mark BLEManager
//扫描到设备
-(void)customBleDidDiscoverPeripheral:(ZKPeripheral*)per {
    if ([self.perip.peripheral isEqual:per.peripheral]) {

        if (_isAutoConnect ) {
            [self.bleManager connectPeripheral:per.peripheral];
        }
    }
}

//连接成功
- (void)customBleDidConnectPeripheral:(ZKPeripheral *)peripheral{
    if ([self.perip.peripheral isEqual:peripheral.peripheral]) {
        peripheral.peripheralDelegate = self;
        [[ZKAlertView sharedZKAlertView] hiddeAlertCompletion:^{}];
        self.perip = peripheral;
        [self reloadPeri];
    }
}

////Peripherals断开连接
//- (void)customBleDidDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
//    if ([self.perip.peripheral isEqual:peripheral]) {
//        if (_isAutoConnect) {
//            [self.bleManager connectPeripheral:peripheral];
//        }
//    }
//}

#pragma mark == bledelegate ==
//收到订阅通知
-(void)customPeripheral:(ZKPeripheral*)peripheral NotiyCode:(ZKPeripheralCode)notiyCode value:(NSData*)value error:(NSError *)error{
    
    if (notiyCode==PeripheralNotiyOnceKeyProduct) {
//        NSString*keycode = [[NSString alloc]initWithData:value encoding:NSASCIIStringEncoding];;
        int res = 0 ;
        [value getBytes:&res length:sizeof(int)];
        int ces = 0 ;
        [value getBytes:&ces length:sizeof(int)];

        
        ZKLog(@"%@ %d %d",value,res,ces);
        
        NSString*resStr = [NSString stringWithFormat:@"%d",res];
        [[ZKAlertView sharedZKAlertView]showTitle:@"配匙码" numMessage:resStr showOnVC:self handler:^{
            _isAutoConnect = YES;
            [self.bleManager connectPeripheral:peripheral.peripheral];
        }];
        [[ZKBleManager sharedZKBleManager]disConnectPeripheral:self.perip.peripheral];
        _isAutoConnect = NO;
        
    }else if (notiyCode==PeripheralNotiyKeyisFull){
        [ZKAlertView showError:@"钥匙已满" viewController:self Completion:^{
            
        }];
    }else if (notiyCode==PeripheralNotiyReadKeySuccess){//查询钥匙列表成功
        ZKLog(@"查询钥匙列表成功");
        //读取钥匙列表
        [peripheral readAllKey];

    }else if (notiyCode==PeripheralNotiyDeleteKey){//删除钥匙成功
        ZKLog(@"删除钥匙成功");
        if (_deleteIndexPath) {
            // 删除模型
            [self.keyArray removeObjectAtIndex:_deleteIndexPath.row];
            // 刷新
            [self.tableView deleteRowsAtIndexPaths:@[_deleteIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            _deleteIndexPath = nil;
        }
    }
}

- (void)customPeripheral:(ZKPeripheral*)peripheral DidUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if ([characteristic isEqual:peripheral.chc_UpdateTime]) {
        ZKLog(@"钥匙：%@",characteristic.value);
        NSData*data = characteristic.value;
        //截取第一个字节判断类型
        Byte buff[data.length];
        [data getBytes:buff length:data.length];
        if (buff[0]==9) {//返回电子钥匙数据
            //buff[1]电子钥匙数量
            NSMutableArray *tempArray = [NSMutableArray array];
            for (int i=0; i<buff[1]; i++) {
                //截取每个字节
                NSData*tempData = [data subdataWithRange:NSMakeRange(2+i, 1)];
                ZKLog(@"%@",tempData);
                [tempArray addObject:tempData];
            }
            self.keyArray = tempArray;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}
-(void)dealloc{
    ZKLog(@"ZKKeyManageController对象释放");
}
@end
