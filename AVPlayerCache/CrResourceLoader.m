//
//  CrResourceLoader.m
//  AVPlayerCacheDemo
//
//  Created by tw on 2017/9/28.
//  Copyright © 2017年 刘天荣. All rights reserved.
//

#import "CrResourceLoader.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "AVPlayerCache.h"

@interface CrResourceLoader ()<CrResourceDownloaderDelegate>

@property (nonatomic, strong) NSMutableArray<AVAssetResourceLoadingRequest *>   *requestList;
@property (nonatomic, strong) CrResourceDownloader                              *resourceDownloader;
@property (nonatomic, strong) CrResourceData                                    *receiveData;
@property (nonatomic, copy  ) NSString                                          *tmpfile;

@property (nonatomic, strong) NSString                                          *requestUrl;
@property (nonatomic, assign) NSUInteger                                        *receivedLength;

@end

@implementation CrResourceLoader

- (instancetype)init {
    self = [super init];
    if (self) {
        self.maxCacheSize = 1024*1024*100;
    }
    return self;
}

- (void)dealloc {
    if (self.resourceDownloader != nil) {
        [self.resourceDownloader cancel];
    }
}

#pragma mark - AVAssetResourceLoaderDelegate
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    [self addLoadingRequest:loadingRequest];        //将loadingRequest添加到请求队列
    return YES;
}
                
- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    [self removeLoadingRequest:loadingRequest];     //播放器取消了loadingRequest，从队列移除
}

#pragma mark - add request
//添加请求
- (void)addLoadingRequest:(AVAssetResourceLoadingRequest *)request {
    [self.requestList addObject:request];
    @synchronized (self) {
        //新下载则先清空原有下载缓存
        NSURLComponents *components = [[NSURLComponents alloc] initWithURL:request.request.URL resolvingAgainstBaseURL:NO];
        components.scheme = self.scheme;
        NSString *url = components.URL.absoluteString;
        if (![self.requestUrl isEqualToString:url]) {  //新资源下载，清除已下载数据
            [self.resourceDownloader cancel];
            self.resourceDownloader = nil;
            self.tmpfile = nil;
            self.receiveData = nil;
            self.receivedLength = 0;
            self.requestUrl = url;
        }
        
        //判断已下载情况
        NSInteger requestedOffset = request.dataRequest.requestedOffset;
        NSInteger requestedLength = request.dataRequest.requestedLength;
        NSInteger requestingOffset = self.resourceDownloader.requestOffset;
        NSInteger requestingLength = self.resourceDownloader.requestLength;
        BOOL downloaded = [self.receiveData allDataOffset:requestedOffset length:requestedLength];  //数据是否已经完全下载
        BOOL requested = (requestedOffset >= requestingOffset) && ((requestedOffset+requestedLength) <= (requestingOffset+requestingLength));   //数据是否全部正在下载
        
        if (downloaded || requested) {
            [self processRequestList];                      //数据已经全部下载或正在下载，直接回填数据
        } else {
            [self newTaskWithLoadingRequest:request];       //没有数据或者数据不完整，需要向网络下载
        }
    }
}

//生成一个新网络下载请求
- (void)newTaskWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    //取消正在下载请求
    if (self.resourceDownloader != nil) {
        [self.resourceDownloader cancel];
        self.resourceDownloader = nil;
    }
    NSUInteger offset = loadingRequest.dataRequest.requestedOffset;
    NSUInteger length = loadingRequest.dataRequest.requestedLength;
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:loadingRequest.request.URL resolvingAgainstBaseURL:NO];
    components.scheme = self.scheme;
    
    //发起网络数据下载请求
    self.resourceDownloader = [[CrResourceDownloader alloc] initWithUrl:components.URL offset:offset length:length delegate:self];
    [self.resourceDownloader start];
}

- (void)removeLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    [self.requestList removeObject:loadingRequest];
}

#pragma mark - respond the request data
//判断请求是否已经回填完成，完成的从队列移除，未完成的回填。
- (void)processRequestList {
    NSMutableArray *finishRequestList = [NSMutableArray array];
    for (int i=0; i<self.requestList.count; i++) {
        AVAssetResourceLoadingRequest *loadingRequest = self.requestList[i];
        if (!loadingRequest.isFinished) {
            [self responseLoadData:loadingRequest];
        } else {
            [finishRequestList addObject:loadingRequest];
        }
    }
    [self.requestList removeObjectsInArray:finishRequestList];
}

- (void)responseLoadData:(AVAssetResourceLoadingRequest *)request {
    //填充信息
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(self.receiveData.mineType), NULL);
    request.contentInformationRequest.contentType = CFBridgingRelease(contentType);
    request.contentInformationRequest.byteRangeAccessSupported = YES;
    request.contentInformationRequest.contentLength = self.receiveData.fileLength;
    
    //填充数据
    NSUInteger needLength = request.dataRequest.requestedLength - (request.dataRequest.currentOffset - request.dataRequest.requestedOffset);
    if ([self.receiveData hasDataOffset:request.dataRequest.currentOffset length:needLength]) {
        NSData *data = [self.receiveData getDataOffset:request.dataRequest.currentOffset length:needLength];
        [request.dataRequest respondWithData:data];
        if ((request.dataRequest.currentOffset-request.dataRequest.requestedOffset) == request.dataRequest.requestedLength) {
            [request finishLoading];
        }
    }
}

#pragma mark - ResourceDownloaderDelegate
- (void)requestTaskDidReceiveResponse:(NSURLResponse *)response {
    //CrDebugLog(@"requestTaskDidReceiveResponse");
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSString *contentRange = [httpResponse.allHeaderFields objectForKey:@"Content-Range"];
    NSString *lengthString = [contentRange componentsSeparatedByString:@"/"].lastObject;
    NSUInteger fileLength = lengthString.integerValue>0 ? lengthString.integerValue : response.expectedContentLength;
    
    self.receiveData.mineType = response.MIMEType;
    self.receiveData.fileLength = fileLength;
    self.receiveData.fileName = [NSString fileNameFromURL:response.URL.absoluteString];
    if (fileLength > 1024*1024*100) {
        self.receiveData.diskCache = YES;
    }
}

- (void)requestTaskDidReceiveData:(NSData *)data offset:(NSUInteger)offset {
    [self.receiveData appendData:data atOffset:offset];
    [self processRequestList];
    //CrDebugLog(@"received %ld byte data.", data.length);
}

- (void)requestTaskDidComplete:(NSError *)error {
    //CrDebugLog(@"requestTaskDidComplete");
    if ([self.receiveData completeCached]) {
        self.tmpfile = self.receiveData.tmpfile;
        if (self.cachesFolder.length>0) {
            [CrFileHandle copyTempFile:self.receiveData.tmpfile toCachesFolder:self.cachesFolder withName:self.receiveData.fileName];
        }
    }
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    }
}

#pragma mark - getter
- (NSMutableArray<AVAssetResourceLoadingRequest *> *)requestList {
    if (_requestList == nil) {
        _requestList = [[NSMutableArray alloc] init];
    }
    return _requestList;
}

- (CrResourceData *)receiveData {
    if (_receiveData == nil) {
        _receiveData = [[CrResourceData alloc] init];
    }
    return _receiveData;
}

@end
