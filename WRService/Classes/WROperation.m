//
//  WROperation.m
//  WRService
//
//  Created by FLS on 04/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#import "WROperation.h"
#import "WROperation_Private.h"

NSErrorDomain const WROperationErrorDomain = @"WROperationErrorDomain";

typedef NS_OPTIONS(NSUInteger, WRDelegateOption) {
    WRDelegateOptionSuccess = 1 << 0,
    WRDelegateOptionError = 1 << 1
};

@interface WROperation() <WROperationPrivate>

@property (readwrite, getter=isFinished) BOOL finished;
@property (readwrite, getter=isCanceled) BOOL canceled;
@property (readwrite, assign) float progress;

@end


@implementation WROperation {
    NSUInteger _taskIdentifier;
    long long _expectedContentLength;
    NSMutableData *_data;
    BOOL _useProgress;
    NSURLSessionTask *_task;
    WRDelegateOption _delegateSettings;
}


- (instancetype)initWithUrl:(NSURL *)url
{
    if (url == nil) [[NSException exceptionWithName:NSStringFromClass([WROperation class]) reason:@"URL is nil" userInfo:nil] raise];
    
    self = [self init];
    if (self) {
        _url = url;
        _request = [NSURLRequest requestWithURL:url];
    }
    return self;
}

- (instancetype)initWithRequest:(NSURLRequest *)request
{
    if (request == nil) [[NSException exceptionWithName:NSStringFromClass([WROperation class]) reason:@"NSURLRequest is nil" userInfo:nil] raise];

    self = [self init];
    if (self) {
        _request = request;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _data = [NSMutableData new];
    }
    return self;
}


- (void)cancel {
    self.successCallback = nil;
    self.failCallback = nil;
    self.delegate = nil;
    self.progressDelegate = nil;
    self.progressCallback = nil;
    self.canceled = YES;
    [_task cancel];
    if (_cancelCallback) {
        self.cancelCallback(self);
        self.cancelCallback = nil;
    }
}

- (id)processResult:(id)result {
    
    return result;
}


#pragma mark - Private

- (void) _calculateProgress {
    float progress = (float)_data.length/(float)_expectedContentLength;
    if (progress > 1.0 || progress < 0.0) {
        return;
    }
    
    self.progress = progress;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_progressCallback) {
            _progressCallback(progress);
        } else if (_useProgress) {
            [_progressDelegate operation:self didChangeProgress:progress];
        }
    });
}


#pragma mark - Getters

- (NSUInteger)taskIdentifier {
    return _taskIdentifier;
}

- (NSData *)responseData {
    return _data;
}
- (BOOL)isSuspended {
    return _task.state == NSURLSessionTaskStateSuspended;
}


#pragma mark - Setters

- (void)setPriority:(WROperationPriority)priority {
    if (_priority != priority) {
        _priority = priority;
    }
}

- (void)setProgressDelegate:(id<WRProgressProtocol>)progressDelegate {
    if (_progressDelegate != progressDelegate) {
        _progressDelegate = progressDelegate;
        _useProgress = [_progressDelegate respondsToSelector:@selector(operation:didChangeProgress:)];
    }
}

- (void)setDelegate:(id<WROperationDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
        
        if (_cancelDelegate == nil) {
            _cancelDelegate = delegate;
        }
        
        if ([delegate respondsToSelector:@selector(operation:didFinishWithResult:)]) {
            _delegateSettings |= WRDelegateOptionSuccess;
        }
        if ([delegate respondsToSelector:@selector(operation:didFailWithError:)]) {
            _delegateSettings |= WRDelegateOptionError;
        }
    }
}

- (void)didReceiveResponse:(NSURLResponse*)response {
    long long size = [response expectedContentLength];
    _expectedContentLength = size;
    _response = response;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        _HTTPResponse = (NSHTTPURLResponse*)response;
    }
}

- (void)setSessionTask:(NSURLSessionTask *)task {
    if (_task == nil) {
        _task = task;
        _taskIdentifier = task.taskIdentifier;
    }
}


#pragma mark - WROperationPrivate

- (void)didCompleteWithError:(NSError * _Nullable )error {
    
    self.finished = YES;
    
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_failCallback) {
                _failCallback(self, error);
            } else  if (_delegateSettings & WRDelegateOptionError) {
                [_delegate operation:self didFailWithError:error];
            }
        });
        
    } else {
        id result = [self processResult:_data];
        
        if (result == nil) {
            NSException *exeption = [[NSException alloc] initWithName:@"WROperationExeption" reason:@"Process result method return nil" userInfo:nil];
            [exeption raise];
        }
        
        if ([result isKindOfClass:[NSError class]]) {
            [self didCompleteWithError:result];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (_successCallback) {
                    _successCallback(self, result);
                } else if (_delegateSettings & WRDelegateOptionSuccess) {
                    [_delegate operation:self didFinishWithResult:result];
                }
            });
        }  
    }
}

- (void)didReceiveData:(NSData *)data {
    [_data appendData:data];
    [self _calculateProgress];
}

- (void)didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

#pragma mark - Helpers

- (NSString *)debugDescription {
    NSString *desc = [super description];
    NSString *requestData = [[NSString alloc] initWithData:self.request.HTTPBody encoding:NSUTF8StringEncoding];
    NSString *responseData = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    NSString *requestInfo = [NSString stringWithFormat:@"{ http method: %@, headers %@\n[DATA]: %@", self.request.HTTPMethod, self.request.allHTTPHeaderFields ?: @{}, requestData.length ? requestData: [NSString stringWithFormat:@"%lu-byte body", self.request.HTTPBody.length]];
    return [NSString stringWithFormat:@"%@\n[REQUEST]: %@ %@\n\n[RESPONSE]: %@\n[DATA]: %@", desc, self.request, requestInfo, self.HTTPResponse ?: self.response, responseData.length ? responseData : [NSString stringWithFormat:@"%lu-byte body", self.responseData.length]];
}



@end
