//
//  WRObjectOperation.h
//  WRService
//
//  Created by FLS on 05/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#import "WROperation.h"


NS_ASSUME_NONNULL_BEGIN


@protocol WRObjectOperationProtocol <NSObject>

@optional

- (instancetype __nullable) initFromXMLData:(NSData*)xmlData;
- (instancetype __nullable) initFromJSONData:(NSData*)jsonData;

/**
 @brief Create your class instance from raw data.
 @param jsonObject NSArray or NSDictionary
 @return Class instance.
 */

- (instancetype __nullable) initFromJSONObject:(id)jsonObject;

@end





typedef NSString HTTPMethod;

@protocol WRRequestProtocol <NSObject>

@required
+ (NSURL*) urlForMethod:(HTTPMethod*)method;


@end




@protocol WRJSONRepresentable <WRObjectOperationProtocol>

@required
- (NSDictionary*) jsonRepresentation;

@end




@interface WRObjectOperation : WROperation

@property (nonatomic, readonly) NSString *className;

/**
 @brief Creates WRObjectOperation.
 @param objClass instanse of this class will be returned on success.
 @return WRObjectOperation instance or nil.
 */

- (instancetype __nullable)initWithRequest:(NSURLRequest*)request resultClass:(Class<WRObjectOperationProtocol>)objClass;

- (instancetype __nullable)initWithUrl:(NSURL *)url requestJSONBody:(id<WRJSONRepresentable>)bodyObject method:(HTTPMethod*)method;

@end

NS_ASSUME_NONNULL_END
