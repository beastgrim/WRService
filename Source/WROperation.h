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

typedef void (^WRSuccessCallback)(WROperation *op, NSData *data);
typedef void (^WRFailCallback)(WROperation *op, NSError *error);

typedef void (^WRProgressCallback)(float progress);

@interface WROperation : NSObject

@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) NSURLRequest *request;

@property (nonatomic, assign, readonly) NSUInteger taskIdentifier;

// Progress support
@property (nonatomic, weak) id<WRProgressProtocol> progressDelegate;
@property (nonatomic, copy) WRProgressCallback progressCallback;

@property (nonatomic, copy) WRFailCallback failCallback;
@property (nonatomic, copy) WRSuccessCallback successCallback;


- (instancetype) initWithUrl:(NSURL*)url;
- (instancetype) initWithSource:(id<WRSourceProtocol>)source;

@end

NS_ASSUME_NONNULL_END
