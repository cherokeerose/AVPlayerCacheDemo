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

#pragma mark - ---------- temporary ----------
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
    NSString *uniqueId = [NSString uniqueId];
    NSString *fileName = [NSString stringWithFormat:@"%@.tmp", uniqueId];
    
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

+ (void)writeData:(NSData *)data toTempFile:(NSString *)fileName {
    if (fileName==nil || fileName.length==0) {
        fileName = kTmpFileName;
    }
    NSString *filePath = [[NSString temporaryPath] stringByAppendingPathComponent:fileName];
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [handle writeData:data];
}

+ (void)appendData:(NSData *)data atTempFile:(NSString *)fileName {
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

#pragma mark - ---------- utility ----------
+ (BOOL)isExistsFile:(NSString *)file {
    if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
        return YES;
    }
    return NO;
}

+ (NSData *)readFile:(NSString *)file {
    if (file==nil || file.length==0) {
        return nil;
    }
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:file];
    return [handle readDataToEndOfFile];
}

+ (NSArray<NSString *> *)getFilesAtPath:(NSString *)path {
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL directory = NO;
    BOOL exists = [manager fileExistsAtPath:path isDirectory:&directory];
    if (exists && directory) {
        NSArray<NSString *> *files = [manager subpathsAtPath:path];
        NSMutableArray<NSString *> *fileArray = [[NSMutableArray<NSString *> alloc] init];
        for (NSString *file in files) {
            if ([file.lastPathComponent isEqualToString:file]) {
                NSString *filePath = [path stringByAppendingPathComponent:file];
                BOOL directory = NO;
                BOOL exists = [manager fileExistsAtPath:filePath isDirectory:&directory];
                if (exists && !directory) {
                    [fileArray addObject:filePath];
                }
            }
        }
        if (fileArray.count > 0) {
            return [[NSArray<NSString *> alloc] initWithArray:fileArray];
        }
    }
    return nil;
}

+ (BOOL)createFolder:(NSString *)path {
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL directory = NO;
    BOOL exists = [manager fileExistsAtPath:path isDirectory:&directory];
    if (exists && directory) {
        return YES;
    }
    
    NSError *error = nil;
    BOOL sucess = [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    if (sucess==YES && error==nil) {
        return YES;
    }
    return NO;
}

+ (BOOL)writeData:(NSData *)data toFile:(NSString *)file {
    if (file==nil || file.length==0 || data.length==0) {
        return NO;
    }
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = file.stringByDeletingLastPathComponent;
    BOOL isDirectory = NO;
    BOOL exists = [manager fileExistsAtPath:path isDirectory:&isDirectory];
    if (!exists || (exists && !isDirectory)) {
        BOOL success = [CrFileHandle createFolder:path];
        if (success == NO) {
            return NO;
        }
    }
    if ([manager fileExistsAtPath:file]) {
        if (![manager removeItemAtPath:file error:nil]) {
            return NO;
        }
    }
    if (![manager createFileAtPath:file contents:nil attributes:nil]) {
        return NO;
    }
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:file];
    [handle writeData:data];
    return YES;
}

+ (BOOL)appendData:(NSData *)data atFile:(NSString *)file {
    if (file==nil || file.length==0 || data.length==0) {
        return NO;
    }
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = file.stringByDeletingLastPathComponent;
    BOOL isDirectory = NO;
    BOOL exists = [manager fileExistsAtPath:path isDirectory:&isDirectory];
    if (!exists || (exists && !isDirectory)) {
        BOOL success = [CrFileHandle createFolder:path];
        if (success == NO) {
            return NO;
        }
    }
    if (![manager fileExistsAtPath:file]) {
        if (![manager createFileAtPath:file contents:nil attributes:nil]) {
            return NO;
        }
    }
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:file];
    [handle seekToEndOfFile];
    [handle writeData:data];
    return YES;
}

+ (BOOL)copyFile:(NSString *)file toPath:(NSString *)path withName:(NSString *)fileName {
    if (file.length==0 || path.length==0) {
        return nil;
    }
    if (fileName.length == 0) {
        fileName = file.lastPathComponent;
    }
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path]) {
        [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    return [manager copyItemAtPath:file toPath:filePath error:nil];
}

+ (BOOL)removeFile:(NSString *)file {
    if (file==nil || file.length==0) {
        return NO;
    }
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:file]) {
        return [manager removeItemAtPath:file error:nil];
    }
    return YES;
}

+ (BOOL)clearFileAtPath:(NSString *)path {
    if (path==nil || path.length==0) {
        return NO;
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];

    NSArray<NSString *> *files = [manager subpathsAtPath:path];
    for (NSString *file in files) {
        NSString *filePath = [path stringByAppendingPathComponent:file];
        [manager removeItemAtPath:filePath error:nil];
    }
    return YES;
}

@end
