//
//  ViewController.m
//  WRService
//
//  Created by FLS on 04/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#import "ViewController.h"

#import "WRService.h"

@interface ViewController () <WRProgressProtocol>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    NSURL *url = [NSURL URLWithString:@"http://speedtest.ftp.otenet.gr/files/test100Mb.db"];
    NSURL *url = [NSURL URLWithString:@"http://google.com"];
    
    WROperation *op = [[WROperation alloc] initWithUrl:url];
    op.progressDelegate = self;
    op.progressCallback = ^(float progress) {
        NSLog(@"Callback progress: %f", progress);
    };

    [[WRService shared] execute:op onSuccess:^(WROperation * _Nonnull op, NSData * _Nonnull data) {
        NSLog(@"Success: %@", data);

    } onFail:^(WROperation * _Nonnull op, NSError * _Nonnull error) {
        NSLog(@"Fail: %@", error);
    }];
}


#pragma mark - WRProgressProtocol

- (void)operation:(WROperation *)op didChangeProgress:(float)progress {
    NSLog(@"Operation %@ progress: %f", op, progress);
}


@end
