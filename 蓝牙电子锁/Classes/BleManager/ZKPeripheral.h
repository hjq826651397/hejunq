//
//  ZKPeripheral.h
//  MosaicLightBLE
//
//  Created by mosaic on 2017/6/6.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "ZKCommandData.h"
typedef enum ZKPeripheralCode
{
    PeripheralNotiyDefualt = 1,
    PeripheralNotiyHandCodeSuccess,     //2、手机与设备连接握手成功
    PeripheralNotiyPasswordSuccess,     //3、密文验证成功
    PeripheralNotiyAddAdminKeySuccess,  //4、密匙添加成功  (管理员)
    PeripheralNotiyAddKeyCodeFail,      //5、密匙添加失败
    PeripheralNotiyBlackList,           //6、已列为黑名单
    PeripheralNotiyLockAccess,          //7、可以开锁
    PeripheralNotiyCloseLockAccess,     //8、关闭开锁
    PeripheralNotiyAddKeySuccess,       //9、密匙添加成功 (普通用户)
    PeripheralNotiyHandCodeFail,        //10、手机与设备连接握手失败
    PeripheralNotiyKeyDisable,          //11、密匙已禁用
    PeripheralNotiyOnceKeyProduct,      //12、配匙码生成完成
    PeripheralNotiyKeyExisted,          //13、密匙已存在
    PeripheralNotiyAddKeyCodeAllow,     //14、允许添加，输入配匙码
    PeripheralNotiyPasswordFail,        //15、密文验证失败
    PeripheralNotiyDeleteKey ,          //16、删除钥匙
    PeripheralNotiyKeyisFull,           //17、钥匙已满
    PeripheralNotiyReadKeySuccess,       //18、查询钥匙列表成功
    PeripheralNotiyReadKeyboardSuccess, //键盘密码读或写操作成功
   PeripheralNotiyReadRSSISuccess    //20、校准RSSI 读取成功
}ZKPeripheralCode;

typedef enum ZKKeyboardStatus
{
   KeyboardStatusNone = 0,
   KeyboardStatusOpen ,
   KeyboardStatusClose,
   KeyboardStatusSet
}ZKKeyboardStatus;
@class ZKPeripheral;
@protocol ZKPeripheralDelegate <NSObject>
@optional


//扫描到服务中的特征
- (void)customPeripheralDidDiscoverCharacteristics:(ZKPeripheral*)peripheral error:(NSError *)error;
//接收外设发过来的值
- (void)customPeripheral:(ZKPeripheral*)peripheral DidUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
//读取RSSI
- (void)customPeripheralDidReadRSSI:(ZKPeripheral*)peripheral error:(NSError *)error;

//收到订阅通知
-(void)customPeripheral:(ZKPeripheral*)peripheral NotiyCode:(ZKPeripheralCode)notiyCode value:(NSData*)value error:(NSError *)error;



@end
@interface ZKPeripheral : NSObject<CBPeripheralDelegate>

@property (nonatomic, strong) CBPeripheral *peripheral;

//系统信息
@property (nonatomic, strong) CBCharacteristic*chc_Firmware;//固件版本
@property (nonatomic, strong) CBCharacteristic*chc_battery; //电池180F
@property (nonatomic, strong) CBCharacteristic*chc_Hardware; //硬件版本

//固件升级
//#define UUID_UPGRADE_SERVER     @"F000FFC0-0451-4000-B000-000000000000"
//#define UUID_UPGRADE_Identify
//#define UUID_UPGRADE_Block      @"F000FFC2-0451-4000-B000-000000000000"
//#define UUID_UPGRADE_Status
@property (nonatomic, strong) CBCharacteristic*chc_Identify;//@"F000FFC1-0451-4000-B000-000000000000"
@property (nonatomic, strong) CBCharacteristic*chc_Block;
@property (nonatomic, strong) CBCharacteristic*chc_Status;


@property (nonatomic, strong) CBCharacteristic*chc_ReturnCode;//0Xfa54
@property (nonatomic, strong) CBCharacteristic*chc_UpdateTime;//0Xfa51(W,R)  更新设备时间或操作设备
@property (nonatomic, strong) CBCharacteristic*chc_ConenctCode;//0Xfa52(W)
@property (nonatomic, strong) CBCharacteristic*chc_KeyCode;//0Xfa53(W)
@property (nonatomic, strong) CBCharacteristic*chc_UnlockPwd;//0Xfa55 (W)
@property (nonatomic, strong) CBCharacteristic*chc_KeyPwd;//0Xfa56(W)

@property(nonatomic,weak)id <ZKPeripheralDelegate>peripheralDelegate;

@property(nonatomic, assign) NSNumber* RSSI;
@property(nonatomic, copy) NSString *firmware;
@property(nonatomic, copy) NSString *upgradeStr;

@property(nonatomic, assign) int battery;
@property(nonatomic, strong)NSData *KeyboardPwdData;
@property(nonatomic, assign) BOOL  isOpenKeyboard;
@property(nonatomic, assign)ZKKeyboardStatus keyboardStatus;//键盘密码状态

@property (nonatomic,copy)NSString *identifyController;
//@property (nonatomic,assign) BOOL  isAvailable;//记录是否有权限开启电子锁
@property (nonatomic,assign) BOOL  isAutoConnect;//是否自动重连



@property(nonatomic,copy)NSString*identifier;   //唯一蓝牙连接识别id
@property(nonatomic,assign)NSNumber *type;      //权限类型 ，//1 为管理员用户  2为普通用户 默认为普通用户
@property(nonatomic,assign)NSNumber *auto_unlock;//自动开锁判断
@property(nonatomic,assign)NSNumber *scene_id;  //场景id
@property(nonatomic,copy)NSString*scene_name;   //场景名字
@property(nonatomic,copy)NSString*note_name;    //备注名字
@property(nonatomic,copy)NSString*device_id;    //设备识别码
@property(nonatomic,copy)NSString*device_Brand; //品牌名字
@property(nonatomic,copy)NSString*device_location; //位置
@property(nonatomic,assign)NSNumber *connect_code; //握手码
@property(nonatomic,assign)NSNumber *signal_set; //


//升级头信息发送
-(void)sendSysHeaderData:(NSData*)headData;
//实际数据信息  /每条
-(void)sendSysFirmwareData:(NSData*)firmwareData;

//0xFA51
//管理员 生成配匙码
-(void)sendCodeForAddKey;
//读取RSSI的值
-(void)readRSSI;
//发送连接握手码
-(void)sendConnectionCode;
//发送注册密码
-(void)sendUnlockPassword;
//发送登陆密码
-(void)sendLoginPassword;
//发送配匙码
-(void)sendAccessCode:(NSString*)code;
//发送开锁信号
-(void)sendOpenLockSignal;
//取消开锁信号
-(void)sendCloseLockSignal;
//删除自己的钥匙
-(void)sendDeleteCode;
//发送查询钥匙指令
-(void)sendQueryKeyCode;
//读取chc_UpdateTime值 包括钥匙和其它返回值
-(void)readAllKey;
//删除指定钥匙
-(void)sendDeleteCode:(NSData*)data;

//发送查询键盘密码指令
-(void)sendQueryKeyboardPwd;
//发送开关键盘钥匙指令
-(void)sendIsOpenKeyboard:(BOOL)open KeyPwd:(NSData*)pwdData;

//校准RSSI
-(void)sendRSSICommand;
@end
