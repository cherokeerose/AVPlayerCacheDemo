//
//  CrFileHandle.m
//  Rosalaevigata
//
//  Created by ltr on 2017/7/8.
//  Copyright © 2017年 刘天荣. All rights reserved.
//

#import "CrFileHandle.h"
#import "AVPlayerCache.h"

#define kTmpFileName    @"data.tmp"

@implementation CrFileHandle

+ (BOOL)createTempFile:(NSString *)fileName {
    if (fileName==nil || fileName.length==0) {
        fileName = kTmpFileName;
    }
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *filePath = [[NSString temporaryPath] stringByAppendingPathComponent:fileName];
    if ([manager fileExistsAtPath:filePath]) {
        [manager removeItemAtPath:filePath error:nil];
    }
    return [manager createFileAtPath:filePath contents:nil attributes:nil];
}

+ (NSString *)getEmptyTempFile {
    CFUUIDRef uuidRef =CFUUIDCreate(NULL);
    CFStringRef uuidStringRef =CFUUIDCreateString(NULL, uuidRef);
    
    NSString *uniqueId = (__bridge NSString *)uuidStringRef;
    NSString *fileName = [NSString stringWithFormat:@"%@.tmp", uniqueId];
    
    CFRelease(uuidRef);
    CFRelease(uuidStringRef);
    
    BOOL success = [self createTempFile:fileName];
    if (success) {
        return fileName;
    }
    return nil;
}

+ (BOOL)removeTempFile:(NSString *)fileName {
    if (fileName==nil || fileName.length==0) {
        fileName = kTmpFileName;
    }
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *filePath = [[NSString temporaryPath] stringByAppendingPathComponent:fileName];
    if ([manager fileExistsAtPath:filePath]) {
        return [manager removeItemAtPath:filePath error:nil];
    }
    return YES;
}

+ (void)writeTempFile:(NSString *)fileName data:(NSData *)data {
    if (fileName==nil || fileName.length==0) {
        fileName = kTmpFileName;
    }
    NSString *filePath = [[NSString temporaryPath] stringByAppendingPathComponent:fileName];
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [handle seekToEndOfFile];
    [handle writeData:data];
}

+ (NSData *)readTempFile:(NSString *)fileName {
    if (fileName==nil || fileName.length==0) {
        fileName = kTmpFileName;
    }
    NSString *filePath = [[NSString temporaryPath] stringByAppendingPathComponent:fileName];
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    return [handle readDataToEndOfFile];
}

+ (NSData *)readTempFile:(NSString *)fileName offset:(NSUInteger)offset {
    if (fileName==nil || fileName.length==0) {
        fileName = kTmpFileName;
    }
    NSString *filePath = [[NSString temporaryPath] stringByAppendingPathComponent:fileName];
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    [handle seekToFileOffset:offset];
    return [handle readDataToEndOfFile];
}

+ (NSData *)readTempFile:(NSString *)fileName offset:(NSUInteger)offset length:(NSUInteger)length {
    if (fileName==nil || fileName.length==0) {
        fileName = kTmpFileName;
    }
    NSString *filePath = [[NSString temporaryPath] stringByAppendingPathComponent:fileName];
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    [handle seekToFileOffset:offset];
    return [handle readDataOfLength:length];
}

+ (void)replaceTempFileData:(NSString *)fileName inRange:(NSRange)range withData:(NSData *)data {
    if (fileName==nil || fileName.length==0) {
        fileName = kTmpFileName;
    }
    NSString *filePath = [[NSString temporaryPath] stringByAppendingPathComponent:fileName];
    NSString *tmpFilePath = [[NSString temporaryPath] stringByAppendingPathComponent:[self getEmptyTempFile]];
    
    NSFileHandle *tmpHandle = [NSFileHandle fileHandleForWritingAtPath:tmpFilePath];
    NSFileHandle *readHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    
    NSData *readData = [readHandle readDataOfLength:range.location];
    [tmpHandle writeData:readData];
    [tmpHandle writeData:data];
    
    [readHandle seekToFileOffset:range.location+range.length];
    readData = [readHandle readDataToEndOfFile];
    [tmpHandle writeData:readData];
    
    [self createTempFile:fileName];
    NSFileHandle *tmpReadHandle = [NSFileHandle fileHandleForReadingAtPath:tmpFilePath];
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    
    readData = [tmpReadHandle readDataToEndOfFile];
    [handle writeData:readData];
}

+ (BOOL)copyTempFile:(NSString *)tempFileName toCachesFolder:(NSString *)folder withName:(NSString *)fileName {
    NSString *cacheFolderPath = [[NSString cachesPath] stringByAppendingPathComponent:folder];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:cacheFolderPath]) {
        [manager createDirectoryAtPath:cacheFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *tempPath = [[NSString temporaryPath] stringByAppendingPathComponent:tempFileName];
    NSString *filePath = [cacheFolderPath stringByAppendingPathComponent:fileName];
    return [manager copyItemAtPath:tempPath toPath:filePath error:nil];
}

+ (NSString *)file:(NSString *)fileName existsAtCahcesFolder:(NSString *)folder {
    NSString *filePath = [[[NSString cachesPath] stringByAppendingPathComponent:folder] stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return filePath;
    }
    return nil;
}

+ (BOOL)clearCacheAtFolder:(NSString *)folder {
    NSString *folderPath = [[NSString cachesPath] stringByAppendingPathComponent:folder];
    NSFileManager * manager = [NSFileManager defaultManager];
    return [manager removeItemAtPath:folderPath error:nil];
}

+ (BOOL)clearAllCache {
    NSFileManager * manager = [NSFileManager defaultManager];
    return [manager removeItemAtPath:[NSString cachesPath] error:nil];
}

@end
