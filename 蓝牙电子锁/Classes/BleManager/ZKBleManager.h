//
//  ZKBleManager.h
//  MosaicLightBLE
//
//  Created by mosaic on 2017/6/6.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "ZKPeripheral.h"
#import "ZKCommandData.h"
enum SenceType{
    BLEBackgroundScanning = 1 ,
    BLEAutoConnectScanning,
    BLEAddDeviceScanning,
    BLEAutoConnectOnVC
};
@protocol ZKBleManagerDelegate <NSObject>
@optional
//扫描到设备
-(void)customBleDidDiscoverPeripheral:(ZKPeripheral*)per ;

//连接成功
- (void)customBleDidConnectPeripheral:(ZKPeripheral *)peripheral;
//连接到Peripherals-失败
-(void)customBleDidFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
//Peripherals断开连接
- (void)customBleDidDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;

@end

@interface ZKBleManager : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>
@property(nonatomic,weak)id <ZKBleManagerDelegate>centralDelegate;
@property(nonatomic,strong)CBCentralManager *centralManager;
//@property(nonatomic,strong)NSMutableArray <ZKPeripheral*>*perArray;
@property(nonatomic,assign)enum SenceType scanType;

@property(nonatomic,assign)enum SenceType restoreState;



singleton_interface(ZKBleManager)

- (instancetype)initWithLaunchOptions:(NSDictionary*)launchOptions;

-(void)scan;//扫描设备
-(void)stopScan;//停止扫描
-(void)connectPeripheral:(CBPeripheral *)periphera;//连接蓝牙
-(void)disConnectPeripheral:(CBPeripheral *)peripheral;//断开连接

////写入数据
//-(void)sendData:(NSData*)value forCharacteristic:(CBCharacteristic *)characteristic toPeripheral:(CBPeripheral *)peripheral;
//+(void)addNotii:(NSString*)msg;
@end
