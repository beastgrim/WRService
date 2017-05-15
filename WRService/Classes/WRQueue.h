//
//  WRQueue.h
//  WRService
//
//  Created by FLS on 05/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WROperation.h"

NS_ASSUME_NONNULL_BEGIN

extern NSErrorDomain const WRQueueErrorDomain;
typedef NS_ENUM(NSUInteger, WRQueueError) {
    WRQueueErrorUnknown = 0,
    WRQueueErrorTaskAlreadyPerforming
};

@protocol WRQueueDelegate;


@interface WRQueue : NSObject

@property (nonatomic, weak) id<WRQueueDelegate> delegate;

@property (nonatomic, readonly) NSURLSession *session;
@property (nonatomic, assign, readonly) NSInteger countExclusiveTasks;
@property (nonatomic, assign) float defaultTaskPriority;

- (instancetype)initWithConfiguration:(NSURLSessionConfiguration*)conf queue:(dispatch_queue_t)queue;

- (void) execute:(WROperation *)op;
- (void) cancelTasksWithDelegate:(id)delegate;

- (void) suspendAllTasks;
- (void) resumeAllTasks;

@end


@protocol WRQueueDelegate <NSObject>

@optional
- (void) queue:(WRQueue *)queue didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler;

@end

NS_ASSUME_NONNULL_END
