//
//  WRService.h
//  WRService
//
//  Created by FLS on 04/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WROperation.h"


NS_ASSUME_NONNULL_BEGIN



@interface WRService : NSObject

+ (instancetype) shared;

- (void) execute:(WROperation*)op onSuccess:(WRSuccessCallback)success onFail:(WRFailCallback __nullable)fail;
- (void) execute:(WROperation*)op withDelegate:(id<WROperationDelegate>)delegate;
- (void) cancelTasksWithDelegate:(id)delegate;
- (void) cancelAllTasks;
//- (void) execute:(WROperation *)op withAutoCancelTarget:(__weak id __nullable)target onSuccess:(WRSuccessCallback)success onFail:(WRFailCallback __nullable)fail;


@end

NS_ASSUME_NONNULL_END
