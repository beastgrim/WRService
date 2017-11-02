//
//  WRService.h
//  WRService
//
//  Created by FLS on 04/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WROperation.h"
#import "WRObjectOperation.h"
#import "WRProgressProtocol.h"
#import "WRServiceSynchronousResult.h"


NS_ASSUME_NONNULL_BEGIN



@interface WRService : NSObject

+ (instancetype) shared;

+ (void) execute:(WROperation*)op onSuccess:(WRSuccessCallback)success onFail:(WRFailCallback __nullable)fail;
+ (void) execute:(WROperation*)op withDelegate:(id<WROperationDelegate>)delegate;

+ (WRServiceSynchronousResult*) synchronousExecute:(WROperation*)op;

- (void) execute:(WROperation*)op onSuccess:(WRSuccessCallback)success onFail:(WRFailCallback __nullable)fail;
- (void) execute:(WROperation*)op withDelegate:(id<WROperationDelegate>)delegate;

- (void) cancelTasksWithDelegate:(id)delegate;
- (void) cancelAllTasks;

- (void) setAuthChallengeCallback:(void(^)(WROperationPriority queuePriority, NSURLAuthenticationChallenge *challenge, void (^completionHandler)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential)))callback;


+ (void) printInformation;

@end

NS_ASSUME_NONNULL_END
