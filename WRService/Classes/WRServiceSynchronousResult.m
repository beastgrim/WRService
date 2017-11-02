//
//  WRServiceSynchronousResult.m
//  WRService
//
//  Created by Евгений Богомолов on 02/11/2017.
//

#import "WRServiceSynchronousResult.h"

@implementation WRServiceSynchronousResult

- (instancetype)initWithResult:(id)result error:(NSError *)error {
    
    if (self = [super init]) {
        if (result == nil && error == nil) {
            NSLog(@"WARNING: result and error is NIL!");
        }
        _result = result;
        _error = error;
    }
    return self;
}

@end
