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

@property (nonatomic, strong) NSString                                          *requestUrl;
@property (nonatomic, assign) NSUInteger                                        *receivedLength;

@end

@implementation CrResourceLoader

- (void)dealloc {
    if (self.resourceDownloader != nil) {
        [self.resourceDownloader cancel];
        
    }
}

#pragma mark - AVAssetResourceLoaderDelegate
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    [self addLoadingRequest:loadingRequest];
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    [self removeLoadingRequest:loadingRequest];
}

#pragma mark - add request
- (void)addLoadingRequest:(AVAssetResourceLoadingRequest *)request {
    [self.requestList addObject:request];
    @synchronized (self) {
        NSInteger requestedOffset = request.dataRequest.requestedOffset;
        NSInteger requestedLength = request.dataRequest.requestedLength;
        NSInteger requestingOffset = self.resourceDownloader.requestOffset;
        NSInteger requestingLength = self.resourceDownloader.requestLength;
        BOOL downloaded = [self.receiveData allDataOffset:requestedOffset length:requestedLength];  //是否已经下载
        BOOL requested = (requestedOffset >= requestingOffset) && ((requestedOffset+requestedLength) <= (requestingOffset+requestingLength));   //是否正在下载
        
        if (downloaded || requested) {
            [self processRequestList];
        } else {
            [self newTaskWithLoadingRequest:request];
        }
    }
}

- (void)newTaskWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    if (self.requestUrl && ![self.requestUrl isEqualToString:loadingRequest.request.URL.absoluteString]) {  //新文件下载
        self.receiveData = nil;
        self.receivedLength = 0;
        self.requestUrl = loadingRequest.request.URL.absoluteString;
    }
    if (self.resourceDownloader != nil) {
        [self.resourceDownloader cancel];
    }
    NSUInteger offset = loadingRequest.dataRequest.requestedOffset;
    NSUInteger length = loadingRequest.dataRequest.requestedLength;
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:loadingRequest.request.URL resolvingAgainstBaseURL:NO];
    components.scheme = self.scheme;
    
    self.resourceDownloader = [[CrResourceDownloader alloc] initWithUrl:components.URL offset:offset length:length delegate:self];
    [self.resourceDownloader start];
}

- (void)removeLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    [self.requestList removeObject:loadingRequest];
}

#pragma mark - respond the request data
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
