//
//  GitHubGist.h
//  WRService
//
//  Created by Evgeny Bogomolov on 5/7/17.
//  Copyright © 2017 WR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WRService/WRObjectOperation.h>


@class Owner, File;


@interface GitHubGist : NSObject <WRObjectOperationProtocol>

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, assign) NSInteger comments;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, strong) Owner *owner;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *git_push_url;
@property (nonatomic, strong) NSDictionary <NSString*,File*> *files;
@property (nonatomic, copy) NSString *html_url;
@property (nonatomic, copy) NSString *git_pull_url;
@property (nonatomic, copy) NSString *updated_at;
@property (nonatomic, assign) short truncated;
@property (nonatomic, copy) NSString *forks_url;
@property (nonatomic, copy) NSString *commits_url;
@property (nonatomic, copy) id user;
@property (nonatomic, assign) short public;
@property (nonatomic, copy) NSString *comments_url;


@end


@interface Owner : NSObject <WRObjectOperationProtocol>

@property (nonatomic, assign) NSInteger id;
@property (nonatomic, copy) NSString *organizations_url;
@property (nonatomic, copy) NSString *received_events_url;
@property (nonatomic, copy) NSString *following_url;
@property (nonatomic, copy) NSString *login;
@property (nonatomic, copy) NSString *avatar_url;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *subscriptions_url;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *repos_url;
@property (nonatomic, copy) NSString *html_url;
@property (nonatomic, copy) NSString *events_url;
@property (nonatomic, assign) short site_admin;
@property (nonatomic, copy) NSString *starred_url;
@property (nonatomic, copy) NSString *gists_url;
@property (nonatomic, copy) NSString *gravatar_id;
@property (nonatomic, copy) NSString *followers_url;


@end


@interface File : NSObject <WRObjectOperationProtocol>

@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *raw_url;
@property (nonatomic, copy) NSString *filename;
@property (nonatomic, assign) NSInteger size;
@property (nonatomic, copy) NSString *type;


@end
