//
//  Article.m
//  WRService
//
//  Created by FLS on 05/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#import "Article.h"

@implementation Article


+ (instancetype)testAtricle {
    
    Article *a = [Article new];
    
    a.identifier = 123;
    a.favorite = YES;
    a.rating = 5.0;
    a.onPage = @(10);
    a.name = @"Best article";
    a.info = @{@"mail": @"sfa@mail.com"};
    a.date = [NSDate date];

    return a;
}

+(NSURL *)urlForMethod:(NSString *)method {
    
    if ([method isEqualToString:@"GET"]) {
        NSURL *url = [NSURL URLWithString:@"http://speedtest.ftp.otenet.gr/files/test100Mb.db"];
        return url;
    }
    return nil;
}

@end
