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

@interface HttpViewController () <WROperationDelegate>

@end

@implementation HttpViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    NSURL *url = [NSURL URLWithString:@"http://ip.jsontest.com"];
    NSURL *url = [NSURL URLWithString:@"https://storage.googleapis.com"];
    
//    WRJSONOperation *op = [[WRJSONOperation alloc] initWithUrl:url];
    WRXMLOperation *op = [[WRXMLOperation alloc] initWithUrl:url];
    [[WRService shared] execute:op withDelegate:self];
    
    
    WRObjectOperation * objOp = [[WRObjectOperation alloc] initWithClass:[Article class]];
    
    NSLog(@"Operation: %@", objOp);
//    [[WRService shared] execute:objOp withDelegate:self];
}


#pragma mark - WROperationDelegate

- (void)operation:(WROperation *)op didFinishWithResult:(Article*)result {
    NSLog(@"didFinishWithResult: %@", result);
}

@end
