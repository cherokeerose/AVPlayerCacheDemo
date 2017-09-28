//
//  CrResourceDownloader.m
//  AVPlayerCacheDemo
//
//  Created by tw on 2017/9/28.
//  Copyright © 2017年 刘天荣. All rights reserved.
//

#import "CrResourceDownloader.h"

@interface CrResourceDownloader ()<NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession          *session;       //会话对象
@property (nonatomic, strong) NSURLSessionDataTask  *task;          //任务

@property (nonatomic, strong) NSURL                 *url;
@property (nonatomic, assign) NSUInteger            requestOffset;
@property (nonatomic, assign) NSUInteger            requestLength;
@property (nonatomic, assign) NSUInteger            receivedLength;

@end

@implementation CrResourceDownloader

- (instancetype)initWithUrl:(NSURL *)url delegate:(id<CrResourceDownloaderDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.url = url;
    }
    return self;
}

- (instancetype)initWithUrl:(NSURL *)url offset:(NSUInteger)offset length:(NSUInteger)length delegate:(id<CrResourceDownloaderDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.requestOffset = offset;
        self.requestLength = length;
        self.url = url;
    }
    return self;
}

- (void)dealloc {
    [self cancel];
}

#pragma mark - operation
- (void)start {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    if (self.requestLength>0) {
        [request addValue:[NSString stringWithFormat:@"bytes=%ld-%ld", self.requestOffset, self.requestOffset+self.requestLength-1] forHTTPHeaderField:@"Range"];
    }
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue currentQueue]];
    self.task = [self.session dataTaskWithRequest:request];
    [self.task resume];
}

- (void)resume {
    [self.task resume];
}

- (void)suspend {
    [self.task suspend];
}

- (void)cancel {
    [self.task cancel];
    [self.session invalidateAndCancel];
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition)) completionHandler {
    completionHandler(NSURLSessionResponseAllow);
    //NSLog(@"didReceiveResponse");
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidReceiveResponse:)]) {
        [self.delegate requestTaskDidReceiveResponse:response];
    }
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    //NSLog(@"didReceiveData");
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidReceiveData:offset:)]) {
        [self.delegate requestTaskDidReceiveData:data offset:self.requestOffset+self.receivedLength];
    }
    self.receivedLength = self.receivedLength + data.length;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    //NSLog(@"didComplete");
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidComplete:)]) {
        [self.delegate requestTaskDidComplete:error];
    }
}

@end
