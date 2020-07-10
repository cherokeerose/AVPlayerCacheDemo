//
//  CrResourceLoader.h
//  AVPlayerCacheDemo
//
//  Created by tw on 2017/9/28.
//  Copyright © 2017年 刘天荣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface CrResourceLoader : NSObject <AVAssetResourceLoaderDelegate>

@property (nonatomic, copy, readonly) NSString *tmpfile;    //沙盒tmp目录下的缓存文件名
@property (nonatomic, copy  ) NSString  *scheme;            //url的scheme
@property (nonatomic, copy  ) NSString  *cachesFolder;      //沙盒内保存缓存的路径，不设则不缓存
@property (nonatomic, assign) NSInteger maxCacheSize;       //最大内存缓冲，超过则转为硬盘缓冲，默认100M

@end
