//
//  WRServiceTests.m
//  WRServiceTests
//
//  Created by beastgrim on 05/09/2017.
//  Copyright (c) 2017 beastgrim. All rights reserved.
//


@import XCTest;

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testArticleFlatDecode
{
    NSDictionary *json = [Article testJSON];
    /*
     @{@"identifier":@"123",
     @"favorite":@"true",
     @"rating":@"5.0",
     @"onPage":@"10",
     @"name":@"Best article",
     @"info":@{@"mail":@"afa.mail.com"},
     @"date":@"2017-08-02T15:08:25Z"};
     */
    XCTAssert(json != nil);
    
    Article *a = [[Article alloc] initFromJSONObject:json];
    
    XCTAssert(a != nil);
    
    XCTAssert(a.identifier == 123);
    XCTAssert(a.favorite == YES);
    XCTAssert(a.rating == 5.0);
    XCTAssert([a.onPage isEqualToNumber:@(10)]);
    XCTAssert([a.name isEqualToString:@"Best article"]);
    XCTAssert([a.info isEqualToDictionary:@{@"mail":@"afa.mail.com"}]);
    
    NSDateFormatter *df = [NSDateFormatter new];
    df.dateFormat = WRDefaultDateFormat;
    NSDate *date = [df dateFromString:@"2017-08-02T15:08:25Z"];
    XCTAssert([a.date isEqualToDate:date]);
    
}

- (void)testArticleWithRequiredParameter {
    
    NSMutableDictionary *json = [[Article testJSON] mutableCopy];
    /*
     @{@"identifier":@"123",
     @"favorite":@"true",
     @"rating":@"5.0",
     @"onPage":@"10",
     @"name":@"Best article",
     @"info":@{@"mail":@"afa.mail.com"},
     @"date":@"2017-08-02T15:08:25Z"};
     */
    XCTAssert(json != nil);
    
    Article *a = [Article new];
    
    NSDictionary *options = @{WRRequiredPropertiesKey: [NSSet setWithObjects:@"identifier", nil]};
    NSError *decodeErr = nil;
    [a wrDecodeFromJSON:json options:options error:&decodeErr];
    
    XCTAssert(decodeErr == nil);
    
    
    // remove required parameter
    json[@"identifier"] = nil;
    [a wrDecodeFromJSON:json options:options error:&decodeErr];
    XCTAssert(decodeErr != nil);

}

- (void)testArticleWithPropertiesMap {
    
    NSDictionary *json =      @{@"id":@"123",
                                @"fav":@"true",
                                @"rate":@"5.0",
                                @"page":@"10",
                                @"title":@"Best article",
                                @"infoDict":@{@"mail":@"afa.mail.com"},
                                @"stamp":@"2017-08-02T15:08:25Z"};
    Article *a = [Article new];
    
    NSDictionary *options = @{WRPropertyNamesMapKey: @{@"identifier":@"id",
                                                       @"favorite":@"fav",
                                                       @"rating":@"rate",
                                                       @"onPage":@"page",
                                                       @"name":@"title",
                                                       @"info":@"infoDict",
                                                       @"date":@"stamp"}};
    
    NSError *decodeErr = nil;
    [a wrDecodeFromJSON:json options:options error:&decodeErr];
    
    XCTAssert(a.identifier == 123);
    XCTAssert(a.favorite == YES);
    XCTAssert(a.rating == 5.0);
    XCTAssert([a.onPage isEqualToNumber:@(10)]);
    XCTAssert([a.name isEqualToString:@"Best article"]);
    XCTAssert([a.info isEqualToDictionary:@{@"mail":@"afa.mail.com"}]);
    
    NSDateFormatter *df = [NSDateFormatter new];
    df.dateFormat = WRDefaultDateFormat;
    NSDate *date = [df dateFromString:@"2017-08-02T15:08:25Z"];
    XCTAssert([a.date isEqualToDate:date]);
    
}

- (void)testArticleJsonGeneration {
    
    NSDictionary *json = [Article testJSON];
    /*
     @{@"identifier":@"123",
     @"favorite":@"true",
     @"rating":@"5.0",
     @"onPage":@"10",
     @"name":@"Best article",
     @"info":@{@"mail":@"afa.mail.com"},
     @"date":@"2017-08-02T15:08:25Z"};
     */
    XCTAssert(json != nil);
    
    Article *a = [[Article alloc] initFromJSONObject:json];
    
    XCTAssert(a != nil);
    
    NSDictionary *outJson = [a wrEncodeToJSONObject];
    NSData *data = [NSJSONSerialization dataWithJSONObject:outJson options:0 error:nil];
    outJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    [json enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
       
        id outVal = outJson[key];
        
        if ([obj isKindOfClass:[NSString class]]) {
            
            if ([outVal isKindOfClass:[NSNumber class]]) {
                NSNumberFormatter *f = [NSNumberFormatter new];
                f.numberStyle = NSNumberFormatterDecimalStyle;
                NSNumber *n = [f numberFromString:obj];
                
                if (n) {
                    XCTAssert([n isEqualToNumber:outVal]);
                } else if ([obj isEqualToString:@"false"]
                           || [obj isEqualToString:@"true"]) {
                    
                    XCTAssert([@([(NSString*)obj boolValue]) isEqualToNumber:outVal]);
                }
            } else {
                XCTAssert([obj isEqualToString:[outVal description]]);
            }
        } else if ([obj isKindOfClass:[NSArray class]]) {
            
            XCTAssert([obj isEqualToArray:outVal]);
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            
            XCTAssert([obj isEqualToDictionary:outVal]);
        } else {
            XCTAssert(0);
        }

    }];
    

}

@end

