//
//  NSString+UniqueId.m
//  Rosalaevigata
//
//  Created by ltr on 2017/7/12.
//  Copyright © 2017年 刘天荣. All rights reserved.
//

#import "NSString+UniqueId.h"

@implementation NSString (UniqueId)

+ (NSString *)uniqueId {
#if TARGET_IPHONE_SIMULATOR  //模拟器
    NSDate *date = [NSDate new];
    NSTimeInterval timeIntrval = date.timeIntervalSince1970;
    NSString *string = [NSString stringWithFormat:@"%lf", timeIntrval];
    return string;
#elif TARGET_OS_IPHONE      //真机
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    
    NSString *uniqueId = (__bridge NSString *)uuidStringRef;
    NSString *uniqueString = [NSString stringWithFormat:@"%@", uniqueId];
    
    CFRelease(uuidRef);
    CFRelease(uuidStringRef);
    
    return uniqueString;
#endif
}

@end
