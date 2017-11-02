//
//  WRServiceSynchronousResult.h
//  WRService
//
//  Created by Евгений Богомолов on 02/11/2017.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WRServiceSynchronousResult : NSObject

@property (nonatomic, readonly) NSError *__nullable error;
@property (nonatomic, readonly) id __nullable result;

- (instancetype)initWithResult:(id __nullable)result error:(NSError* __nullable)error;

@end

NS_ASSUME_NONNULL_END
