//
//  GitHubEvent.m
//  WRService
//
//  Created by Евгений Богомолов on 06/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#import "GitHubEvent.h"
#import "NSObject_WRJSON.h"

/*
[
 {
     "type": "Event",
     "public": true,
     "payload": {
     },
     "repo": {
         "id": 3,
         "name": "octocat/Hello-World",
         "url": "https://api.github.com/repos/octocat/Hello-World"
     },
     "actor": {
         "id": 1,
         "login": "octocat",
         "gravatar_id": "",
         "avatar_url": "https://github.com/images/error/octocat_happy.gif",
         "url": "https://api.github.com/users/octocat"
     },
     "org": {
         "id": 1,
         "login": "github",
         "gravatar_id": "",
         "url": "https://api.github.com/orgs/github",
         "avatar_url": "https://github.com/images/error/octocat_happy.gif"
     },
     "created_at": "2011-09-06T17:26:27Z",
     "id": "12345"
 }
 ] */


#define DATE_FORMAT @"YYYY-MM-dd'T'HH:mm:ss'Z'"


@implementation GitHubEvent

- (instancetype)initFromJSONObject:(id)jsonObject {
    
    if (self = [super init]) {
        [self wrPlainDecodeFromJSON:jsonObject dateFormat:DATE_FORMAT];
    }
    return self;
}

- (NSString *)description {
    NSString *description = [self wrJSONDescription];
    return description;
}

@end


@implementation Actor

- (instancetype)initFromJSONObject:(id)jsonObject {
    
    if (self = [super initFromJSONObject:jsonObject]) {
        [self wrPlainDecodeFromJSON:jsonObject dateFormat:DATE_FORMAT];
    }
    return self;
}

@end


@implementation Org

- (instancetype)initFromJSONObject:(id)jsonObject {
    
    if (self = [super init]) {
        [self wrPlainDecodeFromJSON:jsonObject dateFormat:DATE_FORMAT];
    }
    return self;
}

@end


@implementation Repo

- (instancetype)initFromJSONObject:(id)jsonObject {
    
    if (self = [super init]) {
        [self wrPlainDecodeFromJSON:jsonObject dateFormat:DATE_FORMAT];
    }
    return self;
}


@end

@implementation Payload

- (instancetype)initFromJSONObject:(id)jsonObject {
    
    if (self = [super init]) {
        [self wrPlainDecodeFromJSON:jsonObject dateFormat:DATE_FORMAT];
    }
    return self;
}

@end
