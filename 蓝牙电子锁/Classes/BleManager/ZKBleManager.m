//
//  ZKBleManager.m
//  MosaicLightBLE
//
//  Created by mosaic on 2017/6/6.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import "ZKBleManager.h"

@implementation ZKBleManager{
    NSDictionary *_managerDict;
    NSDictionary *_scanDict;
    NSDictionary *_connectDict;
    
    NSMutableArray <ZKPeripheral*>*_cachePers;//添加新设备时
    
    NSMutableArray <ZKPeripheral*>*_onlinePers;//已有设备在线
}
singleton_implementation(ZKBleManager)

- (instancetype)initWithLaunchOptions:(NSDictionary*)launchOptions
{
    self = [super init];
    if (self) {
        _managerDict = @{CBCentralManagerOptionShowPowerAlertKey:@YES,CBCentralManagerOptionRestoreIdentifierKey:(launchOptions[UIApplicationLaunchOptionsBluetoothCentralsKey] ?: [[NSUUID UUID] UUIDString])};
        _scanDict = @{CBCentralManagerScanOptionAllowDuplicatesKey: @YES };
        _connectDict = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
        dispatch_queue_t centralQueue = dispatch_queue_create("SmartLock",0);
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:centralQueue options:_managerDict];
        _scanType = BLEAutoConnectScanning;
        
        _onlinePers = [NSMutableArray array];
        _cachePers = [NSMutableArray array];
    }
    return self;
}


//扫描设备
-(void)scan{
    [self stopScan];
    [_onlinePers removeAllObjects];
    [_cachePers removeAllObjects];
//    [self.perArray removeAllObjects];
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"FFE0"],[CBUUID UUIDWithString:UUID_LOCK_SERVER]] options:_scanDict];
}
//停止扫描
-(void)stopScan{
    if (@available(iOS 9.0, *)) {
        if (self.centralManager.isScanning) {
            [self.centralManager stopScan];
        }
    } else {
        [self.centralManager stopScan];
    }
}
//开始连接
-(void)connectPeripheral:(CBPeripheral *)peripheral{
    
    if (@available(iOS 9.0, *)) {
        if (peripheral.state==CBPeripheralStateDisconnecting||peripheral.state == CBPeripheralStateDisconnected){
            [self.centralManager connectPeripheral:peripheral options:_connectDict];
        }
    }else{
        if (peripheral.state == CBPeripheralStateDisconnected) {
            [self.centralManager connectPeripheral:peripheral options:_connectDict];
        }
    }
    
}
//断开连接
-(void)disConnectPeripheral:(CBPeripheral *)peripheral{
    
    if (peripheral.state !=CBPeripheralStateDisconnected) {
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}


#pragma mark ==CBCentralManagerDelegate==
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dict{
    ZKLog(@"-------------------------保存触发----------------------------------------");
//    [ZKBleManager addNotii:@"保存触发"];
    NSArray *peripherals =dict[CBCentralManagerRestoredStatePeripheralsKey];
}


-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if (@available(iOS 10.0, *)) {
        switch (central.state) {
                case CBManagerStateUnknown:
                break;
            case CBManagerStateResetting:
                break;
            case CBManagerStateUnsupported:
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"提示" message:@"该设备不支持BLE4.0" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
                });
                break;
            case CBManagerStateUnauthorized:
                break;
            case CBManagerStatePoweredOff:
                break;
            case CBManagerStatePoweredOn:
                [self scan];
                break;
            default:
                break;
        }
    } else {
        switch (central.state) {
            case CBCentralManagerStateUnknown:
                break;
            case CBCentralManagerStateResetting:
                break;
            case CBCentralManagerStateUnsupported:
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"提示" message:@"该设备不支持BLE4.0" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
                });
                break;
            case CBCentralManagerStateUnauthorized:
                break;
            case CBCentralManagerStatePoweredOff:
                break;
            case CBCentralManagerStatePoweredOn:
                [self scan];
                break;
            default:
                break;
        }
    }
}
//扫描到设备
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
//    ZKLog(@"%@ - RSSI:%@",peripheral.identifier,RSSI);
    
    //自动开锁（后台或者前台）
    if (self.scanType == BLEBackgroundScanning||self.scanType == BLEAutoConnectScanning||self.scanType==BLEAutoConnectOnVC) {
        for (ZKPeripheral*per in [ZKCommonData sharedZKCommonData].matchPer) {//所有已添加过的外设
            if ([per.identifier isEqualToString:peripheral.identifier.UUIDString]) {
                //缓存外设
                per.peripheral = peripheral;
                per.RSSI = RSSI;
               
                //前台时
                if (self.scanType == BLEAutoConnectScanning||self.scanType==BLEAutoConnectOnVC) {
                    //判断是否需要自动开锁
                    if (per.auto_unlock.intValue == 1&&self.scanType == BLEAutoConnectScanning) {
                        //连接外设
                        if (per.isAutoConnect&& peripheral.state!=CBPeripheralStateConnected){
                            [self connectPeripheral:peripheral];
                        }
                    }
                    if (![_onlinePers containsObject:per]) {
                        [_onlinePers addObject:per];
                        [ZKCommonData sharedZKCommonData].scanAddedPer = _onlinePers;
                    }
                }else{//后台时扫描方法 同一个外设只触发一次 
                    //判断是否需要自动开锁
                    ZKLog(@"后台时扫描到的设备：%@",per.note_name);
                    if (per.auto_unlock.intValue == 1) {
                        //连接外设
                        if (peripheral.state!=CBPeripheralStateConnected){
                            [self connectPeripheral:peripheral];
                        }
                    }
                }
                //通知新扫描到设备
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.centralDelegate respondsToSelector:@selector(customBleDidDiscoverPeripheral:)]) {
                        [self.centralDelegate customBleDidDiscoverPeripheral:per];
                    }
                });
            }
        }
    }
    
    //添加设备
    if (self.scanType == BLEAddDeviceScanning) {
        for (ZKPeripheral*per in [ZKCommonData sharedZKCommonData].matchPer) {//过滤掉所有已添加过的外设
            if ([per.identifier isEqualToString:peripheral.identifier.UUIDString]) {
                per.RSSI = RSSI;
                per.peripheral = peripheral;
                return;
            }
        }
        //新的设备
        for (ZKPeripheral*per in _cachePers) {
            if ([per.peripheral isEqual:peripheral]) {//已添加至缓存的新设备只更新RSSI
                per.RSSI = RSSI;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.centralDelegate respondsToSelector:@selector(customBleDidDiscoverPeripheral:)]) {
                        [self.centralDelegate customBleDidDiscoverPeripheral:per];
                    }
                });
                return;
            }
        }
        //添加新设备
        ZKPeripheral *zkper = [[ZKPeripheral alloc]init];
        zkper.peripheral = peripheral;
        zkper.identifier = peripheral.identifier.UUIDString;
        zkper.RSSI = RSSI ;
        [_cachePers addObject:zkper];
        [ZKCommonData sharedZKCommonData].scanPer = _cachePers;
         dispatch_async(dispatch_get_main_queue(), ^{
             if ([self.centralDelegate respondsToSelector:@selector(customBleDidDiscoverPeripheral:)]) {
                 [self.centralDelegate customBleDidDiscoverPeripheral:zkper];
             }
         });
    }
}


//连接到Peripherals-成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    //移除所有缓存的扫描设备数据后，按照扫描过滤流程会重新填入设备数据
    [_cachePers removeAllObjects];
    //扫描设备
    [peripheral discoverServices:nil];
//    //定时读取信号
//    [peripheral readRSSI];
    
    //如果不在已连接的设备池中 则添加至已连接设备池
    //添加设备方案
    if (self.scanType == BLEAddDeviceScanning) {
        ZKPeripheral*zkper = [[ZKPeripheral alloc]init];
        zkper.identifier = peripheral.identifier.UUIDString;
        zkper.peripheral = peripheral;
        [[ZKCommonData sharedZKCommonData].connectedPer addObject:zkper];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.centralDelegate respondsToSelector:@selector(customBleDidConnectPeripheral:)]) {
                [self.centralDelegate customBleDidConnectPeripheral:zkper];
            }
        });
    }else{
        for (ZKPeripheral*per in [ZKCommonData sharedZKCommonData].connectedPer) {
            if ([per.peripheral isEqual:peripheral]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.centralDelegate respondsToSelector:@selector(customBleDidConnectPeripheral:)]) {
                        [self.centralDelegate customBleDidConnectPeripheral:per];
                    }
                });
                return;
            }
        }
        
        for (ZKPeripheral*zkper in [ZKCommonData sharedZKCommonData].matchPer) {
            if ([zkper.identifier isEqualToString:peripheral.identifier.UUIDString]) {
                zkper.peripheral  = peripheral;
                [[ZKCommonData sharedZKCommonData].connectedPer addObject:zkper];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.centralDelegate respondsToSelector:@selector(customBleDidConnectPeripheral:)]) {
                        [self.centralDelegate customBleDidConnectPeripheral:zkper];
                    }
                });
            }
        }
        
    }
}

//连接到Peripherals-失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    ZKLog(@">>>连接到名称为（%@）的设备-失败,原因:%@",[peripheral name],[error localizedDescription]);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.centralDelegate respondsToSelector:@selector(customBleDidFailToConnectPeripheral:error:)]) {
            [self.centralDelegate customBleDidFailToConnectPeripheral:peripheral error:error];
        }
    });
}

//Peripherals断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    ZKLog(@">>>外设连接断开连接 %@: %@\n", [peripheral name], [error localizedDescription]);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.centralDelegate respondsToSelector:@selector(customBleDidDisconnectPeripheral:error:)]) {
            [self.centralDelegate customBleDidDisconnectPeripheral:peripheral error:error];
        }
    });
    
   
    if (self.scanType !=BLEAddDeviceScanning) {
        //1、从已连接的设备池中移除断开连接的设备
        NSMutableArray*tempArray = [NSMutableArray array];
        for (ZKPeripheral*zkper in [ZKCommonData sharedZKCommonData].connectedPer) {
            if ([zkper.peripheral isEqual:peripheral]) {
                [tempArray addObject:zkper];
            }
        }
        for (ZKPeripheral*zkper in tempArray) {
            [[ZKCommonData sharedZKCommonData].connectedPer removeObject:zkper];
        }
        if (self.scanType==BLEAutoConnectOnVC) {
            return;
        }
        //2、判断设备是否需要重连
        for (ZKPeripheral*zkper in [ZKCommonData sharedZKCommonData].autoReconnectPer){
            if ([zkper.peripheral isEqual:peripheral]&&zkper.auto_unlock.intValue==1) {
                if (zkper.isAutoConnect) {
                    [self connectPeripheral:peripheral];
                }
            }
        }
    }
}








@end
