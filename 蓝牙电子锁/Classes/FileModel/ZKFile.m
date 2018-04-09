//
//  ZKFile.m
//  蓝牙电子锁
//
//  Created by mosaic on 2018/1/8.
//  Copyright © 2018年 mosaic. All rights reserved.
//

#import "ZKFile.h"
#define OFFSET 16 //每次读取文件的16个字节
@implementation ZKFile

- (instancetype)initWithFilePath:(NSString*)path
{
    self = [super init];
    if (self) {
        _filePath = path;
        _fileName = [path lastPathComponent];
        _fileSize = [ZKFileTool fileSizeAtPath:path];
        //获取文件总大小
        _trunks = (_fileSize%OFFSET==0)?((int)(_fileSize/OFFSET)):((int)(_fileSize/(OFFSET) + 1));
    }
    return self;
}

-(NSMutableArray *)fileArr{
    if (!_fileArr) {
        NSMutableArray *tempArry = [NSMutableArray array];
        for (int i=0; i<self.trunks; i++) {
            NSString *str = @"unfinished";
            [tempArry addObject:str];
        }
        _fileArr = tempArry;
    }
    return _fileArr;
}

//读取指定第chunk块的数据
-(NSData*)readDataWithChunk:(NSInteger)chunk{
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:self.filePath];
    [handle seekToFileOffset:OFFSET*chunk];
    NSData * data = [handle readDataOfLength:OFFSET];
    return data;
}

//标记第tag块为完成状态
-(void)finishUploadAtChunk:(NSInteger)tag {
    if (tag<self.fileArr.count) {
        NSString*tagStr = @"finished";
        [self.fileArr replaceObjectAtIndex:tag withObject:tagStr];
    }
}

////分段读取文件
//-(NSMutableArray*)readFileWith:(NSString*)path{
//    int offset =16;//每次读取文件的16个字节
//    //获取文件总大小
//    long long fileSize = [ZKFileTool fileSizeAtPath:path];
//    ZKLog(@"%lld",fileSize);
//    if (fileSize<1) {
//        return nil;
//    }
//    //文件总片数
//    NSInteger chunks = (fileSize%offset==0)?((int)(fileSize/offset)):((int)(fileSize/(offset) + 1));
//    
//    
//    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
//    //获取文件第一段数据 ,处理头部信息
//    [handle seekToFileOffset:0];
//    NSData * data = [handle readDataOfLength:offset];
//    ZKLog(@"第1段数据:%@",data);
//    //
//    for (int i=1; i<chunks; i++) {
//        [handle seekToFileOffset:offset*i];
//        NSData * data = [handle readDataOfLength:offset];
//        ZKLog(@"第%d段数据:%@",i+1,data);
//    }
//    [handle closeFile];
//    
//    return nil;
//}
-(void)dealloc{
    
}

@end
