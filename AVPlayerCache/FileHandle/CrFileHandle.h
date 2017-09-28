//
//  CrFileHandle.h
//  Rosalaevigata
//
//  Created by ltr on 2017/7/8.
//  Copyright © 2017年 刘天荣. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrFileHandle : NSObject

/**
 *  创建名为fileName的临时文件
 *  @param fileName 临时文件名
 *  @return 创建成功
 */
+ (BOOL)createTempFile:(NSString *)fileName;

/**
 *  创建一个空的临时文件
 *  @return 创建成功返回文件名，否则返回nil
 */
+ (NSString *)getEmptyTempFile;

/**
 *  创建名为fileName的临时文件
 *  @param fileName 临时文件名
 *  @return 删除成功
 */
+ (BOOL)removeTempFile:(NSString *)fileName;

/**
 *  向名为fileName的临时文件追加数据
 *  @param fileName 临时文件名
 *  @param data 追加数据
 */
+ (void)writeTempFile:(NSString *)fileName data:(NSData *)data;

/**
 *  从名为fileName的临时文件读取所有数据
 *  @param fileName 临时文件名
 *  @return 读取的数据
 */
+ (NSData *)readTempFile:(NSString *)fileName;

/**
 *  从名为fileName的临时文件读取offset开始的所有数据
 *  @param fileName 临时文件名
 *  @param offset 开始位置
 *  @return 读取的数据
 */
+ (NSData *)readTempFile:(NSString *)fileName offset:(NSUInteger)offset;

/**
 *  从名为fileName的临时文件读取offset开始长为length的数据
 *  @param fileName 临时文件名
 *  @param offset 开始位置
 *  @param length 长度
 *  @return 读取的数据
 */
+ (NSData *)readTempFile:(NSString *)fileName offset:(NSUInteger)offset length:(NSUInteger)length;

/**
 *  替换tempFileName中rang范围内的字节为data
 *  @param fileName tmp目录下的临时文件名
 *  @param range 替换范围
 *  @param data 替换数据
 */
+ (void)replaceTempFileData:(NSString *)fileName inRange:(NSRange)range withData:(NSData *)data;

/**
 *  将tempFileName从tmp拷贝到caches下的folder目录下并命名为fileName
 *  @param tempFileName tmp目录下的临时文件名
 *  @param folder 缓存目录
 *  @param fileName 保存文件名
 *  @return 读取的数据
 */
+ (BOOL)copyTempFile:(NSString *)tempFileName toCachesFolder:(NSString *)folder withName:(NSString *)fileName;

/**
 *  检查caches下folder目录中fileName文件是否存在
 *  @param fileName 校验文件
 *  @param folder 缓存目录
 *  @return 校验结果，若存在，则返回完整路径，若不存在，则返回nil
 */
+ (NSString *)file:(NSString *)fileName existsAtCahcesFolder:(NSString *)folder;

/**
 *  清除caches下目录folder中的缓存
 *  @param folder 缓存目录
 *  @return 清除成功
 */
+ (BOOL)clearCacheAtFolder:(NSString *)folder;

/**
 *  清除caches下所有缓存
 *  @return 清除成功
 */
+ (BOOL)clearAllCache;

@end
