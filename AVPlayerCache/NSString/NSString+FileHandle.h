//
//  NSString+FileHandle.h
//  Rosalaevigata
//
//  Created by ltr on 2017/7/8.
//  Copyright © 2017年 刘天荣. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FileHandle)

/**
 *  document路径
 */
+ (NSString *)documentPath;

/**
 *  library路径
 */
+ (NSString *)libraryPath;

/**
 *  caches路径
 */
+ (NSString *)cachesPath;

/**
 *  tmp路径
 */
+ (NSString *)temporaryPath;

/**
 *  获取完整路径中的文件名
 *  @param url 路径
 */
+ (NSString *)fileNameFromURL:(NSString *)url;

/**
 *  判断是否为http url
 *  @param url 路径
 */
+ (BOOL)httpURL:(NSString *)url;

@end
