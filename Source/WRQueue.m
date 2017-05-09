//
//  WRQueue.m
//  WRService
//
//  Created by FLS on 05/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#import "WRQueue.h"
#import "WROperation_Private.h"

NSErrorDomain const WRQueueErrorDomain = @"WRQueueErrorDomain";


@interface WRQueue() <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@end

@implementation WRQueue {
    NSURLSession *_session;
    dispatch_queue_t _queue;
    NSMutableDictionary <NSNumber*, WROperation*> * _operations;
}


- (instancetype)initWithConfiguration:(NSURLSessionConfiguration *)conf queue:(dispatch_queue_t)queue
{
    self = [super init];
    if (self) {
        _session = [NSURLSession sessionWithConfiguration:conf delegate:self delegateQueue:nil];
        _queue = queue;
        _operations = [NSMutableDictionary new];
        _defaultTaskPriority = 0.5;
    }
    return self;
}


#pragma mark - Getters

- (NSInteger)countExclusiveTasks {
    __block NSUInteger count = 0;
    dispatch_sync(_queue, ^{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.priority == %d AND self.isFinished == NO", WROperationPriorityExclusive];
        NSArray *arr = [[_operations allValues] filteredArrayUsingPredicate:predicate];
        count = [arr count];
    });
    return count;
}


#pragma mark - Public

- (void)execute:(WROperation *)op onSuccess:(WRSuccessCallback)success onFail:(WRFailCallback)fail {

    NSURLSessionDataTask *t = [_session dataTaskWithRequest:op.request];
    t.priority = _defaultTaskPriority;
    
    [op setSessionTask:t];
    [self _registerTask:op];
    
    op.failCallback = fail;
    op.successCallback = success;
    
    [t resume];
}

- (void)execute:(WROperation *)op {
    if (op.taskIdentifier > 0) {
        NSError *err = [NSError errorWithDomain:WRQueueErrorDomain code:WRQueueErrorTaskAlreadyPerforming userInfo:nil];
        NSLog(@"ERROR execute operation: %@", err);
    } else {
        NSURLSessionDataTask *t = [_session dataTaskWithRequest:op.request];
        t.priority = _defaultTaskPriority;
        
        [op setSessionTask:t];
        [self _registerTask:op];
        
        [t resume];
    }
}

- (void)cancelTasksWithDelegate:(id)delegate {
    dispatch_async(_queue, ^{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.cancelDelegate == %@", delegate];
        NSArray *arr = [[_operations allValues] filteredArrayUsingPredicate:predicate];
        for (WROperation *op in arr) {
            [op cancel];
        }
    });
}

- (void)suspendAllTasks {
    
    [_session getAllTasksWithCompletionHandler:^(NSArray<__kindof NSURLSessionTask *> * _Nonnull tasks) {
       
        dispatch_async(_queue, ^{
            for (NSURLSessionTask *t in tasks) {
                WROperation *op = [_operations objectForKey:@(t.taskIdentifier)];
                if (op && op.priority != WROperationPriorityExclusive) {
                    [t suspend];
                }
            }
        });
    }];
}

- (void)resumeAllTasks {
    
    [_session getAllTasksWithCompletionHandler:^(NSArray<__kindof NSURLSessionTask *> * _Nonnull tasks) {
        
        dispatch_async(_queue, ^{
            for (NSURLSessionTask *t in tasks) {
                WROperation *op = [_operations objectForKey:@(t.taskIdentifier)];
                if (op && op.priority != WROperationPriorityExclusive) {
                    [t resume];
                }
            }
        });
    }];
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
    
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
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
    dispatch_async(_queue, ^{
        [op didReceiveData:data];
    });
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    completionHandler(NSURLSessionResponseAllow);
    
    long long size = [response expectedContentLength];
    WROperation *op = [self operationOfTask:dataTask];
    dispatch_async(_queue, ^{
        [op setContentLength:size];
    });
}

@end
