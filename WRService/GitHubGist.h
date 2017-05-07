//
//  GitHubGist.h
//  WRService
//
//  Created by Evgeny Bogomolov on 5/7/17.
//  Copyright © 2017 WR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WRObjectOperation.h"


@class Files;


@interface GitHubGist : NSObject <WRObjectOperationProtocol>

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) id desc;
@property (nonatomic, assign) NSInteger comments;
@property (nonatomic, copy) NSDate *created_at;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *git_push_url;
@property (nonatomic, strong) Files *files;
@property (nonatomic, copy) NSString *html_url;
@property (nonatomic, copy) NSString *git_pull_url;
@property (nonatomic, copy) NSDate *updated_at;
@property (nonatomic, assign) short truncated;
@property (nonatomic, copy) NSString *forks_url;
@property (nonatomic, copy) NSString *commits_url;
@property (nonatomic, copy) id user;
@property (nonatomic, assign) short public;
@property (nonatomic, copy) NSString *comments_url;


@end



@interface Files : NSObject <WRObjectOperationProtocol>

@property (nonatomic, strong) NSDictionary *_;


@end
