//
//  NSString+ZKString.h
//  BM51SEE
//
//  Created by 赵凯 on 2017/4/12.
//  Copyright © 2017年 com.Linhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ZKString)
+ (NSString *)lr_stringDate;

+(NSArray *)getAStringOfChineseCharacters:(NSString *)string;//提取中文字符
//字符串补零操作
+(NSString *)addZero:(NSString *)str withLength:(int)length;

+(NSString *)ToHex:(long long int)tmpid;//十进制转十六进制表示的字符串

+(NSString*)hexToTen:(NSString*)msg;//十六进制转十进制表示的字符串


+(NSString *)convertDataToHexStr:(NSData *)data;
@end
