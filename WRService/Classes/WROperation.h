//
//  WROperation.h
//  WRService
//
//  Created by FLS on 04/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WRProgressProtocol.h"

NS_ASSUME_NONNULL_BEGIN

extern NSErrorDomain const WROperationErrorDomain;

@protocol WROperationDelegate;

typedef void (^WRSuccessCallback)(WROperation *op, id result);
typedef void (^WRFailCallback)(WROperation *op, NSError *error);
typedef void (^WRCancelCallback)(WROperation *op);
typedef void (^WRProgressCallback)(float progress);
typedef NS_ENUM(NSInteger, WROperationPriority) {
    WROperationPriorityDefault = 0,
    WROperationPriorityBackground,
    WROperationPriorityExclusive        // All executing tasks will be suspended
};


@interface WROperation : NSObject

@property (nonatomic, readonly) NSURL * __nullable url;
@property (nonatomic, readonly) NSURLRequest *request;

@property (nonatomic, readonly) NSURLResponse *response;
@property (nonatomic, readonly) NSHTTPURLResponse *HTTPResponse;
@property (nonatomic, readonly) NSData *responseData;


@property (nonatomic, assign, readonly) NSUInteger taskIdentifier;
@property (nonatomic, assign) WROperationPriority priority;

// Delegate support
@property (nonatomic, weak) id<WROperationDelegate> __nullable delegate;
@property (nonatomic, weak) id __nullable cancelDelegate;

// Progress support
@property (nonatomic, weak) id<WRProgressProtocol> __nullable progressDelegate;
@property (nonatomic, copy) WRProgressCallback __nullable progressCallback;

// Callback support
@property (nonatomic, copy) WRFailCallback __nullable failCallback;
@property (nonatomic, copy) WRSuccessCallback __nullable successCallback;
@property (nonatomic, copy) WRCancelCallback __nullable cancelCallback;

@property (readonly) BOOL isSuspended;

// KVO properties
@property (readonly, getter=isFinished) BOOL finished;
@property (readonly, getter=isCanceled) BOOL canceled;
@property (readonly, assign) float progress;


#pragma mark Initialize

- (instancetype) initWithUrl:(NSURL*)url;
- (instancetype) initWithRequest:(NSURLRequest*)request;

/**
 @brief Process data to convert to expected class.
 
 You should override this method in your subclasses for modify result from nsdata to any object.
 
 @param result any object
 
 @return id any object that will be return your subclass.
 */

- (id) processResult:(id)result;

- (void) cancel;

@end






@protocol WROperationDelegate <NSObject>

@optional
- (void) operation:(WROperation*)op didFinishWithResult:(id)result;
- (void) operation:(WROperation *)op didFailWithError:(NSError*)error;

@end

NS_ASSUME_NONNULL_END
