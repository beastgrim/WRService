//
//  Article.m
//  WRService
//
//  Created by FLS on 05/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#import "Article.h"
#import "NSObject_WRJSON.h"

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

+ (NSDictionary *)testJSON {
    
    return @{@"identifier":@"123",
             @"favorite":@"true",
             @"rating":@"5.0",
             @"onPage":@"10",
             @"name":@"Best article",
             @"info":@{@"mail":@"afa.mail.com"},
             @"date":@"128452352"};
}

+(NSURL *)urlForMethod:(NSString *)method {
    
    if ([method isEqualToString:@"GET"]) {
        NSURL *url = [NSURL URLWithString:@"http://speedtest.ftp.otenet.gr/files/test10Mb.db"];
        return url;
    }
    return nil;
}

+ (id)decodeFromJSONData:(NSData *)jsonData {
    
    NSDictionary *json = [self testJSON];
    
    Article *a = [Article new];
    [a setValue:json[@"identifier"] forKey:@"identifier"];
    
    return a;
}
/*
- (instancetype)initFromJSONData:(NSData *)jsonData {
    
    if (self = [super init]) {
        
        NSDictionary *json = [Article testJSON];
        
        _identifier = [json[@"identifier"] integerValue];
        _timeoutInterval = 60;
        _favorite = [json[@"favorite"] boolValue];
        _rating = [json[@"rating"] floatValue];
        _onPage = @([json[@"onPage"] integerValue]);
        _name = json[@"name"];
        _info = json[@"info"];
        _date = [NSDate date];
    }
    return self;
} */

- (instancetype)initFromJSONObject:(id)jsonObject {
    
    if (self = [super init]) {
        
        NSDictionary *json = [Article testJSON];
        
        _identifier = [json[@"identifier"] integerValue];
        _timeoutInterval = 60;
        _favorite = [json[@"favorite"] boolValue];
        _rating = [json[@"rating"] floatValue];
        _onPage = @([json[@"onPage"] integerValue]);
        _name = json[@"name"];
        _info = json[@"info"];
        _date = [NSDate date];
        _parentArticle = [Article new];
        
    }
    return self;
}


- (NSDictionary *)jsonRepresentation {
    return [self wrEncodeToJSONObject];
}


- (NSString *)debugDescription {
    return [self wrJSONDescription];
}

@end
