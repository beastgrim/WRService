//
//  WRService.m
//  WRService
//
//  Created by FLS on 04/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#import "WRService.h"
#import "WRQueue.h"
#import "WROperation_Private.h"

@interface WRService()



@end


@implementation WRService {
    WRQueue * _backgroundQueue;
    WRQueue * _defaultQueue;
    dispatch_queue_t _queue;
    NSUInteger _countExclusiveTasks;
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
        
        /*
         _highQueue = [NSOperationQueue new];
         _highQueue.name = @"High";
         _highQueue.maxConcurrentOperationCount = 3;
         _highQueue.qualityOfService = NSQualityOfServiceUserInteractive;
         _defaultQueue = [NSOperationQueue new];
         _defaultQueue.name = @"Default";
         _defaultQueue.maxConcurrentOperationCount = 10;
         _defaultQueue.qualityOfService = NSQualityOfServiceBackground;
         */
        
        NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
        _defaultQueue = [[WRQueue alloc] initWithConfiguration:conf queue:_queue];
        _defaultQueue.defaultTaskPriority = 0.6;
        conf.networkServiceType = NSURLNetworkServiceTypeBackground;
        _backgroundQueue = [[WRQueue alloc] initWithConfiguration:conf queue:_queue];
        _backgroundQueue.defaultTaskPriority = 0.3;
    }
    return self;
}


#pragma mark - Public

+ (void)execute:(WROperation *)op onSuccess:(WRSuccessCallback)success onFail:(WRFailCallback)fail {
    [[self shared] execute:op onSuccess:success onFail:fail];
}

+ (void)execute:(WROperation *)op withDelegate:(id<WROperationDelegate>)delegate {
    [[self shared] execute:op withDelegate:delegate];
}


- (void)execute:(WROperation *)op onSuccess:(WRSuccessCallback)success onFail:(WRFailCallback)fail {
    
    if (op == nil) return;
    
    op.successCallback = success;
    op.failCallback = fail;
    
    [self _executeOperation:op];
}

- (void)execute:(WROperation *)op withDelegate:(id<WROperationDelegate>)delegate {
    
    if (op == nil) return;
    
    op.delegate = delegate;
    
    [self _executeOperation:op];
}

- (void)cancelTasksWithDelegate:(id)delegate {
    [_defaultQueue cancelTasksWithDelegate:delegate];
    [_backgroundQueue cancelTasksWithDelegate:delegate];
}

- (void)cancelAllTasks {
    
}


#pragma mark - Private

- (void) _executeOperation:(WROperation *)op {
    
    switch (op.priority) {
        case WROperationPriorityDefault:
            [_defaultQueue execute:op];
            
            break;
            
        case WROperationPriorityBackground:
            [_backgroundQueue execute:op];
            
            break;
            
        case WROperationPriorityExclusive:
            
            if (_countExclusiveTasks == 0) {
                [_defaultQueue suspendAllTasks];
                [_backgroundQueue suspendAllTasks];
            }
            
            _countExclusiveTasks++;
            [_defaultQueue execute:op];
            
            [op addObserver:self forKeyPath:@"finished" options:NSKeyValueObservingOptionNew context:(__bridge void * _Nullable)(self)];
            break;
    }
}

- (BOOL)countExclusiveTasks {
    NSInteger count = [_defaultQueue countExclusiveTasks];
    
    return count;
}

- (void) resumeAllTasks {
    [_defaultQueue resumeAllTasks];
    [_backgroundQueue resumeAllTasks];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void * _Nullable)(self)) {
        NSLog(@"Exclusive task KVO");
        [object removeObserver:self forKeyPath:@"finished" context:(__bridge void * _Nullable)(self)];
        _countExclusiveTasks--;
        
        if (_countExclusiveTasks == 0) {
            [self resumeAllTasks];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
