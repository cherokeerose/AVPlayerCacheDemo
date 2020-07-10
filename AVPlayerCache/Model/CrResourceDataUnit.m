//
//  CrResourceDataUnit.m
//  AVPlayerCacheDemo
//
//  Created by tw on 2017/9/28.
//  Copyright © 2017年 刘天荣. All rights reserved.
//

#import "CrResourceDataUnit.h"
#import "AVPlayerCache.h"

@interface CrResourceDataUnit()

@property (nonatomic, assign) NSUInteger    offset;
@property (nonatomic, assign) NSUInteger    length;
@property (nonatomic, assign) BOOL          diskCache;

@property (nonatomic, strong) NSMutableData *data;      //内存缓冲数据
@property (nonatomic, copy  ) NSString      *tmpfile;   //在tmp目录下保存的缓存文件名，硬盘缓冲
@property (nonatomic, strong) NSLock        *lock;

@end

@implementation CrResourceDataUnit

- (instancetype)initWithOffset:(NSUInteger)offset {
    self = [super init];
    if (self) {
        self.offset = offset;
        self.diskCache = NO;
        self.data = [[NSMutableData alloc] init];
    }
    return self;
}

- (instancetype)initWithOffset:(NSUInteger)offset diskCache:(BOOL)diskCache {
    self = [super init];
    if (self) {
        self.offset = offset;
        self.diskCache = diskCache;
        if (diskCache) {
            [CrFileHandle createTempFile:self.tmpfile];
        } else {
            self.data = [[NSMutableData alloc] init];
        }
    }
    return self;
}

- (void)dealloc {
    [CrFileHandle removeTempFile:self.tmpfile];
}

#pragma mark - op
- (void)appendData:(NSData *)data {
    if (self.diskCache) {
        [self diskAppendData:data];
    } else {
        [self memoryAppendData:data];
    }
}

- (NSData *)readData {
    if (self.diskCache) {
        return [self diskReadData];
    } else {
        return [self memoryReadData];
    }
}

//offset为当前data内的偏移
- (NSData *)readDataAtOffset:(NSUInteger)offset {
    if (self.diskCache) {
        return [self diskReadDataAtOffset:offset];
    } else {
        return [self memoryReadDataAtOffset:offset];
    }
}

//offset为当前data内的偏移
- (NSData *)readDataAtOffset:(NSUInteger)offset length:(NSUInteger)length {
    if (self.diskCache) {
        return [self diskReadDataAtOffset:offset length:length];
    } else {
        return [self memoryReadDataAtOffset:offset length:length];
    }
}


#pragma mark memory
- (void)memoryAppendData:(NSData *)data {
    [self.lock lock];
    self.length = self.length + data.length;
    [self.data appendData:data];
    [self.lock unlock];
}

- (NSData *)memoryReadData {
    [self.lock lock];
    NSData *data = [self.data copy];
    [self.lock unlock];
    return data;
}

//offset为当前data内的偏移
- (NSData *)memoryReadDataAtOffset:(NSUInteger)offset {
    if (offset > self.length) {
        return nil;
    }
    [self.lock lock];
    NSData *data = [self.data subdataWithRange:NSMakeRange(offset, self.length - offset)];
    [self.lock unlock];
    return data;
}

//offset为当前data内的偏移
- (NSData *)memoryReadDataAtOffset:(NSUInteger)offset length:(NSUInteger)length {
    if (offset > self.length || length == 0) {
        return nil;
    }
    [self.lock lock];
    NSInteger canRead = self.length - offset;
    NSInteger read = MIN(length, canRead);
    NSData *data = [self.data subdataWithRange:NSMakeRange(offset, read)];
    [self.lock unlock];
    return data;
}

#pragma mark disk
- (void)diskAppendData:(NSData *)data {
    [self.lock lock];
    self.length = self.length + data.length;
    [CrFileHandle appendData:data atTempFile:self.tmpfile];
    [self.lock unlock];
}

- (NSData *)diskReadData {
    [self.lock lock];
    NSData *data = [CrFileHandle readTempFile:self.tmpfile];
    [self.lock unlock];
    return data;
}

//offset为当前data内的偏移
- (NSData *)diskReadDataAtOffset:(NSUInteger)offset {
    if (offset > self.length) {
        return nil;
    }
    [self.lock lock];
    NSData *data = [CrFileHandle readTempFile:self.tmpfile offset:offset];
    [self.lock unlock];
    return data;
}

//offset为当前data内的偏移
- (NSData *)diskReadDataAtOffset:(NSUInteger)offset length:(NSUInteger)length {
    if (offset > self.length || length == 0) {
        return nil;
    }
    [self.lock lock];
    NSData *data = [CrFileHandle readTempFile:self.tmpfile offset:offset length:length];
    [self.lock unlock];
    return data;
}

#pragma mark - getter
- (NSString *)tmpfile {
    if (_tmpfile == nil) {
        NSString *uniqueId = [NSString uniqueId];
        _tmpfile = [NSString stringWithFormat:@"%@.tmp", uniqueId];
    }
    return _tmpfile;
}

- (NSLock *)lock {
    if (_lock == nil) {
        _lock = [[NSLock alloc] init];
    }
    return _lock;
}

@end
