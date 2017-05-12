//
//  WROperation_Private.h
//  WRService
//
//  Created by FLS on 04/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#ifndef WROperation_Private_h
#define WROperation_Private_h

@class WROperation;
@protocol WROperationPrivate <NSObject>

@required

- (void)setSessionTask:(NSURLSessionTask*_Nonnull)task;
- (void)didReceiveData:(NSData *_Nonnull)data;
- (void)didCompleteWithError:(nullable NSError *)error;
- (void)didReceiveResponse:(NSURLResponse*_Nonnull)response;

@end

@interface WROperation(Private)


- (void)setSessionTask:(NSURLSessionTask*_Nonnull)task;
- (void)didReceiveData:(NSData *_Nonnull)data;
- (void)didCompleteWithError:(nullable NSError *)error;
- (void)didReceiveResponse:(NSURLResponse*_Nonnull)response;

@end

#endif /* WROperation_Private_h */
