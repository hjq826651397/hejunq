//
//  ZKFileTool.h
//  蓝牙电子锁
//
//  Created by mosaic on 2018/1/6.
//  Copyright © 2018年 mosaic. All rights reserved.
//

#import <Foundation/Foundation.h>
#define FirmWare_Path @"bluetoothFirmware.bin"

@interface ZKFileTool : NSObject

+(BOOL) isFileExist:(NSString *)fileName;

//获取文件大小
+ (long long)fileSizeAtPath:(NSString *)filePath;

@end
