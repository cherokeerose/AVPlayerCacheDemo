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
@property (nonatomic, copy  ) NSString      *tmpfile; //在tmp目录下保存的缓存文件名

@property (nonatomic, strong) NSLock        *lock;

@end

@implementation CrResourceDataUnit

- (instancetype)initWithOffset:(NSUInteger)offset {
    self = [super init];
    if (self) {
        self.offset = offset;
        [CrFileHandle createTempFile:self.tmpfile];
    }
    return self;
}

- (void)dealloc {
    //[CrFileHandle removeTempFile:self.tmpfile];
}

#pragma mark - op
- (void)appendData:(NSData *)data {
    [self.lock lock];
    self.length = self.length + data.length;
    [CrFileHandle writeTempFile:self.tmpfile data:data];
    [self.lock unlock];
}

- (NSData *)readData {
    [self.lock lock];
    NSData *data = [CrFileHandle readTempFile:self.tmpfile];
    [self.lock unlock];
    return data;
}

//offset为当前data内的偏移
- (NSData *)readDataAtOffset:(NSUInteger)offset {
    if (offset > self.length) {
        return nil;
    }
    [self.lock lock];
    NSData *data = [CrFileHandle readTempFile:self.tmpfile offset:offset];
    [self.lock unlock];
    return data;
}

//offset为当前data内的偏移
- (NSData *)readDataAtOffset:(NSUInteger)offset length:(NSUInteger)length {
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
