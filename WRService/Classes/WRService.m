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

@interface WRService() <WRQueueDelegate>


@property (nonatomic, copy) void (^authChallangeCallback)(WROperationPriority, NSURLAuthenticationChallenge * _Nonnull, void (^ _Nonnull)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable));


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

+ (void)printInformation {
    WRService *service = [WRService shared];
    [service _printTasks];
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
//        [conf setRequestCachePolicy:NSURLRequestReturnCacheDataDontLoad];
        _defaultQueue = [[WRQueue alloc] initWithConfiguration:conf queue:_queue];
        _defaultQueue.defaultTaskPriority = 0.6;
        _defaultQueue.delegate = self;
        conf.networkServiceType = NSURLNetworkServiceTypeBackground;
        _backgroundQueue = [[WRQueue alloc] initWithConfiguration:conf queue:_queue];
        _backgroundQueue.defaultTaskPriority = 0.3;
        _backgroundQueue.delegate = self;
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

+ (WRServiceSynchronousResult *)synchronousExecute:(WROperation *)op {
    
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    __block id res;
    __block NSError *err = nil;
    
    if (sem) {
        op.cancelCallback = ^(WROperation * _Nonnull op) {
            err = [NSError errorWithDomain:NSStringFromClass(op.class) code:1 userInfo:@{NSLocalizedDescriptionKey:@"Operation was cancelled."}];
            dispatch_semaphore_signal(sem);
        };
        [self execute:op onSuccess:^(WROperation * _Nonnull op, id  _Nonnull result) {
            res = result;
            dispatch_semaphore_signal(sem);
        } onFail:^(WROperation * _Nonnull op, NSError * _Nonnull error) {
            err = error;
            dispatch_semaphore_signal(sem);
        }];
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    } else {
        err = [NSError errorWithDomain:NSStringFromClass(self) code:1 userInfo:@{NSLocalizedDescriptionKey:@"Error creare semaphore."}];
    }
    
    WRServiceSynchronousResult *result = [[WRServiceSynchronousResult alloc] initWithResult:res error:err];
    
    return result;
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

- (void)setAuthChallengeCallback:(void (^)(WROperationPriority, NSURLAuthenticationChallenge * _Nonnull, void (^ _Nonnull)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable)))callback
{
    self.authChallangeCallback = callback;
}


#pragma mark - Private

- (void) _printTasks {
    
    dispatch_group_t waiter = dispatch_group_create();
    __block NSMutableArray<__kindof WROperation *> *defaultTasks;
    __block NSArray<__kindof WROperation *> *backgroundTasks;
    
    dispatch_group_enter(waiter);
    [_defaultQueue getAllTasksWithCompletionHandler:^(NSArray<__kindof WROperation *> * _Nonnull tasks) {
        defaultTasks = [tasks mutableCopy];
        dispatch_group_leave(waiter);
    }];
    dispatch_group_enter(waiter);
    [_backgroundQueue getAllTasksWithCompletionHandler:^(NSArray<__kindof WROperation *> * _Nonnull tasks) {
        backgroundTasks = tasks;
        dispatch_group_leave(waiter);
    }];
    
    dispatch_group_notify(waiter, _queue, ^{
        
        printf("\n\n============ WRService operatiions ============\n");
        NSArray *exclusive = [defaultTasks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"priority == %@", @(WROperationPriorityExclusive)]];
        [defaultTasks filterUsingPredicate:[NSPredicate predicateWithFormat:@"priority != %@", @(WROperationPriorityExclusive)]];
        
        if (exclusive.count) {
            printf("---------------- Exclusive:  %ld ----------------\n", exclusive.count);
            for (WROperation *t in exclusive) {
                [self _printTask:t];
            }
        }
        if (defaultTasks.count) {
            printf("---------------- Default:    %ld ----------------\n", defaultTasks.count);
            for (WROperation *t in defaultTasks) {
                [self _printTask:t];
            }
        }
        if (backgroundTasks.count) {
            printf("---------------- Background: %ld ----------------\n", backgroundTasks.count);
            for (WROperation *t in backgroundTasks) {
                [self _printTask:t];
            }
        }
        printf("===============================================\n");
        printf("\n");
    });
}

- (void) _printTask:(WROperation*)op {
    NSURLRequest *req = op.request;
    NSString *suspended = op.isSuspended ? @"[SUSPENDED]" : @"";
    printf("[%s] %s %s\n", req.HTTPMethod.UTF8String, req.URL.absoluteString.UTF8String, suspended.UTF8String);
}

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
            
            @synchronized (self) {
                _countExclusiveTasks++;
            }
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

        [object removeObserver:self forKeyPath:@"finished" context:(__bridge void * _Nullable)(self)];
        
        @synchronized (self) {
            _countExclusiveTasks--;
        }
        
        if (_countExclusiveTasks == 0) {
            [self resumeAllTasks];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark - WRQueue Delegate

- (void)queue:(WRQueue *)queue didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    if (self.authChallangeCallback) {
        WROperationPriority priority = queue == _defaultQueue ? WROperationPriorityDefault : WROperationPriorityBackground;
        self.authChallangeCallback(priority, challenge, completionHandler);
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

@end
