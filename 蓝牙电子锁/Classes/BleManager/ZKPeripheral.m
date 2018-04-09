//
//  ZKPeripheral.m
//  MosaicLightBLE
//
//  Created by mosaic on 2017/6/6.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import "ZKPeripheral.h"
@interface ZKPeripheral ()
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,assign)BOOL  islockDistance;//是否符合开锁距离
@property(nonatomic,assign)BOOL  isPwdSuccess;//是否符合开锁权限
@end
@implementation ZKPeripheral{
//    NSTimer *_RSSITimer;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isAutoConnect = YES;
        self.islockDistance = NO;
        self.isPwdSuccess = NO;
        self.keyboardStatus = KeyboardStatusNone;
    }
    return self;
}

-(void)setPeripheral:(CBPeripheral *)peripheral{
    _peripheral = peripheral;
    _peripheral.delegate = self;
}


//-(instancetype)initWith:(CBPeripheral*)peripheral{
//    self = [super init];
//    if (self) {
//        self.peripheral = peripheral;
//        self.peripheral.delegate = self;
////        ZKLog(@"当前线程：%@",[NSThread currentThread]);
////        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(readRSSI) userInfo:nil repeats:YES];
//    }
//    return self;
//}

-(void)readRSSI{
    [self.peripheral readRSSI];
}
//升级头信息发送
-(void)sendSysHeaderData:(NSData*)headerData{
    if (self.peripheral&&self.chc_Identify) {
        [self.peripheral writeValue:headerData forCharacteristic:self.chc_Identify type:CBCharacteristicWriteWithResponse];
    }
}
//实际数据信息  /每条
-(void)sendSysFirmwareData:(NSData*)firmwareData{
    if (self.peripheral&&self.chc_Block) {
        [self.peripheral writeValue:firmwareData forCharacteristic:self.chc_Block type:CBCharacteristicWriteWithResponse];
    }
}
//生成配匙码
-(void)sendCodeForAddKey{
    if (self.peripheral) {
        Byte type[2];
        type[0]=11;
        type[1]=0x01;
        NSData*data =[NSData dataWithBytes:type length:2];
        if (self.chc_UpdateTime) {
            [self.peripheral writeValue:data forCharacteristic:self.chc_UpdateTime type:CBCharacteristicWriteWithResponse];
            ZKLog(@"生成配匙码操作：%@",data);
        }
    }
}

//发送握手码
-(void)sendConnectionCode{
    if (self.peripheral) {
        //connect_code为int类型存储和转换  类型是 0x02
        //类型
        Byte type[1];
        type[0]=0x02;
        NSMutableData*data =[NSMutableData dataWithBytes:type length:1];
        int code = self.connect_code.intValue;
        //握手码
        NSData*codeData = [NSData dataWithBytes:&code length:2];
        ZKLog(@"%lu",sizeof(code));
        //拼接数据
        [data appendData:codeData];
        NSData *timeTData ;
        //管理员发送带时间参数的握手码
        if (self.type.intValue==1) {
            //类型
            type[0]=0x01;
            timeTData = [NSData dataWithBytes:type length:1];
        }else{
            //类型
            type[0]=0x00;
            timeTData = [NSData dataWithBytes:type length:1];
        }
        //时间
        //发送命令
        NSDate *date = [NSDate date];
        int time = [date timeIntervalSince1970];
        ZKLog(@"%d",time);
        NSData*timeData =  [NSData dataWithBytes:&time length:4];
        ZKLog(@"timeData:%@",timeData);
        ZKLog(@"data:%@",data);
        [data appendData:timeTData];
        [data appendData:timeData];
//        自动开锁权限
        NSData*auto_unlockData;
        if (self.auto_unlock.intValue == 1) {//自动开锁
            type[0]=0x01;
            auto_unlockData = [NSData dataWithBytes:type length:1];
        }else{
            type[0]=0x00;
            auto_unlockData = [NSData dataWithBytes:type length:1];
        }
        [data appendData:auto_unlockData];
        //信号值
        NSData*RssiData;
        if (self.signal_set) {
            type[0] = self.signal_set.intValue;
           RssiData = [NSData dataWithBytes:type length:1];
            [data appendData:RssiData];
        }

        ZKLog(@"%@",data);
        
        if (self.chc_ConenctCode) {
            [self.peripheral writeValue:data forCharacteristic:self.chc_ConenctCode type:CBCharacteristicWriteWithResponse];
            ZKLog(@"握手码:%@",self.connect_code);
            ZKLog(@"发送握手码:%@",data);
        }
    }
}
//029aec01 46846e5a
//0291be
//发送注册密码
-(void)sendUnlockPassword{
    if (self.peripheral) {
        //发送密码
        UICKeyChainStore*keychainStore=[UICKeyChainStore keyChainStoreWithService:@"自定义存储"];
        NSString *deviceUUID = [keychainStore stringForKey:@"passwordabc"];
        if (!deviceUUID||deviceUUID.length==0) {
            deviceUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
            keychainStore[@"passwordabc"] = deviceUUID;
        }
        Byte type[1];
        type[0]=0x65;
        NSMutableData*pwdData =[NSMutableData dataWithBytes:type length:1];
        NSData* pwdcode = [deviceUUID dataUsingEncoding:NSASCIIStringEncoding ];
        [pwdData appendData:pwdcode];
        if (self.chc_UnlockPwd) {
            [self.peripheral writeValue:pwdData forCharacteristic:self.chc_UnlockPwd type:CBCharacteristicWriteWithResponse];
            ZKLog(@"发送注册密码：%@",pwdData);
        }
    }
}
//发送登录密码
-(void)sendLoginPassword{
     if (self.peripheral) {
    //发送密码
         UICKeyChainStore*keychainStore=[UICKeyChainStore keyChainStoreWithService:@"自定义存储"];
         NSString *deviceUUID = [keychainStore stringForKey:@"passwordabc"];
         if (!deviceUUID||deviceUUID.length==0) {
             deviceUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
             keychainStore[@"passwordabc"] = deviceUUID;
         }
         Byte type[1];
         type[0]=0x64;
         NSMutableData*pwdData =[NSMutableData dataWithBytes:type length:1];
         NSData* pwdcode = [deviceUUID dataUsingEncoding:NSASCIIStringEncoding ];
         [pwdData appendData:pwdcode];
         if (self.chc_UnlockPwd) {
             [self.peripheral writeValue:pwdData forCharacteristic:self.chc_UnlockPwd type:CBCharacteristicWriteWithResponse];
             ZKLog(@"发送登录密码:%@",pwdData);
         }
     }
}
//发送配匙码
-(void)sendAccessCode:(NSString*)code{
    if (self.peripheral) {
        //NSString转int
        int res = code.intValue;
//        NSData*strData = [code dataUsingEncoding:NSASCIIStringEncoding ];
        
        NSData*strData = [NSData dataWithBytes:&res length:sizeof(int)];
        ZKLog(@"%@",strData);
        NSMutableData*data = [NSMutableData dataWithData:[NSData convertHexStrToData:@"03"]];
        [data appendData:strData];
        //发送验证码
        if (self.chc_ConenctCode) {
            [self.peripheral writeValue:data forCharacteristic:self.chc_ConenctCode type:CBCharacteristicWriteWithResponse];
            ZKLog(@"发送配匙码:%@",data);
        }
    }
}
//发送开锁信号
-(void)sendOpenLockSignal{
    
    if (self.peripheral) {
        //类型
        Byte type[1];
        type[0]=0x04;
        NSMutableData*data =[NSMutableData dataWithBytes:type length:1];
        int code = 1;//1表示开锁  2表示取消开锁
        //握手码
        NSData*codeData = [NSData dataWithBytes:&code length:sizeof(code)];
        //拼接数据
        [data appendData:codeData];
        if (self.chc_ConenctCode) {
            [self.peripheral writeValue:data forCharacteristic:self.chc_ConenctCode type:CBCharacteristicWriteWithResponse];
            ZKLog(@"发送开锁信号:%@",data);
        }
    }
}
//取消开锁信号
-(void)sendCloseLockSignal{
    if (self.peripheral) {
        if (self.peripheral) {
            //类型
            Byte type[1];
            type[0]=0x04;
            NSMutableData*data =[NSMutableData dataWithBytes:type length:1];
            int code = 2;//1表示开锁  2表示取消开锁
            //握手码
            NSData*codeData = [NSData dataWithBytes:&code length:sizeof(code)];
            //拼接数据
            [data appendData:codeData];
            if (self.chc_ConenctCode) {
                [self.peripheral writeValue:data forCharacteristic:self.chc_ConenctCode type:CBCharacteristicWriteWithResponse];
                ZKLog(@"取消开锁信号:%@",data);
            }
        }
    }
}
//删除钥匙
-(void)sendDeleteCode{
    if (self.peripheral) {
        if (self.peripheral) {
            UICKeyChainStore*keychainStore=[UICKeyChainStore keyChainStoreWithService:@"自定义存储"];
            NSString *deviceUUID = [keychainStore stringForKey:@"passwordabc"];
            if (!deviceUUID||deviceUUID.length==0) {
                deviceUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
                keychainStore[@"passwordabc"] = deviceUUID;
            }
            //类型
            Byte type[1];
            type[0]=0x66;
            NSMutableData*pwdData =[NSMutableData dataWithBytes:type length:1];
            NSData* pwdcode = [deviceUUID dataUsingEncoding:NSASCIIStringEncoding ];
            [pwdData appendData:pwdcode];
            if (self.chc_UnlockPwd) {
                [self.peripheral writeValue:pwdData forCharacteristic:self.chc_UnlockPwd type:CBCharacteristicWriteWithResponse];
                ZKLog(@"删除钥匙:%@",pwdData);
            }
        }
    }
}
//发送查询钥匙指令
-(void)sendQueryKeyCode{
    if (self.peripheral) {
        //类型
        Byte type[2];
        type[0]=0x09;
        type[1]=10;
        NSMutableData*data =[NSMutableData dataWithBytes:type length:2];
        if (self.chc_UpdateTime) {
            [self.peripheral writeValue:data forCharacteristic:self.chc_UpdateTime type:CBCharacteristicWriteWithResponse];
        }
    }
}
//读取钥匙
-(void)readAllKey{
    if (self.peripheral) {
        if (self.chc_UpdateTime) {
            [self.peripheral readValueForCharacteristic:self.chc_UpdateTime];
        }
    }
}
//管理员删除钥匙
-(void)sendDeleteCode:(NSData*)data{
    if (self.peripheral) {
        if (self.chc_UpdateTime) {
            Byte type[2];
            type[0]=10;
            type[1]=1;
            NSMutableData*codeData = [NSMutableData dataWithBytes:&type length:2];
            [codeData appendData:data];
            [self.peripheral writeValue:codeData forCharacteristic:self.chc_UpdateTime type:CBCharacteristicWriteWithResponse];
        }
    }
}

//发送查询键盘密码指令
-(void)sendQueryKeyboardPwd{
    if (self.peripheral&&self.chc_UpdateTime) {
        //类型
        Byte type[2];
        type[0]=17;
        type[1]=0xff;
        NSMutableData*data =[NSMutableData dataWithBytes:type length:2];
        [self.peripheral writeValue:data forCharacteristic:self.chc_UpdateTime type:CBCharacteristicWriteWithResponse];
        ZKLog(@"发送查询键盘密码指令:%@",data);
    }
}
//发送开关钥匙指令及设置密码
-(void)sendIsOpenKeyboard:(BOOL)open KeyPwd:(NSData*)pwdData{
    ZKLog(@"%@",self.KeyboardPwdData);
    ZKLog(@"%@",self.peripheral);
    ZKLog(@"%@",self.chc_UpdateTime);
    if (self.KeyboardPwdData&&self.peripheral&&self.chc_UpdateTime) {
        //类型
        Byte type[2];
        type[0]=17;
        type[1]=open;
        NSMutableData*data =[NSMutableData dataWithBytes:type length:2];
        [data appendData:pwdData];
        [self.peripheral writeValue:data forCharacteristic:self.chc_UpdateTime type:CBCharacteristicWriteWithResponse];
        ZKLog(@"发送开关钥匙指令及设置密码:%@",data);
    }
}
//校准RSSI
-(void)sendRSSICommand{
    if (self.peripheral&&self.chc_UpdateTime) {
        //类型
        Byte type[2];
        type[0]=37;
        type[1]=0xff;
        NSData*data =[NSData dataWithBytes:type length:2];
         [self.peripheral writeValue:data forCharacteristic:self.chc_UpdateTime type:CBCharacteristicWriteWithResponse];
    }
}
#pragma mark == ==

//扫描到services
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    
    if (error)
    {
        ZKLog(@"Error discovering services: %@", [error localizedDescription]);
        return;
    }
    for (CBService *service in peripheral.services) {
        
        if ([service.UUID.UUIDString isEqualToString:UUID_LOCK_SERVER]) {//
            [peripheral discoverCharacteristics:nil forService:service];
        }else if ([service.UUID.UUIDString isEqualToString:UUID_UPGRADE_SERVER]){
            [peripheral discoverCharacteristics:nil forService:service];
        }else if ([service.UUID.UUIDString isEqualToString:@"180A"]){
            [peripheral discoverCharacteristics:nil forService:service];
        }else if ([service.UUID.UUIDString isEqualToString:@"180F"]){
            [peripheral discoverCharacteristics:nil forService:service];
        }
        ZKLog(@"服务：%@",service.UUID.UUIDString);
    }
}

//扫描到服务中的特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error{
    
    if (error)
    {
        ZKLog(@"Error didDiscoverCharacteristicsForService: %@", [error localizedDescription]);
        return;
    }
    
    
    for (CBCharacteristic *characteristic in service.characteristics){
        if ([characteristic.UUID.UUIDString isEqualToString:UUID_LOCK_ReturnCode]){
            self.chc_ReturnCode = characteristic;
            //订阅特征
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        if ([characteristic.UUID.UUIDString isEqualToString:UUID_LOCK_UpdateTime]){
            self.chc_UpdateTime = characteristic;
            [peripheral readValueForCharacteristic:characteristic];
        }
        if ([characteristic.UUID.UUIDString isEqualToString:UUID_LOCK_ConenctCode]){
            self.chc_ConenctCode = characteristic;
        }
        if ([characteristic.UUID.UUIDString isEqualToString:UUID_LOCK_KeyCode]){
            self.chc_KeyCode = characteristic;
        }
        if ([characteristic.UUID.UUIDString isEqualToString:UUID_LOCK_UnlockPwd]){
            self.chc_UnlockPwd = characteristic;
        }
        if ([characteristic.UUID.UUIDString isEqualToString:UUID_LOCK_KeyPwd]){
            self.chc_KeyPwd = characteristic;
        }
        if ([characteristic.UUID.UUIDString isEqualToString:@"2A26"]) {
//            Firmware
            self.chc_Firmware = characteristic;
            
            self.firmware = [[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
            ZKLog(@"固件版本:%@",self.firmware);
            ZKLog(@"%@",characteristic.value);
            [peripheral readValueForCharacteristic:characteristic];
        }
        if ([characteristic.UUID.UUIDString isEqualToString:@"2A27"]) {
            self.chc_Hardware = characteristic;
            self.upgradeStr = [[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];;
            [peripheral readValueForCharacteristic:characteristic];
        }
//        180F
        if ([characteristic.UUID.UUIDString isEqualToString:@"2A19"]) {
            self.chc_battery = characteristic;
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        if ([characteristic.UUID.UUIDString isEqualToString:UUID_UPGRADE_Identify]){
            self.chc_Identify = characteristic;
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        if ([characteristic.UUID.UUIDString isEqualToString:UUID_UPGRADE_Block]){
            self.chc_Block = characteristic;
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        if ([characteristic.UUID.UUIDString isEqualToString:UUID_UPGRADE_Status]){
            self.chc_Status = characteristic;
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        ZKLog(@"特征描述：%@",characteristic.UUID.UUIDString);
    }
    
    //自动开锁模式下
    if ([ZKBleManager sharedZKBleManager].scanType !=BLEAddDeviceScanning ) {
        //1、发送连接握手码
        [self sendConnectionCode];
        //2、发送密码
        [self sendLoginPassword];
        //3、管理员发送查询钥匙命令
        if (self.type.intValue==1) {
            [self sendQueryKeyCode];//查询钥匙列表
            [self sendQueryKeyboardPwd];//查询键盘锁开关状态
        }
    }else{
        //1、发送连接握手码  //添加设备模式下为固定码
        NSData*data =[NSData convertHexStrToData:COMMAND_CONCODE];
        if (self.chc_ConenctCode) {
            [self.peripheral writeValue:data forCharacteristic:self.chc_ConenctCode type:CBCharacteristicWriteWithResponse];
            ZKLog(@"发送握手码:%@",data);
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.peripheralDelegate respondsToSelector:@selector(customPeripheralDidDiscoverCharacteristics:error:)]) {
            [self.peripheralDelegate customPeripheralDidDiscoverCharacteristics:self error:error];
        }
    });
    
}

//接收外设发过来的值
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    ZKLog(@"接收到的数据:%@",characteristic.value);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.peripheralDelegate respondsToSelector:@selector(customPeripheral:DidUpdateValueForCharacteristic:error:)]) {
            [self.peripheralDelegate customPeripheral:self DidUpdateValueForCharacteristic:characteristic error:error];
        }
       //固件版本
        if ([characteristic isEqual:self.chc_Firmware]) {
            self.firmware = [[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
            ZKLog(@"固件版本:%@",self.firmware);
        }
        if ([characteristic isEqual:self.chc_Hardware]) {
            self.upgradeStr = [[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
            ZKLog(@"硬件版本:%@",self.upgradeStr);
            
        }
        //电池信息
        if ([characteristic isEqual:self.chc_battery]) {
            NSString*str = [[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
//            ZKLog(@"电池信息:%@ %@",str,characteristic.value);
            int buff =0;
            [characteristic.value getBytes:&buff length:1];
//            ZKLog(@"%d",buff);
            self.battery = buff;
            if ( self.battery<30) {
                [ZKNotificationView show:[NSString stringWithFormat:@"%@电池电量低于%d%%",self.note_name,self.battery] willShowBlock:^{
                    
                } Tapblock:^{
                    
                } didShowBlock:^{
                    
                }];
            }
        }
        
        //升级-Identify
        if ([characteristic isEqual:self.chc_Identify]) {
            ZKLog(@"chc_Identify:%@",characteristic.value);
        }
        //升级-Block
        if ([characteristic isEqual:self.chc_Block]) {
            ZKLog(@"chc_Block:%@",characteristic.value);
            
        }
        //升级-Status
        if ([characteristic isEqual:self.chc_Status]) {
            ZKLog(@"chc_Status:%@",characteristic.value);
        }
        //读取到chc_UpdateTime
        if ([characteristic isEqual:self.chc_UpdateTime]) {
            NSData*resultData = characteristic.value;
            if (resultData.length<1) {
                return ;
            }
            //截取第一个字节判断类型
            Byte buff[1];
            [resultData getBytes:buff length:1];
            int res = buff[0];
            NSLog(@"%d %d",buff[0],res);
            if (buff[0]==17) {//键盘锁开关
                //第二个字节判断开关状态
                NSData*value = [resultData subdataWithRange:NSMakeRange(1, 1)];
                BOOL isOpen;
                [value getBytes:&isOpen length:1];
                self.isOpenKeyboard = isOpen;
                //获取到密码
                self.KeyboardPwdData = [resultData subdataWithRange:NSMakeRange(2,4)];
                ZKLog(@"chc_UpdateTime:%@",resultData);
                ZKLog(@"chc_UpdateTime密码:%@",self.KeyboardPwdData);
//               long  pwd = 0;
//                [self.KeyboardPwdData getBytes:&pwd length:4];
//                ZKLog(@"密码:%ld",pwd);
                NSLog(@"%d,%d",self.isOpenKeyboard,self.keyboardStatus);
                if (self.isOpenKeyboard&&self.keyboardStatus==KeyboardStatusOpen) {
                    [ZKNotificationView show:[NSString stringWithFormat:@"“%@”键盘开锁权限已开启",self.note_name] delay:1.5 willShowBlock:^{
                    } Tapblock:^{} didShowBlock:^{}];
                }else if (!self.isOpenKeyboard&&self.keyboardStatus==KeyboardStatusClose){
                    [ZKNotificationView show:[NSString stringWithFormat:@"“%@”键盘开锁权限已关闭",self.note_name] delay:1.5 willShowBlock:^{
                    } Tapblock:^{} didShowBlock:^{}];
                }else if (self.keyboardStatus == KeyboardStatusSet){
                    [ZKNotificationView show:[NSString stringWithFormat:@"“%@”键盘开锁密码已设置",self.note_name] delay:1.5 willShowBlock:^{
                    } Tapblock:^{} didShowBlock:^{}];
                }
                self.keyboardStatus = KeyboardStatusNone;
            }
        }
        //接收到设备通知
        if ([characteristic isEqual:self.chc_ReturnCode]) {
            NSData*resultData = characteristic.value;
            if (resultData.length<1) {
                return ;
            }
            
            //从第二个字节开始截取数据
            NSData*value = [resultData subdataWithRange:NSMakeRange(1, resultData.length-1)];
            //截取第一个字节判断类型
            Byte buff[1];
            [resultData getBytes:buff length:1];
            ZKPeripheralCode returnCod = buff[0];
            ZKLog(@"业务通知:%@",resultData)

//            if (returnCod==3){
//            } else{ ZKLog(@"业务通知:%@",resultData)};

            //获得开锁权限时提示
            if (returnCod == PeripheralNotiyLockAccess) {
                NSString *msg ;
                if (self.note_name) {
                    msg = self.note_name;
                }else{
                    msg = peripheral.name;
                }
            }
            
            //通知代理
            if ([self.peripheralDelegate respondsToSelector:@selector(customPeripheral:NotiyCode:value:error:)]) {
                [self.peripheralDelegate customPeripheral:self NotiyCode:returnCod value:value error:error];
            }
            switch (returnCod) {
                case PeripheralNotiyDefualt:{
                    
    
                }
                    break;
                case PeripheralNotiyHandCodeSuccess:{//2、手机与设备连接握手成功
                    
                    
                }
                    break;
                case PeripheralNotiyPasswordSuccess:{//3、密文验证成功
                    ZKLog(@"密码验证成功");
                    if ([self.identifyController isEqualToString:@"ZKUnlockController"]&&[ZKBleManager sharedZKBleManager].scanType== BLEAutoConnectScanning ) {//在开锁界面 且在前台模式，屏蔽自动开锁
                    }else{
                        
                        //3、判断是否有权限发送开锁信号
                        if (self.auto_unlock.intValue == 1&&self.isAutoConnect) {//1为自动开锁 2为手动开锁
                            self.isPwdSuccess = YES;//获得开锁权限
                            //在合适距离内发送开锁信号
//                            [self readRSSI];
                        }
                    }
                    [peripheral readValueForCharacteristic:self.chc_battery];

                }
                    break;
                case PeripheralNotiyAddAdminKeySuccess:{//管理员钥匙添加成功
                    
                    
                }
                    break;
                case PeripheralNotiyAddKeyCodeFail:{//5、密匙添加失败
                    
                }
                    break;
                case PeripheralNotiyBlackList:{//6、已列为黑名单
                    [[ZKBleManager sharedZKBleManager] disConnectPeripheral:peripheral];
                    self.isAutoConnect = NO;
                }
                    break;
                case PeripheralNotiyLockAccess:{//7、可以开锁
                    ZKLog(@"开锁");
                    self.isAutoConnect = YES;
                    [ZKNotificationView show:[NSString stringWithFormat:@"“%@”电子锁可以开锁",self.note_name] delay:1.5 willShowBlock:^{
                    } Tapblock:^{} didShowBlock:^{}];
                    
                    [ZKNotificationView ShowLocalNotification:[NSString stringWithFormat:@"“%@”电子锁可以开锁",self.note_name]];
                }
                    break;
                case PeripheralNotiyCloseLockAccess:{//8、关闭开锁
                    ZKLog(@"关锁");
                    self.isAutoConnect = YES;
                    [ZKNotificationView show:[NSString stringWithFormat:@"“%@”电子锁已锁定",self.note_name] delay:1.5 willShowBlock:^{
                    } Tapblock:^{} didShowBlock:^{}];
                    [ZKNotificationView ShowLocalNotification:[NSString stringWithFormat:@"“%@”电子锁已锁定",self.note_name]];
                   
                    if ([self.identifyController isEqualToString:@"ZKUnlockController"]&&[ZKBleManager sharedZKBleManager].scanType== BLEAutoConnectScanning ) {//在开锁界面 且在前台模式，屏蔽自动开锁
                    }else{
                        //3、判断是否有权限发送开锁信号
                        if (self.auto_unlock.intValue == 1&&self.isAutoConnect) {//1为自动开锁 2为手动开锁
                            self.islockDistance = NO;//设备15秒自动上锁，此时视为超出距离上锁
//                            [self readRSSI];
                        }
                    }
                }
                    break;
                case PeripheralNotiyAddKeySuccess:{//普通用户钥匙添加成功
                    
                    
                }
                    break;
                case PeripheralNotiyHandCodeFail:{//10、手机与设备连接握手失败
                    [[ZKBleManager sharedZKBleManager] disConnectPeripheral:peripheral];
                    self.isAutoConnect = NO;
                    self.isPwdSuccess = NO;

                }
                    break;
                case PeripheralNotiyKeyDisable:{//11、密匙已禁用
                    [[ZKBleManager sharedZKBleManager] disConnectPeripheral:peripheral];
                    self.isAutoConnect = NO;
                    self.isPwdSuccess = NO;
                }
                    break;
                case PeripheralNotiyOnceKeyProduct://12、配匙码生成完成
                    
                    break;
                case PeripheralNotiyKeyExisted:{//13、密匙已存在
                    
                }
                    break;
                case PeripheralNotiyAddKeyCodeAllow:{//14、允许配匙
                    
                }
                    break;
                case PeripheralNotiyPasswordFail:{//15、密文验证失败
                    self.isPwdSuccess = NO;
                    self.isAutoConnect = NO;
                }
                case PeripheralNotiyReadKeyboardSuccess:{
                    [self readAllKey];
                    ZKLog(@"键盘密码读或写操作成功");
                }
                default:
                    break;
            }
        }
    });
    
}
//接收外设发过来的值
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    if (characteristic.isNotifying) {
        ZKLog(@"可以操控");
    }else{
        ZKLog(@"不能操作");
    }
}
//用于检测中心向外设写数据是否成功
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    if (error) {
        ZKLog(@"发送数据失败:%@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [ZKNotificationView show:@"发送数据失败" delay:1 willShowBlock:^{
            } Tapblock:^{
            } didShowBlock:^{
            }];
        });
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error{
    self.RSSI = RSSI;
//    ZKLog(@"RSSI:%@",self.RSSI);
//    NSString *str = peripheral.identifier.UUIDString;
//    str =[str substringWithRange:NSMakeRange(0, 5)];
////    ZKLog(@"%@--%d",str,RSSI.intValue);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        //1、在开锁距离内
//        if (RSSI.intValue>self.signal_set.intValue&&!self.islockDistance&&self.isPwdSuccess) {
//            self.islockDistance = YES;//表示已经满足距离,开过锁了
//            //发送开锁信号
//            [self sendOpenLockSignal];
//        }
//        //2、离开权限距离
//        if (RSSI.intValue<self.signal_set.intValue-10&&self.islockDistance&&self.isPwdSuccess) {
//            self.islockDistance = NO;//表示已经超出距离,取消开锁了
//            //发送取消开锁信号
//            [self sendCloseLockSignal];
//        }
//    });
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.peripheralDelegate respondsToSelector:@selector(customPeripheralDidReadRSSI:error:)]) {
            [self.peripheralDelegate customPeripheralDidReadRSSI:self error:error];
        }
    });
}

-(NSString *)identifier{
    if (!_identifier&&_peripheral) {
        _identifier = _peripheral.identifier.UUIDString;
    }
    return _identifier;
}


-(NSNumber *)auto_unlock{
    if (!_auto_unlock||_auto_unlock.intValue!=1) {//2为手动开锁，默认为手动
        _auto_unlock = @(2);
    }
    return _auto_unlock;
}
-(NSNumber *)type{
    if (!_type||_type.intValue!=1) {//1 为管理员用户  2为普通用户 默认为普通用户
        _type = @(2);
    }
    return _type;
}

-(NSNumber *)signal_set{
    if (!_signal_set) {
        _signal_set = @(-65);
    }
    return _signal_set;
}


@end
