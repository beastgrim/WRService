//
//  WRServiceTests.m
//  WRServiceTests
//
//  Created by FLS on 04/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WRXMLOperation.h"

@interface WRServiceTests : XCTestCase

@end

@implementation WRServiceTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}


- (void)testXMLArray {
    
    
    WRXMLOperation *op = [WRXMLOperation new];
    
    NSString *xmlString = @"<object type=\"array\" elementType=\"Product\" length=\"3\" id=\"0\"> <object type=\"Product\" id=\"1\"> <field name=\"name\" type=\"string\" value=\"Baked beans\" /> <field name=\"price\" type=\"double\" value=\"1.75\" /> <field name=\"grams\" type=\"int\" value=\"250\" /> <field name=\"registered\" type=\"boolean\" value=\"true\" /> <field name=\"category\" type=\"char\" value=\"\\u0042\" /> </object> <object type=\"Product\" id=\"2\"> <field name=\"name\" type=\"string\" value=\"Basmati Rice\" /> <field name=\"price\" type=\"double\" value=\"3.89\" /> <field name=\"grams\" type=\"int\" value=\"750\" /> <field name=\"registered\" type=\"boolean\" value=\"true\" /> <field name=\"category\" type=\"char\" value=\"\\u0052\" /> </object> <object type=\"Product\" id=\"3\"> <field name=\"name\" type=\"string\" value=\"White bread\" /> <field name=\"price\" type=\"double\" value=\"1.06\" /> <field name=\"grams\" type=\"int\" value=\"300\" /> <field name=\"registered\" type=\"boolean\" value=\"false\" /> <field name=\"category\" type=\"char\" value=\"\\u0048\" /> </object> </object>";
    NSData *data = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *result = [op processResult:data];
    
    NSLog(@"Test XML dictionary: %@", result);
}

@end
