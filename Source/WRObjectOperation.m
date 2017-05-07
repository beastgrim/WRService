//
//  WRObjectOperation.m
//  WRService
//
//  Created by FLS on 05/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#import "WRObjectOperation.h"


@implementation WRObjectOperation {
    
    Class _class;
}


#pragma mark - Initialize

- (instancetype)initWithRequest:(NSURLRequest *)request resultClass:(Class<WRObjectOperationProtocol>)objClass
{
    if (self = [super initWithRequest:request]) {
        _class = objClass;
    }
    return self;
}

- (instancetype)initWithUrl:(NSURL *)url requestJSONBody:(id<WRJSONRepresentable>)bodyObject method:(HTTPMethod *)method
{
    if (![bodyObject conformsToProtocol:@protocol(WRJSONRepresentable)]) return nil;
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    req.HTTPMethod = method;
    id jsonObject = [bodyObject jsonRepresentation];
    
    NSError *err = nil;
    NSData * data = [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:&err];
    if (err) {
        NSLog(@"ERROR create WRObjectOperation: %@", err);
        return nil;
    }
    req.HTTPBody = data;

    self = [super initWithRequest:req];
    if (self) {
        
    }
    return self;
}


#pragma mark - 

- (id)processResult:(id)result {
    result = [super processResult:result];
    
    if (![result isKindOfClass:[NSData class]]) return nil;
    
    if (_class == nil) {
        return result;
    }

    id object = nil;

    if ([_class instancesRespondToSelector:@selector(initFromJSONData:)]) {
        object = [[_class alloc] initFromJSONData:result];
    } else if ([_class instancesRespondToSelector:@selector(initFromXMLData:)]) {
        object = [[_class alloc] initFromXMLData:result];
    } else if ([_class instancesRespondToSelector:@selector(initFromJSONObject:)]) {
        
        NSError *err;
        id obj = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&err];
        
        if (err) {
            return err;
        }
        
        if ([obj isKindOfClass:[NSArray class]]) {
            
            NSArray *objects = obj;
            NSMutableArray *results = [NSMutableArray new];
            BOOL successDecode = YES;
            
            for (NSDictionary *json in objects) {
                id i = [[_class alloc] initFromJSONObject:json];
                if (i) {
                    [results addObject:i];
                } else {
                    successDecode = NO;
                    break;
                }
            }
            if (successDecode) {
                object = results;
            } else {
                NSError *error = [NSError errorWithDomain:WROperationErrorDomain code:3 userInfo:@{NSLocalizedDescriptionKey:@"Error decode array of objects."}];
                object = error;
            }
        } else {
            object = [[_class alloc] initFromJSONObject:obj];
        }
    } else {
        NSError *err = [NSError errorWithDomain:WROperationErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey:@"Class decode protocol not emplemented."}];
        return err;
    }
    
    if (object == nil) {
        NSError *err = [NSError errorWithDomain:WROperationErrorDomain code:2 userInfo:@{NSLocalizedDescriptionKey:@"Error decode class."}];
        return err;
    }
    return object;
}


@end
