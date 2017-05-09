//
//  ViewController.m
//  WRService
//
//  Created by FLS on 04/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#import "ViewController.h"

#import "WRService.h"


@interface ViewController () <WRProgressProtocol, WROperationDelegate>

@property (nonatomic, weak) IBOutlet UIProgressView *p1;
@property (nonatomic, weak) IBOutlet UIProgressView *p2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.p1.progress = 0;
    self.p2.progress = 0;

    NSURL *url = [NSURL URLWithString:@"http://speedtest.ftp.otenet.gr/files/test100Mb.db"];
//    NSURL *url = [NSURL URLWithString:@"http://speedtest.ftp.otenet.gr/files/test10Mb.db"];
//    NSURL *url = [NSURL URLWithString:@"http://google.com"];
    
    WROperation *op = [[WROperation alloc] initWithUrl:url];
    op.progressDelegate = self;
//    op.progressCallback = ^(float progress) {
//        NSLog(@"Callback progress: %f, %@", progress, self);
//    };
    op.delegate = self;
    op.priority = WROperationPriorityDefault;

    [self startBackgoundTask];
    [[WRService shared] execute:op onSuccess:^(WROperation * _Nonnull op, NSData * _Nonnull data) {
        NSLog(@"Success: %@, self: %@", data, self);

    } onFail:^(WROperation * _Nonnull op, NSError * _Nonnull error) {
        NSLog(@"Fail: %@", error);
    }];
}

- (void)dealloc {
    NSLog(@"Dealloc: %@", self);
}


#pragma mark - Test

- (void) onSuccess {
    NSLog(@"onSuccess");
    
    [UIApplication sharedApplication].keyWindow.rootViewController = [ViewController new];
}

- (void) startExclusiveTask {
    
//    NSURL *url = [NSURL URLWithString:@"http://speedtest.ftp.otenet.gr/files/test10Mb.db"];
    NSURL *url = [NSURL URLWithString:@"http://speedtest.ftp.otenet.gr/files/test100Mb.db"];

    WROperation *op = [[WROperation alloc] initWithUrl:url];
    op.priority = WROperationPriorityExclusive;
    op.progressCallback = ^(float progress) {
        NSLog(@"Exclusive progress: %f", progress);
        _p2.progress = progress;
    };
    
    NSLog(@"Exclusive task STARTED!");

    [[WRService shared] execute:op onSuccess:^(WROperation * _Nonnull op, NSData * _Nonnull data) {
        NSLog(@"Exclusive task is READY! %@", op);
    } onFail:nil];
}

- (void) startBackgoundTask {
    
    //    NSURL *url = [NSURL URLWithString:@"http://speedtest.ftp.otenet.gr/files/test10Mb.db"];
    NSURL *url = [NSURL URLWithString:@"http://speedtest.ftp.otenet.gr/files/test100Mb.db"];
    
    WROperation *op = [[WROperation alloc] initWithUrl:url];
    op.priority = WROperationPriorityBackground;
    op.progressCallback = ^(float progress) {
        NSLog(@"Backgound progress: %f", progress);
        _p2.progress = progress;
    };
    
    NSLog(@"Backgound task STARTED!");
    
    [[WRService shared] execute:op onSuccess:^(WROperation * _Nonnull op, NSData * _Nonnull data) {
        NSLog(@"Backgound task is READY! %@", op);
    } onFail:nil];
    op.cancelDelegate = self;
}


- (void) example {
    NSURL *url = [NSURL URLWithString:@"http://speedtest.ftp.otenet.gr/files/test100Mb.db"];
    
    WROperation *op = [[WROperation alloc] initWithUrl:url];
    op.progressCallback = ^(float progress) {
        NSLog(@"Progress: %f", progress);
    };
    
    [[WRService shared] execute:op onSuccess:^(WROperation * _Nonnull op, NSData * _Nonnull data) {
        NSLog(@"Backgound task is READY! %@", op);
    } onFail:^(WROperation * _Nonnull op, NSError * _Nonnull error) {
        NSLog(@"Fail error: %@", error);
    }];
}


#pragma mark - WRProgressProtocol

- (void)operation:(WROperation *)op didChangeProgress:(float)progress {
    NSLog(@"Operation %@ progress: %f", op, progress);
    static BOOL startNewTask = NO;
    _p1.progress = progress;
    
    if (progress > 0.05 && startNewTask == NO) {
        startNewTask = YES;

        
//        [[WRService shared] cancelTasksWithDelegate:self];
//        [self startExclusiveTask];
    }
}


#pragma mark - WROperationDelegate

- (void)operation:(WROperation *)op didFinishWithResult:(id)result {
    NSLog(@"didFinishWithResult: %@", result);
}

- (void)operation:(WROperation *)op didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
}


@end
