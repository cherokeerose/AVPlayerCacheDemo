//
//  CrFileHandle.h
//  Rosalaevigata
//
//  Created by ltr on 2017/7/8.
//  Copyright © 2017年 刘天荣. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrFileHandle : NSObject


#pragma mark - ---------- temporary ----------
/**
 *  创建名为fileName的临时文件，若已有则会先删除再创建
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
 *  移除名为fileName的临时文件
 *  @param fileName 临时文件名
 *  @return 删除成功
 */
+ (BOOL)removeTempFile:(NSString *)fileName;

/**
*  向名为fileName的临时文件从头开始写数据
*  @param data 写入的数据
*  @param fileName 临时文件名
*/
+ (void)writeData:(NSData *)data toTempFile:(NSString *)fileName;

/**
*  向名为fileName的临时文件追加数据
*  @param data 追加的数据
*  @param fileName 临时文件名
*/
+ (void)appendData:(NSData *)data atTempFile:(NSString *)fileName;

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

#pragma mark - ---------- utility ----------
/**
 是否存在文件或文件夹

 @param file 文件或文件夹完整路径
 @return 存在结果
 */

+ (BOOL)isExistsFile:(NSString *)file;

/**
 读取沙盒下的某个文件数据

 @param file 文件完整路径
 @return 读取的数据
 */
+ (NSData *)readFile:(NSString *)file;

/**
 读取文件夹下的文件，不包含文件夹和子文件

 @param path 路径
 @return 所有文件的文件名
 */
+ (NSArray<NSString *> *)getFilesAtPath:(NSString *)path;

/**
 创建文件夹

 @param path 路径
 @return 是否成功，包含已经存在
 */
+ (BOOL)createFolder:(NSString *)path;

/**
 向文件写入数据，文件不存在会创建，若文件已存在则会删除原文件

 @param data 写入的数据
 @param file 完整文件路径
 @return 写入成功
 */
+ (BOOL)writeData:(NSData *)data toFile:(NSString *)file;

/**
 向文件末尾追加数据，文件不存在会创建

 @param data 追加的数据
 @param file 完整文件路径
 @return 追加成功
 */
+ (BOOL)appendData:(NSData *)data atFile:(NSString *)file;

/**
 *  将file拷贝到path目录下并重命名为fileName，文件冲突会失败
 *  @param file 拷贝的完整文件路径
 *  @param path 保存目录
 *  @param fileName 保存文件名，若为nil，则不重命名
 *  @return 拷贝结果
 */
+ (BOOL)copyFile:(NSString *)file toPath:(NSString *)path withName:(NSString *)fileName;

/**
 删除沙盒下的文件

 @param file 删除的完整文件路径
 @return 是否成功
 */
+ (BOOL)removeFile:(NSString *)file;

/**
 清空目录

 @param path 要清空的目录
 @return 是否成功
 */
+ (BOOL)clearFileAtPath:(NSString *)path;

@end
