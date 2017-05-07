//
//  GitHubGist.m
//  WRService
//
//  Created by Evgeny Bogomolov on 5/7/17.
//  Copyright © 2017 WR. All rights reserved.
//

#import "GitHubGist.h"
#import "NSObject_WRJSON.h"



@implementation Files

- (instancetype)initFromJSONObject:(id)jsonObject {
    
    if (self = [super init]) {
        [self wrPlainDecodeFromJSON:jsonObject];
    }
    return self;
}

@end



@implementation GitHubGist

- (instancetype)initFromJSONObject:(id)jsonObject {
    
    if (self = [super init]) {
        [self wrPlainDecodeFromJSON:jsonObject];
    }
    return self;
}

- (NSString *)description {
    return [self wrJSONDescription];
}

@end

