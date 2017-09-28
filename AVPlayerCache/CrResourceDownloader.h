//
//  CrResourceDownloader.h
//  AVPlayerCacheDemo
//
//  Created by tw on 2017/9/28.
//  Copyright © 2017年 刘天荣. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CrResourceDownloaderDelegate <NSObject>

@required
- (void)requestTaskDidReceiveResponse:(NSURLResponse *)response;
- (void)requestTaskDidReceiveData:(NSData *)data offset:(NSUInteger)offset;
- (void)requestTaskDidComplete:(NSError *)error;

@end

@interface CrResourceDownloader : NSObject

@property (nonatomic, assign, readonly) NSUInteger requestOffset;
@property (nonatomic, assign, readonly) NSUInteger requestLength;
@property (nonatomic, assign, readonly) NSUInteger receivedLength;

@property (nonatomic, weak) id<CrResourceDownloaderDelegate> delegate;

- (instancetype)initWithUrl:(NSURL *)url delegate:(id<CrResourceDownloaderDelegate>)delegate;
- (instancetype)initWithUrl:(NSURL *)url offset:(NSUInteger)offset length:(NSUInteger)length delegate:(id<CrResourceDownloaderDelegate>)delegate;
- (void)start;      //开始新下载任务
- (void)resume;     //继续原有下载任务
- (void)suspend;    //暂停下载任务
- (void)cancel;     //取消下载任务

@end
