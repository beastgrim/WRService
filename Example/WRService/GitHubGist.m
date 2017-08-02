//
//  GitHubGist.m
//  WRService
//
//  Created by Evgeny Bogomolov on 5/7/17.
//  Copyright © 2017 WR. All rights reserved.
//

#import "GitHubGist.h"
#import "NSObject_WRJSON.h"


@implementation GitHubGist

- (instancetype)initFromJSONObject:(id)jsonObject {
    
    if (self = [super init]) {
        
        NSError *decodeError = nil;
        if (![self wrDecodeFromJSON:jsonObject options:nil error:&decodeError]) {
            NSLog(@"Error decode: %@", decodeError);
            return nil;
        }
    }

    return self;
}

- (NSString *)description {
    return [self wrJSONDescription];
}

@end


@implementation File

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



@implementation Owner

- (instancetype)initFromJSONObject:(id)jsonObject {
    
    if (self = [super init]) {
        [self wrPlainDecodeFromJSON:jsonObject];
    }
    return self;
}

@end
