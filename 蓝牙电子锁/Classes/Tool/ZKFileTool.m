//
//  ZKFileTool.m
//  蓝牙电子锁
//
//  Created by mosaic on 2018/1/6.
//  Copyright © 2018年 mosaic. All rights reserved.
//

#import "ZKFileTool.h"

@implementation ZKFileTool

+(BOOL) isFileExist:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:filePath];
    ZKLog(@"这个文件：%@",result?@"是的":@"不存在");
    return result;
}


//获取文件大小
+ (long long)fileSizeAtPath:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath])
    {
        return 0;
    }
    else
    {
        return [[fileManager attributesOfItemAtPath:filePath error:nil] fileSize];
    }

}

@end
