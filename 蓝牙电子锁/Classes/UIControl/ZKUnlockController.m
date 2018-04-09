//
//  ZKUnlockController.m
//  蓝牙电子锁
//
//  Created by mosaic on 2017/12/14.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import "ZKUnlockController.h"
#import "ZKEmp1Button.h"
#import "ZKEmp2Button.h"
#import "ZKEmp3Button.h"
#import "ZKRemarkController.h"
#import "ZKKeyManageController.h"
#import "ZKDevManagerController.h"
#import "ZKSignalController.h"
@interface ZKUnlockController ()<ZKBleManagerDelegate,ZKPeripheralDelegate>
@property(nonatomic,weak)UIView *unlockView;
@property(nonatomic,weak)UIButton *unlockButton;
@property(nonatomic,weak)UILabel *unlockLabel;
@property(nonatomic,weak)ZKEmp1Button *deleteButton;
@property(nonatomic,weak)ZKEmp2Button *changeNameButton;
@property(nonatomic,weak)ZKEmp3Button *autoUnlockButton;
@property(nonatomic,weak)ZKEmp2Button *managerButton;
@property(nonatomic,weak)ZKBleManager*bleManager;//蓝牙管理器
@property(nonatomic,weak)ZKCommonData*dataManager;//数据管理器
@property(nonatomic,weak)ZKBatteryView *batteryView;
@property(nonatomic,weak)UILabel *batteryLabel;
@end

@implementation ZKUnlockController{
    BOOL _isAllowUnlock;//是否符合开锁权限
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.zkper.peripheralDelegate = self;
    self.bleManager = [ZKBleManager sharedZKBleManager];
    self.bleManager.centralDelegate = self;
    self.dataManager = [ZKCommonData sharedZKCommonData];
    
    self.changeNameButton.dLabel.text = self.zkper.note_name;
    [self.changeNameButton refresh];
    [ZKBleManager sharedZKBleManager].scanType = BLEAutoConnectScanning;

    if (self.zkper.peripheral.state==CBPeripheralStateDisconnected) {
        [self setUnlockLabelText:@"蓝牙未连接"];
        [self.unlockButton setImage:[UIImage imageNamed:@"开锁图标.png"] forState:UIControlStateNormal];
    }
    if (self.zkper.peripheral.state==CBPeripheralStateConnecting) {
        [self setUnlockLabelText:@"正在连接蓝牙"];
        [self.unlockButton setImage:[UIImage imageNamed:@"开锁图标.png"] forState:UIControlStateNormal];
    }
    if (self.zkper.peripheral.state==CBPeripheralStateConnected) {
        [self setUnlockLabelText:@"点击开锁"];
        [self.unlockButton setImage:[UIImage imageNamed:@"可开锁.png"] forState:UIControlStateNormal];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _isAllowUnlock = YES;
    self.zkper.identifyController = @"ZKUnlockController";
    [self createUI];
}


-(void)createUI{
    self.title = @"设备信息";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.view setBackgroundColor:[UIColor colorWithHexString:@"F1F2F1"]];
    UIView *unlockView = [[UIView alloc]init];
    [unlockView setFrame:CGRectMake(0, 64, ZKSCREEN_W, relative_h(625))];
    [unlockView setBackgroundColor:[UIColor colorWithHexString:@"FF3956"]];
    [self.view addSubview:unlockView];
    self.unlockView = unlockView;
    //电池信息
    ZKBatteryView *batteryView = [[ZKBatteryView alloc]init];
    [batteryView setFrame:CGRectMake(10,unlockView.y+10 , 30, 11.0/27.0*30)];
    [batteryView setBackgroundColor:[UIColor clearColor]];
    [batteryView setBordColor:[UIColor clearColor]];
    [batteryView setProgressColor:[UIColor colorWithHexString:@"#4AD963"]];
    [batteryView setBackColor:[UIColor colorWithWhite:1 alpha:0.3]];
    [self.view addSubview:batteryView];
    [batteryView setRatio:self.zkper.battery/100.0];
    self.batteryView = batteryView;
    
    UILabel *batteryLabel = [[UILabel alloc]init];
    [batteryLabel setTextColor:[UIColor whiteColor]];
    [batteryLabel setFrame:CGRectMake(CGRectGetMaxX(batteryView.frame)+5, 0, 0, 0)];
    batteryLabel.font = LabelFount(13);
    [batteryLabel setText:[NSString stringWithFormat:@"%d%%",self.zkper.battery]];
    [batteryLabel sizeToFit];
    batteryLabel.centerY = batteryView.centerY;
    [self.view addSubview:batteryLabel];
    self.batteryLabel = batteryLabel;
    if (self.zkper.battery>0&&self.zkper.peripheral.state==CBPeripheralStateConnected) {
        [self.batteryView setHidden:NO];
        [self.batteryLabel setHidden:NO];
    }else{
        [self.batteryView setHidden:YES];
        [self.batteryLabel setHidden:YES];
    }
    
    UIButton *unlockButton = [[UIButton alloc]init];
    [unlockButton setImage:[UIImage imageNamed:@"开锁图标.png"] forState:UIControlStateNormal];
    [unlockButton setFrame:CGRectMake(0, relative_h(140), relative_h(258), relative_h(258))];
    unlockButton.centerX = unlockView.centerX;
    [unlockView addSubview:unlockButton];
    self.unlockButton = unlockButton;
    
    UILabel *unlockLabel = [[UILabel alloc]init];
    unlockLabel.text = @"蓝牙未连接";
    unlockLabel.textColor = [UIColor whiteColor];
    unlockLabel.font = LabelFount(14);
    [unlockLabel sizeToFit];
    unlockLabel.centerX = unlockButton.centerX;
    unlockLabel.y = CGRectGetMaxY(unlockButton.frame)+relative_h(38);
    [unlockView addSubview:unlockLabel];
    self.unlockLabel = unlockLabel;
   //删除设备按钮
    ZKEmp1Button *deleteButton = [[ZKEmp1Button alloc]init];
    [deleteButton setFrame:CGRectMake(0, ZKSCREEN_H-relative_h(150)-relative_h(110), relative_w(612), relative_h(110))];
    [deleteButton setTitle:@"删除设备" forState:UIControlStateNormal];
    deleteButton.centerX = unlockView.centerX;
    [self.view addSubview:deleteButton];
    self.deleteButton = deleteButton;
    //修改备注
    ZKEmp2Button *changeNameButton  = [[ZKEmp2Button alloc]init];
    [changeNameButton setBackgroundColor:[UIColor whiteColor]];
    changeNameButton.tLabel.text = @"修改备注";
    changeNameButton.dLabel.text = self.zkper.note_name;
    [changeNameButton.dLabel setTextColor:[UIColor colorWithWhite:0.3 alpha:1]];
    [changeNameButton setFrame:CGRectMake(0, CGRectGetMaxY(unlockView.frame), ZKSCREEN_W, relative_h(125))];
    [self.view addSubview:changeNameButton];
    self.changeNameButton = changeNameButton;
    //自动开锁
    ZKEmp3Button *autoUnlockButton = [[ZKEmp3Button alloc]init];
    [autoUnlockButton setBackgroundColor:[UIColor whiteColor]];
    autoUnlockButton.tLabel.text = @"自动开锁";
    [autoUnlockButton setFrame:CGRectMake(0, CGRectGetMaxY(changeNameButton.frame)+relative_h(20), ZKSCREEN_W, relative_h(125))];
    [self.view addSubview:autoUnlockButton];
    self.autoUnlockButton = autoUnlockButton;
    if (self.zkper.type.intValue==1) {
        //管理设备
        ZKEmp2Button *managerButton  = [[ZKEmp2Button alloc]init];
        [managerButton setBackgroundColor:[UIColor whiteColor]];
        managerButton.tLabel.text = @"管理设备";
        [managerButton setFrame:CGRectMake(0, CGRectGetMaxY(autoUnlockButton.frame)+relative_h(20), ZKSCREEN_W, relative_h(125))];
        [self.view addSubview:managerButton];
        self.managerButton = managerButton;
        [self.managerButton addTarget:self action:@selector(managerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    //事件
    ZKLog(@"%@",self.autoUnlockButton.clickButton );
    [self.autoUnlockButton.clickButton addTarget:self action:@selector(autoClickButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteButton addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.changeNameButton addTarget:self action:@selector(changeNameButtonClick:) forControlEvents:UIControlEventTouchUpInside];
   
    //自动开锁开关事件
    [self.autoUnlockButton.autoUnlockSwitch addTarget:self action:@selector(autoUnlockSwitchChangedValue:) forControlEvents:UIControlEventValueChanged];
    //点击开锁事件
    [self.unlockButton addTarget:self action:@selector(unlockButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.zkper.auto_unlock.intValue ==1) {
        [self.autoUnlockButton.autoUnlockSwitch setOn:YES];
    }else{
        [self.autoUnlockButton.autoUnlockSwitch setOn:NO];
    }
    //监听电池信息变化
    [self.zkper addObserver:self forKeyPath:@"battery" options:NSKeyValueObservingOptionNew context:nil];
}

//监听事件
- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context{
    ZKLog(@"%@",change);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.batteryView setRatio:self.zkper.battery/100.0];
        [self.batteryLabel setText:[NSString stringWithFormat:@"%d%%",self.zkper.battery]];
        [self.batteryLabel sizeToFit];
        if (self.zkper.battery>0) {
            [self.batteryView setHidden:NO];
            [self.batteryLabel setHidden:NO];
        }else{
            [self.batteryView setHidden:YES];
            [self.batteryLabel setHidden:YES];
        }
    });
}
-(void)autoClickButton:(id)sender{
    ZKLog(@"设置信号强度");
    ZKSignalController *singalController = [[ZKSignalController alloc]init];
    singalController.peri = self.zkper;
    [self.navigationController pushViewController:singalController animated:YES];
}
-(void)setUnlockLabelText:(NSString*)msg{
    self.unlockLabel.text = msg;
    [self.unlockLabel sizeToFit];
    self.unlockLabel.centerX = self.unlockButton.centerX;
    self.unlockLabel.y = CGRectGetMaxY(self.unlockButton.frame)+relative_h(38);
}
//点击开锁
-(void)unlockButtonClick:(UIButton*)sender{
    if (_isAllowUnlock&&self.zkper.peripheral&&self.zkper.peripheral.state==CBPeripheralStateConnected) {
        [self.zkper sendOpenLockSignal];
    }else{
        if (self.zkper.peripheral.state!=CBPeripheralStateConnected) {
            [ZKAlertView showError:@"蓝牙未连接" viewController:self Completion:^{}];
            [self setUnlockLabelText:@"蓝牙未连接"];
        }else{
            [ZKAlertView showError:@"钥匙失效或禁用" viewController:self Completion:^{}];
        }
    }
}
//删除设备 并断开连接
-(void)deleteButtonClick:(ZKEmp1Button*)sender{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定删除设备?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    // 添加按钮
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        BOOL result = [self.dataManager deletePerToDatabase:self.zkper];
        if (result) {
            if (self.zkper.peripheral.state==CBPeripheralStateConnected&&_isAllowUnlock) {
                [self.zkper sendDeleteCode];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        ZKLog(@"点击了取消按钮");
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)changeNameButtonClick:(ZKEmp2Button*)sender{
    ZKRemarkController *remarkVC = [[ZKRemarkController alloc]init];
    remarkVC.zkper = self.zkper;
    [self.navigationController pushViewController:remarkVC animated:YES];
    [self.changeNameButton refresh];
}

//管理设备
-(void)managerButtonClick:(ZKEmp2Button*)sender{
   
//    ZKKeyManageController *keyVC = [[ZKKeyManageController alloc]init];
//    keyVC.perip = self.zkper;
    ZKDevManagerController *devManagerVc = [[ZKDevManagerController alloc]init];
        devManagerVc.perip = self.zkper;

    if (self.zkper.peripheral.state == CBPeripheralStateConnected) {
        [self.navigationController pushViewController:devManagerVc animated:YES];
    }else{
        [ZKAlertView showError:@"蓝牙未连接" viewController:self Completion:^{}];
    }
    
}

-(void)autoUnlockSwitchChangedValue:(UISwitch*)sender{
    int value;
    if (sender.on) {
        value = 1;
    }else{
        value = 2;
    }
    if (self.zkper.auto_unlock.intValue!=value) {
        self.zkper.auto_unlock = [NSNumber numberWithInt:value];
        if ([self.dataManager updatePerToDatabase:self.zkper]) {
            ZKLog(@"%@",self.zkper.signal_set);
            ZKLog(@"%d",self.zkper.auto_unlock.intValue);
            [self.zkper sendConnectionCode];
        }else{
            [ZKNotificationView show:@"保存设置失败" willShowBlock:^{}Tapblock:^{} didShowBlock:^{}];
        }
    }
}

#pragma mark ==BLEDelegate==
//扫描到设备
-(void)customBleDidDiscoverPeripheral:(ZKPeripheral*)per {
    
    if ([self.zkper.peripheral isEqual:per.peripheral]) {
        if (self.zkper.isAutoConnect) {
            [self.bleManager connectPeripheral:per.peripheral];
            [self setUnlockLabelText:@"正在连接蓝牙"];
            [self.unlockButton setImage:[UIImage imageNamed:@"开锁图标.png"] forState:UIControlStateNormal];
        }
    }
}
//连接成功
- (void)customBleDidConnectPeripheral:(ZKPeripheral *)peripheral{
    if ([self.zkper.peripheral isEqual:peripheral.peripheral]) {
        [self setUnlockLabelText:@"点击开锁"];
        [self.unlockButton setImage:[UIImage imageNamed:@"可开锁.png"] forState:UIControlStateNormal];
        peripheral.peripheralDelegate = self;
    }
}
//连接到Peripherals-失败
-(void)customBleDidFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    if ([peripheral isEqual:self.zkper.peripheral]) {
        [self setUnlockLabelText:@"蓝牙未连接"];
        [self.unlockButton setImage:[UIImage imageNamed:@"开锁图标.png"] forState:UIControlStateNormal];
    }
}
//Peripherals断开连接
- (void)customBleDidDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    if ([peripheral isEqual:self.zkper.peripheral]) {
        [self setUnlockLabelText:@"蓝牙未连接"];
        [self.unlockButton setImage:[UIImage imageNamed:@"开锁图标.png"] forState:UIControlStateNormal];
    }
}

#pragma mark ==perdelegate ==
//扫描到服务中的特征
- (void)customPeripheralDidDiscoverCharacteristics:(ZKPeripheral*)peripheral error:(NSError *)error{
    
}
//接收外设发过来的值
- (void)customPeripheral:(ZKPeripheral*)peripheral DidUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    
}
//读取RSSI
- (void)customPeripheralDidReadRSSI:(ZKPeripheral*)peripheral error:(NSError *)error{
    
    
}

-(void)customPeripheral:(ZKPeripheral *)peripheral NotiyCode:(ZKPeripheralCode)notiyCode value:(NSData *)value error:(NSError *)error{
    if ([peripheral.peripheral isEqual:self.zkper.peripheral]) {
//        ZKLog(@"%d,%@",notiyCode,value);
        switch (notiyCode) {
            case PeripheralNotiyDefualt:{
                
        
            }
                break;
            case PeripheralNotiyHandCodeSuccess:{//2、手机与设备连接握手成功
                ZKLog(@"连接握手成功");
            }
                break;
            case PeripheralNotiyPasswordSuccess:{//3、密文验证成功
                _isAllowUnlock = YES;

                ZKLog(@"密文验证成功");
            }
                break;
            case PeripheralNotiyAddAdminKeySuccess:{//管理员钥匙添加成功
                
                
            }
                break;
            case PeripheralNotiyAddKeyCodeFail:{//5、密匙添加失败
                
            }
                break;
            case PeripheralNotiyBlackList:{//6、已列为黑名单
                [ZKNotificationView show:@"钥匙已失效" delay:1.5 willShowBlock:^{
                } Tapblock:^{} didShowBlock:^{}];
                [self.bleManager disConnectPeripheral:peripheral.peripheral];
//                self.zkper.isAutoConnect = NO;
            }
                break;
            case PeripheralNotiyLockAccess:{//7、可以开锁
                ZKLog(@"可以开锁");
                _isAllowUnlock = YES;
//                self.zkper.isAutoConnect = YES;

            }
                break;
            case PeripheralNotiyCloseLockAccess:{//8、关闭开锁
                _isAllowUnlock = YES;
//                self.zkper.isAutoConnect = YES;

            }
                break;
            case PeripheralNotiyAddKeySuccess:{//普通用户钥匙添加成功
                
                
            }
                break;
            case PeripheralNotiyHandCodeFail:{//10、手机与设备连接握手失败
                [ZKNotificationView show:@"钥匙已失效" delay:1.5 willShowBlock:^{
                } Tapblock:^{} didShowBlock:^{}];
                [self.bleManager disConnectPeripheral:peripheral.peripheral];
                _isAllowUnlock = NO;
//                self.zkper.isAutoConnect = NO;
            }
                break;
            case PeripheralNotiyKeyDisable:{//11、密匙已禁用
                [ZKNotificationView show:@"钥匙已禁用" delay:1.5 willShowBlock:^{
                } Tapblock:^{} didShowBlock:^{}];
                [self.bleManager disConnectPeripheral:peripheral.peripheral];
//                self.zkper.isAutoConnect = NO;
                _isAllowUnlock = NO;

            }
                break;
            case PeripheralNotiyOnceKeyProduct://12、配匙码生成完成
                
                break;
            case PeripheralNotiyKeyExisted:{//13、密匙已存在
                
            }
                break;
            case PeripheralNotiyAddKeyCodeAllow:{//允许配匙
                
            }
                break;
            case PeripheralNotiyPasswordFail:{//15:密文验证失败
                
                _isAllowUnlock = NO;
            }
                break;
                
            case PeripheralNotiyDeleteKey:{//16、删除钥匙
                [ZKNotificationView show:[NSString stringWithFormat:@"“%@”钥匙已从设备中删除",self.zkper.note_name] delay:1.5 willShowBlock:^{
                } Tapblock:^{} didShowBlock:^{}];
                [self.bleManager disConnectPeripheral:self.zkper.peripheral];
                [self.navigationController popViewControllerAnimated:YES];
            }
                break;
            case PeripheralNotiyKeyisFull:{//17、钥匙已满
                
            }
            default:
                break;
        }
    }
}



-(void)dealloc{
    self.zkper.identifyController = @"";
    self.bleManager.centralDelegate = nil; if(self.zkper.auto_unlock.intValue==2&&self.zkper.peripheral&&self.zkper.peripheral.state!=CBPeripheralStateDisconnected) {
        [self.bleManager disConnectPeripheral:self.zkper.peripheral];
    }
    [self.zkper removeObserver:self forKeyPath:@"battery"];

}
@end
