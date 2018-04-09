//
//  ZKCommonData.m
//  蓝牙电子锁
//
//  Created by mosaic on 2017/11/24.
//  Copyright © 2017年 mosaic. All rights reserved.
//

#import "ZKCommonData.h"
@interface ZKCommonData()
@property (nonatomic,strong)FMDatabaseQueue *dataBaseQueue;

@end
@implementation ZKCommonData


@synthesize dataBaseQueue;
singleton_implementation(ZKCommonData)

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *dbPath = [NSString stringWithFormat:@"%@/Documents/blePer.db", NSHomeDirectory()];
        ZKLog(@"%@",dbPath);
        dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
        [dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            [db executeUpdate:@"CREATE TABLE IF NOT EXISTS ble_perList (id integer PRIMARY KEY AUTOINCREMENT, identifier text, type integer,auto_unlock integer,scene_id integer,scene_name text,note_name text,device_Id text,device_Brand text,device_location text,connect_code integer,signal_set integer);"];
        }];
    }
    return self;
}
//type  1 -- 管理员用户   2 -- 普通用户
//auto_unlock   1 -- 自动开锁   2 -- 手动开锁

-(NSMutableArray *)matchPer{
    if (!_matchPer) {
        _matchPer = [NSMutableArray array];
        //从本地数据库中获取所有已添加设备
        [dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            FMResultSet *res = [db executeQuery:@"SELECT * FROM ble_perList"];
            while ([res next]) {
                ZKPeripheral *per = [[ZKPeripheral alloc]init];
                per.identifier = [res stringForColumn:@"identifier"];
                per.type = [NSNumber numberWithInt:[res intForColumn:@"type"]];
                per.auto_unlock = [NSNumber numberWithInt:[res intForColumn:@"auto_unlock"]];
                per.scene_id = [NSNumber numberWithInt:[res intForColumn:@"scene_id"]];
                per.scene_name = [res stringForColumn:@"scene_name"];
                per.note_name = [res stringForColumn:@"note_name"];
                per.device_id = [res stringForColumn:@"device_id"];
                per.device_Brand = [res stringForColumn:@"device_Brand"];
                per.device_location = [res stringForColumn:@"device_location"];
                per.connect_code = [NSNumber numberWithInt:[res intForColumn:@"connect_code"]];
                per.signal_set =[NSNumber numberWithInt:[res intForColumn:@"signal_set"]];
                [_matchPer addObject:per];
            }
        }];        
    }
    return _matchPer;
}

-(NSMutableArray<ZKPeripheral *> *)autoReconnectPer{
    if (!_autoReconnectPer) {
        _autoReconnectPer = [NSMutableArray array];
        for (ZKPeripheral*per in self.matchPer) {
            if (per.auto_unlock.intValue == 1) {
                [_autoReconnectPer addObject:per];
            }
        }
    }
    return _autoReconnectPer;
}




-(NSMutableArray<ZKPeripheral *> *)scanPer{
    
    if (!_scanPer) {
        _scanPer = [NSMutableArray array];
    }
    return _scanPer;
}





-(NSMutableArray<ZKPeripheral *> *)scanAddedPer{
    if (!_scanAddedPer) {
        _scanAddedPer = [NSMutableArray array];
    }
    return _scanAddedPer;
}

-(NSMutableArray<ZKPeripheral *> *)connectedPer{
    if (!_connectedPer) {
        _connectedPer = [NSMutableArray array];
    }
    return _connectedPer;
}

//添加数据至数据库，并更新缓存
-(BOOL)addPerToDatabase:(ZKPeripheral*)zkper{
   __block BOOL result ;
    //判断zkper是否已经存在于数据库
    for (ZKPeripheral*per in self.matchPer) {
        if ([zkper.identifier isEqualToString:per.identifier]) {
            return NO;
        }
    }
    
    [dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
      result =  [db executeUpdate:@"INSERT INTO ble_perList(identifier,type,auto_unlock,scene_id,scene_name,note_name,device_Id,device_Brand,device_location,connect_code,signal_set)VALUES(?,?,?,?,?,?,?,?,?,?,?)",zkper.identifier,zkper.type,zkper.auto_unlock,zkper.scene_id,zkper.scene_name,zkper.note_name,zkper.device_id,zkper.device_Brand,zkper.device_location,zkper.connect_code,zkper.signal_set];
    }];
    self.matchPer = nil;
    self.autoReconnectPer = nil;
    return result;
}

//删除数据 并更新缓存
-(BOOL)deletePerToDatabase:(ZKPeripheral*)zkper{
    __block BOOL result ;
    [dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        
        result =  [db executeUpdate:@"DELETE FROM ble_perList WHERE identifier = ?",zkper.identifier];
    }];
    self.matchPer = nil;
    self.autoReconnectPer = nil;
    return result;
}


//修改更新数据  并更新缓存
-(BOOL)updatePerToDatabase:(ZKPeripheral*)zkper{
    __block BOOL result ;
    [dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        result =  [db executeUpdate:@"UPDATE ble_perList SET type = ? ,auto_unlock =? ,scene_id = ?,note_name = ? ,device_location = ?,signal_set = ?  WHERE identifier=?",zkper.type,zkper.auto_unlock,zkper.scene_id,zkper.note_name,zkper.device_location,zkper.signal_set,zkper.identifier];
    }];
    self.matchPer = nil;
    self.autoReconnectPer = nil;
    return result;
}




@end
