//
//  CrResourceData.h
//  AVPlayerCacheDemo
//
//  Created by tw on 2017/9/28.
//  Copyright © 2017年 刘天荣. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrResourceData : NSObject

@property (atomic,    copy  ) NSString      *mineType;      //文件类型
@property (atomic,    assign) NSUInteger    fileLength;     //整个流的长度，对于已知长度的流有效
@property (nonatomic, copy  ) NSString      *fileName;      //网络文件名
@property (nonatomic, assign) BOOL          diskCache;      //YES-硬盘缓冲，NO-内存缓冲，默认NO

@property (nonatomic, copy,   readonly) NSString      *tmpfile;         //在tmp目录下保存的缓存文件名


- (void)appendData:(NSData *)data atOffset:(NSUInteger)offset;
- (NSData *)getDataOffset:(NSUInteger)offset length:(NSUInteger)length;
- (NSData *)getAllData;
- (BOOL)allDataOffset:(NSUInteger)offset length:(NSUInteger)length;     //是否有全部数据
- (BOOL)hasDataOffset:(NSUInteger)offset length:(NSUInteger)length;     //是否包含有数据
- (BOOL)completeCached;

@end
