//
//  TestViewController.m
//  WRService
//
//  Created by Евгений Богомолов on 09/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#import "TestViewController.h"
#import <WRService/WRService.h>
#import <WRService/NSObject_WRJSON.h>

#import "Article.h"
#import "GitHubEvent.h"
#import "GitHubGist.h"


@interface TestViewController () <WROperationDelegate>

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    NSURL *url = [NSURL URLWithString:@"https://storage.googleapis.com"];
    
    //    [self generateClassExample];
    [self testSimpleRequest];
}

- (void) testSimpleRequest {
    
    
    NSURL *url = [NSURL URLWithString:@"https://s-cdn.sportbox.ru/images/styles/690_388/fp_fotos/93/dc/604f8e540b134d7039de323586cee932588f80ad7e203618142168.jpg"];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    WROperation * op = [[WROperation alloc] initWithRequest:req];
    
    [[WRService shared] execute:op onSuccess:^(WROperation * _Nonnull op, NSData * _Nonnull data) {
        NSLog(@"Success: %lu, self: %@", data.length, self);
        
    } onFail:^(WROperation * _Nonnull op, NSError * _Nonnull error) {
        NSLog(@"Fail: %@", error);
    }];
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

- (void) testGithubGistRequest {
    
    NSURL *url = [NSURL URLWithString:@"https://api.github.com/gists/public"];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    WRObjectOperation *op = [[WRObjectOperation alloc] initWithRequest:req resultClass:[GitHubGist class]];
    
    [[WRService shared] execute:op onSuccess:^(WROperation * _Nonnull op, NSArray <GitHubGist*>*  _Nonnull result) {
        NSLog(@"%@", result.firstObject);
    } onFail:nil];
}

- (void) generateClassExample {
    NSURL *url = [NSURL URLWithString:@"https://api.github.com/gists/public"];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    WRObjectOperation *op = [[WRObjectOperation alloc] initWithRequest:req];
    
    [[WRService shared] execute:op onSuccess:^(WROperation * _Nonnull op, NSData*  _Nonnull result) {
        
        id json = [NSJSONSerialization JSONObjectWithData:result options:0 error:nil];
        if (json) {
            NSDictionary *options = @{WRDictOfClassKey: @{@"files": @{WRClassNameKey:@"File", WRClassPropertyNameForDictKey: @"filename"}}};
            NSDictionary *map;
            NSString *classInterface = [NSObject wrGenerateClass:@"GitHubGist" fromJSON:json renamedProperties:&map options:options];
            NSLog(@"%@", classInterface);
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:map options:NSJSONWritingPrettyPrinted error:nil];
            NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"MAP: %@", json);
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
