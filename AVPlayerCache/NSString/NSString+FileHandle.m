//
//  NSString+FileHandle.m
//  Rosalaevigata
//
//  Created by ltr on 2017/7/8.
//  Copyright © 2017年 刘天荣. All rights reserved.
//

#import "NSString+FileHandle.h"

@implementation NSString (FileHandle)

+ (NSString *)documentPath {
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = pathArray.lastObject;
    return path;
}

+ (NSString *)libraryPath {
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *path = pathArray.lastObject;
    return path;
}

+ (NSString *)cachesPath {
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = pathArray.lastObject;
    return path;
}

+ (NSString *)temporaryPath {
    NSString *path = NSTemporaryDirectory();
    return path;
}

+ (NSString *)fileNameFromURL:(NSString *)url {
    return [[url componentsSeparatedByString:@"/"] lastObject];
}

+ (BOOL)httpURL:(NSString *)url {
    if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) {
        return YES;
    }
    return NO;
}

@end
