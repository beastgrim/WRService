//
//  WRObjectOperation.h
//  WRService
//
//  Created by FLS on 05/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#import "WROperation.h"
#import "WRHTTPRequestProtocol.h"




@protocol WRObjectOperationProtocol <NSObject, WRHttpRequestProtocol>

@required
+ (NSURL*) urlForMethod:(NSString*)method;

@end






@interface WRObjectOperation : WROperation

- (instancetype)initWithClass:(Class<WRObjectOperationProtocol>)objClass;

@end
