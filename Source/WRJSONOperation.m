//
//  WRJSONOperation.m
//  WRService
//
//  Created by FLS on 05/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#import "WRJSONOperation.h"

@implementation WRJSONOperation


- (id)processResult:(NSData *)result {
    result = [super processResult:result];
    
    if (![result isKindOfClass:[NSData class]]) return nil;
    
    NSError *err;
    id obj = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&err];
    
    if (err) {
        return err;
    }
    
    return obj;
}

@end
