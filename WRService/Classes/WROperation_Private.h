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

- (void)didReceiveData:(NSData *_Nonnull)data;
- (void)didCompleteWithError:(nullable NSError *)error;
- (void)setSessionTask:(NSURLSessionTask*_Nonnull)task;
- (void)setContentLength:(long long)length;

@end

@interface WROperation(Private)

- (void)didReceiveData:(NSData *_Nonnull)data;
- (void)didCompleteWithError:(nullable NSError *)error;
- (void)setSessionTask:(NSURLSessionTask*_Nonnull)task;
- (void)setContentLength:(long long)length;

@end

#endif /* WROperation_Private_h */
