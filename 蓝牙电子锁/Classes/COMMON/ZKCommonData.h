//
//  ZKCommonData.h
//  蓝牙电子锁
//
//  Created by mosaic on 2017/11/24.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZKPeripheral.h"

@interface ZKCommonData : NSObject

/**
 需要自动重连的per
 */
@property(nonatomic,strong)NSMutableArray <ZKPeripheral*>*autoReconnectPer;

/**
 已连接上的per
 */
@property(nonatomic,strong)NSMutableArray <ZKPeripheral*>*connectedPer;

/**
 扫描到的未添加的per
 */
@property(nonatomic,strong)NSMutableArray <ZKPeripheral*>*scanPer;

/**
 扫描到的已添加的per
 */
@property(nonatomic,strong)NSMutableArray <ZKPeripheral*>*scanAddedPer;
/**
 已经添加过的per
 */
@property(nonatomic,strong)NSMutableArray <ZKPeripheral*>*matchPer;


singleton_interface(ZKCommonData)


/**
 添加per信息至数据库，同时更新缓存数据

 @param zkper ZKPeripheral
 @return 操作成功 -- YES
 */
-(BOOL)addPerToDatabase:(ZKPeripheral*)zkper;


/**
 删除per数据，同时更新缓存数据

 @param zkper ZKPeripheral
 @return 操作成功 -- YES
 */
-(BOOL)deletePerToDatabase:(ZKPeripheral*)zkper;


/**
 更新per数据，同时更新缓存数据
 
 @param zkper ZKPeripheral
 @return 操作成功 -- YES
 */
-(BOOL)updatePerToDatabase:(ZKPeripheral*)zkper;

@end
