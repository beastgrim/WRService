//
//  Article.h
//  WRService
//
//  Created by FLS on 05/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WRObjectOperation.h"


@interface Article : NSObject <WRObjectOperationProtocol>

@property NSTimeInterval timeoutInterval;


@property (nonatomic, assign) NSInteger identifier;
@property (nonatomic, assign) BOOL favorite;
@property (nonatomic, assign) float rating;
@property (nonatomic, copy) NSNumber * onPage;
@property (nonatomic, copy) NSString * name;
@property (nonatomic, strong) NSDictionary * info;
@property (nonatomic, strong) NSDate *date;


+ (instancetype) testAtricle;

@end
