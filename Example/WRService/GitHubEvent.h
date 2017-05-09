//
//  GitHubEvent.h
//  WRService
//
//  Created by Евгений Богомолов on 06/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WRService/WRObjectOperation.h>


@class Repo, Payload, Actor, Org;

@interface GitHubEvent : NSObject <WRObjectOperationProtocol>


@property (nonatomic, strong) Repo *repo;
@property (nonatomic, strong) Actor *actor;
@property (nonatomic, assign) short public;
@property (nonatomic, assign) NSInteger id;
@property (nonatomic, copy) NSDate *created_at;
@property (nonatomic, strong) Org *org;
@property (nonatomic, strong) Payload *payload;
@property (nonatomic, copy) NSString *type;


/* test properties
@property NSUInteger u_intiger;
@property NSInteger integer;
@property float float_val;
@property short short_val;
@property unsigned short u_short_val;
@property char * char_p_val;
@property void * void_p_val;
@property long long_val;
@property long long long_long_val;
@property unsigned long long u_long_long_val;
@property double double_val;
@property int int_val;
@property unsigned int u_int_val;
@property char char_val;
@property unsigned char u_char_val; */

@end



@interface Org : NSObject <WRObjectOperationProtocol>

@property (nonatomic, assign) NSInteger id;
@property (nonatomic, copy) NSString *login;
@property (nonatomic, copy) NSString *avatar_url;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *gravatar_id;


@end



@interface Actor : Org <WRObjectOperationProtocol>

@property (nonatomic, copy) NSString *display_login;

@end



@interface Repo : NSObject <WRObjectOperationProtocol>

@property (nonatomic, assign) NSInteger id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *url;


@end



@interface Payload : NSObject

@property (nonatomic, copy) NSString *before;
@property (nonatomic, copy) NSString *ref;
@property (nonatomic, assign) NSInteger push_id;
@property (nonatomic, assign) NSInteger size;
@property (nonatomic, assign) NSInteger distinct_size;
@property (nonatomic, copy) NSString *head;


@end


