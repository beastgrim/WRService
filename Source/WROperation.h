//
//  WROperation.h
//  WRService
//
//  Created by FLS on 04/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WRProgressProtocol.h"
#import "WRSourceProrocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol WROperationDelegate;

typedef void (^WRSuccessCallback)(WROperation *op, id result);
typedef void (^WRFailCallback)(WROperation *op, NSError *error);
typedef void (^WRProgressCallback)(float progress);
typedef NS_ENUM(NSInteger, WROperationPriority) {
    WROperationPriorityDefault = 0,
    WROperationPriorityBackground,
    WROperationPriorityExclusive        // All executing tasks will be suspended
};


@interface WROperation : NSObject

@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) NSURLRequest *request;

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


// KVO properties
@property (readonly, getter=isFinished) BOOL finished;


#pragma mark Initialize

- (instancetype) initWithUrl:(NSURL*)url;
- (instancetype) initWithSource:(id<WRSourceProtocol>)source;

/**
 * Method name: processResult
 * Description: You should override this method in your subclasses for modify result from nsdata to any object
 * Parameters: id - Returns any object, not NIL!
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
