//
//  CrResourceDataUnit.h
//  AVPlayerCacheDemo
//
//  Created by tw on 2017/9/28.
//  Copyright © 2017年 刘天荣. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrResourceDataUnit : NSObject

@property (nonatomic, assign, readonly) NSUInteger  offset;     //offset为在整个数据流的偏移
@property (nonatomic, assign, readonly) NSUInteger  length;     //length为当前数据的长度
@property (nonatomic, assign, readonly) BOOL        diskCache;  //YES-硬盘缓冲，NO-内存缓冲，默认NO

- (instancetype)initWithOffset:(NSUInteger)offset;
- (instancetype)initWithOffset:(NSUInteger)offset diskCache:(BOOL)diskCache;

- (void)appendData:(NSData *)data;
- (NSData *)readData;
- (NSData *)readDataAtOffset:(NSUInteger)offset;    //offset为当前data内的偏移
- (NSData *)readDataAtOffset:(NSUInteger)offset length:(NSUInteger)length;  //offset为当前data内的偏移

@end
