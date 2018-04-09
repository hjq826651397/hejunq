//
//  ZKAddBLEController.m
//  蓝牙电子锁
//
//  Created by mosaic on 2017/12/2.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import "ZKAddBLEController.h"
#import "ZKTableViewCell.h"
#import "ZKMaskController.h"
@interface ZKAddBLEController ()<ZKBleManagerDelegate,ZKPeripheralDelegate>


@property (nonatomic,weak)ZKBleManager*manager;

@property (nonatomic,strong)ZKPeripheral* currentPer;
@property (nonatomic,strong)NSMutableArray <ZKPeripheral*>*tableArray;

@end

@implementation ZKAddBLEController{
    NSTimer *_scanTimer;
    NSMutableArray *_conenectArray;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
//懒加载
-(NSMutableArray *)tableArray{
    if (!_tableArray) {
        _tableArray = [NSMutableArray arrayWithArray:[ZKCommonData sharedZKCommonData].scanPer];
    }
    return _tableArray;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        _conenectArray = [NSMutableArray array];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [ZKBleManager sharedZKBleManager].scanType = BLEAddDeviceScanning;
    [ZKBleManager sharedZKBleManager].centralDelegate = self;
    self.manager =  [ZKBleManager sharedZKBleManager];
    _scanTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timerScan) userInfo:nil repeats:YES];
    [_scanTimer fire];
//    [self.manager scan];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [ZKBleManager sharedZKBleManager].centralDelegate = nil;

    for (ZKPeripheral*per in _conenectArray) {
        if (per.peripheral) {
            [self.manager disConnectPeripheral:per.peripheral];
        }
    }
    [_scanTimer invalidate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"搜索设备";
    [self createUI];
}

//创建UI
-(void)createUI{
    [self.view setBackgroundColor:[UIColor colorWithHexString:@"F1F2F1"]];
    //tableView
    UITableView*tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ZKSCREEN_W, ZKSCREEN_H-64) style:UITableViewStylePlain];;
    [tableview setBackgroundColor:[UIColor colorWithHexString:@"F1F2F1"]];
    tableview.delegate = self;
    tableview.dataSource = self;
    [tableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableview];
    self.tableView = tableview;
    
//    [self.tableView setFrame:CGRectMake(0, 64, ZKSCREEN_W, ZKSCREEN_H-64)];
}




-(void)timerScan{
    [self.manager scan];
//    [self.tableView reloadData];
    [self performSelector:@selector(refreshData) withObject:nil afterDelay:3];
//    [self refreshData];
}

-(void)refreshData{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshData) object:nil];

    //删除消失的设备
    NSMutableArray *tempArray = [NSMutableArray array];
    for (ZKPeripheral*tablePer in self.tableArray) {
        BOOL isThere  = NO;
        for (ZKPeripheral*temPer in [ZKCommonData sharedZKCommonData].scanPer) {
            if ([tablePer.peripheral isEqual:temPer.peripheral]) {
                isThere = YES;
                break;
            }
        }
        if (!isThere) {
            //缓存需要删除的数据
            [tempArray addObject:tablePer];
//            NSInteger i = [self.tableArray indexOfObject:tablePer];
//            [self.tableArray removeObject:tablePer];
//            NSIndexPath*indexPath = [NSIndexPath indexPathForRow:i inSection:0];
//            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    if (tempArray.count>0) {
        //删除数据
        for (ZKPeripheral*temper in tempArray) {
            if ([self.tableArray containsObject:temper]) {
                NSInteger i = [self.tableArray indexOfObject:temper];
//                NSIndexPath*indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                //            ZKTableViewCell*cell = [self.tableView cellForRowAtIndexPath:indexPath];
                [self.tableArray removeObject:temper];
//                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
//                [self.tableView reloadData];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }
}


-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return relative_h(200);
    }else{
        return 0.0000001;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section ==0) {
        UIView *backView = [[UIView alloc]init];
        [backView setFrame:CGRectMake(0, 0, ZKSCREEN_W, relative_h(200))];
        [backView setBackgroundColor:[UIColor clearColor]];
        
        UIView *view = [[UIView alloc]init];
        [view setFrame:CGRectMake(0, relative_h(20), ZKSCREEN_W, relative_h(180))];
        [view setBackgroundColor:[UIColor whiteColor]];
        [backView addSubview:view];
        UILabel*labTitle = [[UILabel alloc]init];
        labTitle.text = @"请从以下列表中选择，连接蓝牙锁";
        labTitle.font = LabelFount(11);
        [labTitle setTextColor:[UIColor colorWithHexString:@"7F7F7F"]];
        [labTitle setFrame:CGRectMake(relative_h(80), relative_h(30), 0, 0)];
        [labTitle sizeToFit];
        [view addSubview:labTitle];
        
        UILabel *labDetail = [[UILabel alloc]init];
        labDetail.text = @"附近可匹配的门锁";
        labDetail.font = LabelFount(15);
        [labDetail setFrame:CGRectMake(relative_h(80), CGRectGetMaxY(labTitle.frame)+relative_h(20), 0, 0)];
        [labDetail sizeToFit];
        [view addSubview:labDetail];
        return backView;
    }else{
        return nil;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tableArray.count;//[ZKCommonData sharedZKCommonData].scanPer.count;
}
    

- (ZKTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *ID = @"ZKTableViewCell";
    ZKTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[ZKTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }

    ZKPeripheral*per = self.tableArray[indexPath.row];//[ZKCommonData sharedZKCommonData].scanPer[indexPath.row];
//    [cell.imageView setImage:[UIImage imageNamed:@"设备.png"]];
//    cell.textLabel.text = per.peripheral.name;
    [cell.iconImgV setImage:[UIImage imageNamed:@"设备.png"]];
//    [cell.titleLabel setText:per.peripheral.identifier.UUIDString];
    NSString *idstr = per.peripheral.identifier.UUIDString;
    idstr = [idstr substringToIndex:5];
    [cell.titleLabel setText:[NSString stringWithFormat:@"%@:%@",idstr,per.RSSI.stringValue]];
    [cell.accImgV setImage:[UIImage imageNamed:@"下一级按钮.png"]];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return relative_h(150);
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //从扫描到的设备组中选择设备    //注意:设备连接成功后，扫描数组里面失去此条数据
    ZKPeripheral*per = self.tableArray[indexPath.row];//[ZKCommonData sharedZKCommonData].scanPer[indexPath.row];
    [self.manager connectPeripheral:per.peripheral];
    [[ZKAlertView sharedZKAlertView] showTitle:@"提示" message:@"正在连接设备......" showOnVC:self handler:^{
        [self.manager disConnectPeripheral:per.peripheral];
    }];

}



#pragma mark == ZKBleManagerDelegate
-(void)customBleDidDiscoverPeripheral:(ZKPeripheral*)per{
    //判断展示数据中是否存在Per
    for (ZKPeripheral*perT in self.tableArray) {
        if ([per.peripheral isEqual:perT.peripheral]) {
            perT.RSSI = per.RSSI;
            NSUInteger i = [self.tableArray indexOfObject:perT];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            ZKTableViewCell*cell = [self.tableView cellForRowAtIndexPath:indexPath];
            NSString *idstr = per.peripheral.identifier.UUIDString;
            idstr = [idstr substringToIndex:5];
            [cell.titleLabel setText:[NSString stringWithFormat:@"%@:%@",idstr,per.RSSI.stringValue]];
            [cell.titleLabel sizeToFit];
            return;
        }
    }
//    //不存在则添加数据并刷新UI
    if (![self.tableArray containsObject:per]) {
        [self.tableArray insertObject:per atIndex:0];
//        [self.tableView reloadData];
         [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];

//        NSUInteger i = [self.tableArray indexOfObject:per];
//        ZKLog(@"----- %lu",(unsigned long)i);
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    }
}
//连接成功
- (void)customBleDidConnectPeripheral:(ZKPeripheral *)peripheral{
    [self.tableView reloadData];
    [_conenectArray addObject:peripheral];
    //设置代理
    self.currentPer = peripheral;
    peripheral.peripheralDelegate = self;
}

#pragma mark == ZKPeripheralDelegate

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
    [[ZKAlertView sharedZKAlertView] hiddeAlertCompletion:^{}];
    
    switch (notiyCode) {
        case PeripheralNotiyDefualt:{
         
            
        }
            break;
        case PeripheralNotiyHandCodeSuccess:{
            //发送密码
            [peripheral sendUnlockPassword];
        }
            break;
        case PeripheralNotiyPasswordSuccess:
            
            break;
        case PeripheralNotiyAddAdminKeySuccess:{//管理员钥匙添加成功
            int rCode = 0;
            [value getBytes:&rCode length:value.length];
            NSNumber *numrcode = [NSNumber numberWithInt:rCode];
            peripheral.connect_code = numrcode;
            peripheral.type = @(1);
           NSString*idStr =  peripheral.peripheral.identifier.UUIDString;
           idStr = [idStr substringToIndex:5];
            peripheral.note_name =[NSString stringWithFormat:@"%@",idStr] ;
            //保存至数据库
            BOOL result =   [[ZKCommonData sharedZKCommonData]addPerToDatabase:peripheral];
            if (result) {
                 [ZKNotificationView show:@"管理员钥匙添加成功" delay:1 willShowBlock:^{} Tapblock:^{}didShowBlock:^{}];
            }else{
                [ZKNotificationView show:@"添加钥匙失败" delay:1 willShowBlock:^{} Tapblock:^{} didShowBlock:^{}];
            }
        }
            break;
        case PeripheralNotiyAddKeyCodeFail:{
            [ZKNotificationView show:@"配匙码错误" delay:1 willShowBlock:^{} Tapblock:^{} didShowBlock:^{}];
            //断开连接
            [[ZKBleManager sharedZKBleManager] disConnectPeripheral:peripheral.peripheral];
        }
            break;
        case PeripheralNotiyBlackList:
            
            break;
        case PeripheralNotiyLockAccess:
            
            break;
        case PeripheralNotiyCloseLockAccess:
            
            break;
        case PeripheralNotiyAddKeySuccess:{//普通用户钥匙添加成功
            int rCode = 0;
            [value getBytes:&rCode length:value.length];
            NSNumber *numrcode = [NSNumber numberWithInt:rCode];
            peripheral.connect_code = numrcode;
            peripheral.type = @(2);
            NSString*idstr =  peripheral.peripheral.identifier.UUIDString;
            idstr = [idstr substringToIndex:5];
            peripheral.note_name = idstr;
            //保存至数据库
            BOOL result =   [[ZKCommonData sharedZKCommonData]addPerToDatabase:peripheral];
            if (result) {
                [ZKNotificationView show:@"添加普通用户钥匙成功" delay:1 willShowBlock:^{} Tapblock:^{}didShowBlock:^{}];
            }else{
                [ZKNotificationView show:@"添加设备失败" delay:1 willShowBlock:^{} Tapblock:^{} didShowBlock:^{}];
            }
        }
            break;
        case PeripheralNotiyHandCodeFail:
            
            break;
        case PeripheralNotiyKeyDisable:
            
            break;
        case PeripheralNotiyOnceKeyProduct:
            
            break;
        case PeripheralNotiyKeyExisted:{
            
            
        }
            break;
        case PeripheralNotiyAddKeyCodeAllow:{//允许配匙
            ZKMaskController *setVC = [[ZKMaskController alloc]init];
            setVC.titleStr = @"请输入配匙码";
            setVC.modalPresentationStyle = UIModalPresentationCustom;
            setVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:setVC animated:YES completion:nil];
            [setVC getResultBlock:^(NSString *codeStr, BOOL isCancel) {
                if (!isCancel) {
                    [peripheral sendAccessCode:codeStr];
                }else{
                    [[ZKBleManager sharedZKBleManager] disConnectPeripheral:peripheral.peripheral];
                }
            }];

        }
            break;
        default:
            break;
    }
    
}

-(void)dealloc{
    
}

@end
