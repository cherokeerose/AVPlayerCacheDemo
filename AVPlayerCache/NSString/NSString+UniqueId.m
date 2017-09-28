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
    CFUUIDRef uuidRef =CFUUIDCreate(NULL);
    CFStringRef uuidStringRef =CFUUIDCreateString(NULL, uuidRef);
    
    NSString *uniqueId = (__bridge NSString *)uuidStringRef;
    NSString *uniqueString= [NSString stringWithFormat:@"%@", uniqueId];
    
    CFRelease(uuidRef);
    CFRelease(uuidStringRef);
    
    return uniqueString;
}

@end
