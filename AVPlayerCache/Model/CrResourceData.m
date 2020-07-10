//
//  CrResourceData.m
//  AVPlayerCacheDemo
//
//  Created by tw on 2017/9/28.
//  Copyright © 2017年 刘天荣. All rights reserved.
//

#import "CrResourceData.h"
#import "AVPlayerCache.h"

@interface CrResourceData()

@property (nonatomic, copy  ) NSString                              *tmpfile;
@property (nonatomic, strong) NSMutableArray<CrResourceDataUnit *>  *dataRangeArray;

@end

@implementation CrResourceData

- (void)dealloc {
    [CrFileHandle removeTempFile:self.tmpfile];
}

#pragma mark - 数据读写
- (void)appendData:(NSData *)data atOffset:(NSUInteger)offset {
    for (int i=0; i<self.dataRangeArray.count; i++) {
        CrResourceDataUnit *resource = self.dataRangeArray[i];
        if ((resource.offset+resource.length) == offset) {
            [resource appendData:data];
            return;
        }
    }
    CrResourceDataUnit *resource = [[CrResourceDataUnit alloc] initWithOffset:offset diskCache:self.diskCache];
    [resource appendData:data];
    [self.dataRangeArray addObject:resource];
    [self sortDataArray];
    [self mergeDataArray];
}

- (NSData *)getDataOffset:(NSUInteger)offset length:(NSUInteger)length {
    for (int i=0; i<self.dataRangeArray.count; i++) {
        CrResourceDataUnit *resource = self.dataRangeArray[i];
        if (offset >= resource.offset && (offset < (resource.offset+resource.length))) {          //有数据
            NSUInteger readOffset = offset-resource.offset;
            NSUInteger canReadLength = resource.length - readOffset;
            NSUInteger readLength = MIN(canReadLength, length);
            NSData *data = [resource readDataAtOffset:readOffset length:readLength];
            return data;
        }
    }
    //无数据
    return nil;
}

- (NSData *)getAllData {
    if (self.dataRangeArray.count == 0) {
        return nil;
    }
    NSMutableData *data = [[NSMutableData alloc] init];
    for (int i=0; i<self.dataRangeArray.count; i++) {
        CrResourceDataUnit *resource = self.dataRangeArray[i];
        [data appendData:[resource readData]];
    }
    return data;
}

- (BOOL)allDataOffset:(NSUInteger)offset length:(NSUInteger)length {
    for (int i=0; i<self.dataRangeArray.count; i++) {
        CrResourceDataUnit *resource = self.dataRangeArray[i];
        if (offset >= resource.offset && ((offset+length) <= (resource.offset+resource.length))) {          //有连续数据
            return YES;
        }
    }
    return NO;
}

- (BOOL)hasDataOffset:(NSUInteger)offset length:(NSUInteger)length {
    for (int i=0; i<self.dataRangeArray.count; i++) {
        CrResourceDataUnit *resource = self.dataRangeArray[i];
        if (offset >= resource.offset && (offset < (resource.offset+resource.length))) {          //有数据
            return YES;
        }
    }
    return NO;
}

//判断是否缓冲完成，以单一数据且长度恰好等于文件长度判断
- (BOOL)completeCached {
    if (self.dataRangeArray.count == 1 && [self getCurrentLength] == self.fileLength) {
        //CrDebugLog("Cache Success");
        CrResourceDataUnit *resource = self.dataRangeArray.firstObject;
        
        //将数据拷贝一份
        NSString *uinqueId = [NSString uniqueId];
        self.tmpfile = [NSString stringWithFormat:@"%@.tmp", uinqueId];
        [CrFileHandle createTempFile:self.tmpfile];
        [CrFileHandle writeData:[resource readData] toTempFile:self.tmpfile];
        return YES;
    } else {
        return NO;
    }
}

- (NSUInteger)getCurrentLength {
    NSUInteger datalength = 0;
    for (CrResourceDataUnit *resource in self.dataRangeArray) {
        datalength = datalength + resource.length;
    }
    return datalength;
}

#pragma mark - 排序合并已有数据
//按offset排序，确保所有数据可以按序合并
- (void)sortDataArray {
    NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:@"offset" ascending:YES];
    [self.dataRangeArray sortUsingDescriptors:@[sortDes]];
}

//将连续数据合并成单一数据
- (void)mergeDataArray {
    NSMutableArray<CrResourceDataUnit *> *dataArray = [[NSMutableArray<CrResourceDataUnit *> alloc] init];
    for (int i=0; i<self.dataRangeArray.count; i++) {
        CrResourceDataUnit *lastresource = dataArray.lastObject;
        CrResourceDataUnit *resourcei = self.dataRangeArray[i];
        if (lastresource && (lastresource.offset+lastresource.length)>=resourcei.offset) {          //有连续数据
            NSUInteger readOffset = (lastresource.offset+lastresource.length) - resourcei.offset;
            NSData *data = [resourcei readDataAtOffset:readOffset];
            [lastresource appendData:data];
        } else {    //无连续数据
            [dataArray addObject:resourcei];
        }
    }
    [self.dataRangeArray removeAllObjects];
    [self.dataRangeArray addObjectsFromArray:dataArray];
}

#pragma mark - getter
- (NSMutableArray<CrResourceDataUnit *> *)dataRangeArray {
    if (_dataRangeArray == nil) {
        _dataRangeArray = [[NSMutableArray<CrResourceDataUnit *> alloc] init];
    }
    return _dataRangeArray;
}

@end
