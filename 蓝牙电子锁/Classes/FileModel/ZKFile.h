//
//  ZKFile.h
//  蓝牙电子锁
//
//  Created by mosaic on 2018/1/8.
//  Copyright © 2018年 mosaic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZKFileTool.h"
@interface ZKFile : NSObject
@property (nonatomic,copy) NSString* filePath;//文件在app中路径
@property (nonatomic,copy) NSString* fileName;//文件名
@property (nonatomic,assign) NSInteger fileSize;//文件大小
@property (nonatomic,assign) NSInteger trunks;//总片数
@property (nonatomic,strong) NSMutableArray* fileArr;//标记每片的上传状态

- (instancetype)initWithFilePath:(NSString*)path;

//读取指定第chunk块的数据
-(NSData*)readDataWithChunk:(NSInteger)chunk ;
    
//标记第tag块数据已发送成功
-(void)finishUploadAtChunk:(NSInteger)tag;

@end
