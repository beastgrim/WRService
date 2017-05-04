//
//  WRService.m
//  WRService
//
//  Created by FLS on 04/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#import "WRService.h"
#import "WROperation_Private.h"

@interface WRService() <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>



@end

@implementation WRService {
    NSOperationQueue * _highQueue;
    NSOperationQueue * _defaultQueue;
    NSURLSession * _urlSession;
    dispatch_queue_t _queue;
    NSMutableDictionary <NSNumber*, WROperation*> * _operations;
}

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static WRService * service = nil;
    dispatch_once(&onceToken, ^{
        service = [WRService new];
    });
    return service;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _queue = dispatch_queue_create("wr_service_queue", nil);
        _operations = [NSMutableDictionary new];
        
        _highQueue = [NSOperationQueue new];
        _highQueue.name = @"High";
        _highQueue.maxConcurrentOperationCount = 3;
        _highQueue.qualityOfService = NSQualityOfServiceUserInteractive;
        _defaultQueue = [NSOperationQueue new];
        _defaultQueue.name = @"Default";
        _defaultQueue.maxConcurrentOperationCount = 10;
        _defaultQueue.qualityOfService = NSQualityOfServiceBackground;
        
        NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
        _urlSession = [NSURLSession sessionWithConfiguration:conf delegate:self delegateQueue:nil];
    }
    return self;
}


#pragma mark - Public

- (void)execute:(WROperation *)op onSuccess:(WRSuccessCallback)success onFail:(WRFailCallback)fail {
    NSURLSessionDataTask *t = [_urlSession dataTaskWithURL:op.url];
    
    [op setSessionTask:t];
    [self _registerTask:op];
    op.failCallback = fail;
    op.successCallback = success;
    
    [t resume];
}


#pragma mark - Private

- (void) _registerTask:(WROperation*)op {
    dispatch_sync(_queue, ^{
        [_operations setObject:op forKey:@([op taskIdentifier])];
    });
}

- (void) _unregisterTask:(WROperation*)op {
    dispatch_sync(_queue, ^{
        [_operations removeObjectForKey:@([op taskIdentifier])];
    });
}

- (WROperation*) operationOfTask:(NSURLSessionTask*)task {
    __block WROperation *op = nil;
    dispatch_sync(_queue, ^{
        op = [_operations objectForKey:@(task.taskIdentifier)];
    });
    return op;
}


#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error {
    NSLog(@"didBecomeInvalidWithError: %@", error);
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {

    NSLog(@"didReceiveChallenge: %@", challenge);

}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    NSLog(@"URLSessionDidFinishEventsForBackgroundURLSession: %@", session);
}


#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    
    WROperation *op = [self operationOfTask:task];
    [op didCompleteWithError:error];

    [self _unregisterTask:op];
}


#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    WROperation *op = [self operationOfTask:dataTask];
    [op didReceiveData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    completionHandler(NSURLSessionResponseAllow);
    
    long long size = [response expectedContentLength];
    WROperation *op = [self operationOfTask:dataTask];
    [op setContentLength:size];
}

@end
