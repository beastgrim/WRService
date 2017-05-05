//
//  WROperation.m
//  WRService
//
//  Created by FLS on 04/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#import "WROperation.h"
#import "WROperation_Private.h"
#import "WRHTTPRequestProtocol.h"


typedef NS_OPTIONS(NSUInteger, WRDelegateOption) {
    WRDelegateOptionSuccess = 1 << 0,
    WRDelegateOptionError = 1 << 1
};

@interface WROperation() <WROperationPrivate>

@property (readwrite, getter=isFinished) BOOL finished;

@end


@implementation WROperation {
    NSUInteger _taskIdentifier;
    long long _expectedContentLength;
    NSMutableData *_data;
    uint8_t _progress;
    BOOL _useProgress;
    NSURLSessionTask *_task;
    WRDelegateOption _delegateSettings;
}


- (instancetype)initWithUrl:(NSURL *)url
{
    if (url == nil) return nil;

    self = [super init];
    if (self) {
        _url = url;
        _data = [NSMutableData new];
     }
    return self;
}

- (instancetype)initWithSource:(id<WRSourceProtocol>)source
{
    NSURL *url = [source sourceUrl];
    if (url == nil) return nil;

    self = [super init];
    if (self) {
        _url = url;
    }
    return self;
}


- (void)cancel {
    self.successCallback = nil;
    self.failCallback = nil;
    self.delegate = nil;
    self.progressDelegate = nil;
    self.progressCallback = nil;
    [_task cancel];
}

/**
 * Method name: processResult
 * Description: Yuo should override this method in your subclasses for modify result from nsdata to any object
 * Parameters: id - any object
 */
- (id)processResult:(id)result {
    
    return result;
}

#pragma mark - Private

- (void) _calculateProgress {
    float progress = (float)_data.length/_expectedContentLength;

    if (_progressCallback) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _progressCallback(progress);
        });
    } else if (_useProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_progressDelegate operation:self didChangeProgress:progress];
        });
    }
}


#pragma mark - Getters

- (NSURLRequest *)request {
    if ([self conformsToProtocol:@protocol(WRHttpRequestProtocol)]) {
        id <WRHttpRequestProtocol> obj = self;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:_url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:obj.timeoutInterval];
        return request;
    }
    return [NSURLRequest requestWithURL:_url];
}

- (NSUInteger)taskIdentifier {
    return _taskIdentifier;
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

- (void)setContentLength:(long long)length {
    _expectedContentLength = length;
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
        if (_failCallback) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _failCallback(self, error);
            });
        } else
        if (_delegateSettings & WRDelegateOptionError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate operation:self didFailWithError:error];
            });
        }
    } else {
        id result = [self processResult:_data];
        
        if (result == nil) {
            NSException *exeption = [[NSException alloc] initWithName:@"WROperationExeption" reason:@"Process result method return nil" userInfo:nil];
            [exeption raise];
        }
        
        if ([result isKindOfClass:[NSError class]]) {
            [self didCompleteWithError:result];
            
        } if (_successCallback) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _successCallback(self, result);
            });
        } else if (_delegateSettings & WRDelegateOptionSuccess) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate operation:self didFinishWithResult:result];
            });
        }
    }
}

- (void)didReceiveData:(NSData *)data {
    [_data appendData:data];
    [self _calculateProgress];
}

@end
