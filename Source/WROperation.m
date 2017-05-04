//
//  WROperation.m
//  WRService
//
//  Created by FLS on 04/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#import "WROperation.h"
#import "WROperation_Private.h"

@interface WROperation() <WROperationPrivate>

@end



@implementation WROperation {
    NSUInteger _taskIdentifier;
    long long _expectedContentLength;
    NSMutableData *_data;
    uint8_t _progress;
    BOOL _useProgress;
    NSURLSessionTask *_task;
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


#pragma mark - Private

- (void) _calculateProgress {
    float progress = (float)_data.length/_expectedContentLength;
    
    if (_useProgress) {
        [_progressDelegate operation:self didChangeProgress:progress];
    }
    if (_progressCallback) {
        _progressCallback(progress);
    }
}


#pragma mark - Getters

- (NSURLRequest *)request {
    return [NSURLRequest requestWithURL:_url];
}

- (NSUInteger)taskIdentifier {
    return _taskIdentifier;
}


#pragma mark - Setters

- (void)setProgressDelegate:(id<WRProgressProtocol>)progressDelegate {
    if (_progressDelegate != progressDelegate) {
        _progressDelegate = progressDelegate;
        _useProgress = [_progressDelegate respondsToSelector:@selector(operation:didChangeProgress:)];
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
    
    if (error) {
        if (_failCallback) {
            _failCallback(self, error);
        }
    } else {
        if (_successCallback) {
            _successCallback(self, _data);
        }
    }
}

- (void)didReceiveData:(NSData *)data {
    [_data appendData:data];
    if (_useProgress) {
        [self _calculateProgress];
    }
}

@end
