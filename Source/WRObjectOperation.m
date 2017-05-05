//
//  WRObjectOperation.m
//  WRService
//
//  Created by FLS on 05/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#import "WRObjectOperation.h"

@implementation WRObjectOperation


- (instancetype)initWithClass:(Class<WRObjectOperationProtocol>)objClass
{
    if (![objClass conformsToProtocol:@protocol(WRObjectOperationProtocol)]) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        
    }
    return self;
}

@end
