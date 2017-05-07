//
//  HttpViewController.m
//  WRService
//
//  Created by FLS on 05/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#import "HttpViewController.h"
#import "WRService.h"
#import "WRJSONOperation.h"
#import "WRXMLOperation.h"
#import "WRObjectOperation.h"
#import "Article.h"
#import "GitHubEvent.h"
#import "NSObject_WRJSON.h"


@interface HttpViewController () <WROperationDelegate>

@end

@implementation HttpViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    NSURL *url = [NSURL URLWithString:@"https://storage.googleapis.com"];

    [self generateClassExample];
}


- (void) testJSONEncoding {
    NSURL *url = [NSURL URLWithString:@"http://ip.jsontest.com"];
    
    Article *a = [Article testAtricle];

    WRObjectOperation * objOp = [[WRObjectOperation alloc] initWithUrl:url requestJSONBody:a method:@"POST"];
    
    
    [[WRService shared] execute:objOp withDelegate:self];
}

- (void) testObjectOperation {
    NSURL *url = [NSURL URLWithString:@"http://ip.jsontest.com"];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    WRObjectOperation * objOp = [[WRObjectOperation alloc] initWithRequest:req resultClass:[Article class]];
    objOp.progressCallback = ^(float progress) {
        NSLog(@"Progress: %f", progress);
    };
    
    [[WRService shared] execute:objOp onSuccess:^(WROperation * _Nonnull op, Article * _Nonnull result) {
        NSLog(@"Article: %@", result);
    } onFail:^(WROperation * _Nonnull op, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void) testGithubEventRequest {
    
    NSURL *url = [NSURL URLWithString:@"https://api.github.com/events"];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    WRObjectOperation *op = [[WRObjectOperation alloc] initWithRequest:req resultClass:[GitHubEvent class]];
    
    [[WRService shared] execute:op withDelegate:self];
}

- (void) generateClassExample {
    NSURL *url = [NSURL URLWithString:@"https://api.github.com/events"];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    WRObjectOperation *op = [[WRObjectOperation alloc] initWithRequest:req];
    
    [[WRService shared] execute:op onSuccess:^(WROperation * _Nonnull op, NSData*  _Nonnull result) {
        
        id json = [NSJSONSerialization JSONObjectWithData:result options:0 error:nil];
        if (json) {
            NSString *classInterface = [NSObject wrGenerateClass:@"GitHubEvent" fromJSON:json];
            NSLog(@"%@", classInterface);
        }
    } onFail:nil];
}

#pragma mark - WROperationDelegate

- (void)operation:(WROperation *)op didFinishWithResult:(NSArray<GitHubEvent*>*)result {
    NSLog(@"didFinishWithResult: %@", [result debugDescription]);
    
//    GitHubEvent *e = result.firstObject;
    
//    for (GitHubEvent *e in result) {
//        NSLog(@"Date: %@ - class: %@", e.created_at, NSStringFromClass([e.created_at class]));
//    }
}

@end
