//
//  WRXMLOperation.m
//  WRService
//
//  Created by FLS on 05/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#import "WRXMLOperation.h"

@interface WRXMLOperation() <NSXMLParserDelegate>

@end

@implementation WRXMLOperation {
    
    dispatch_group_t _waiter;
    NSError *_xmlParserError;
    NSMutableDictionary * _xmlParseResult;
    NSMutableArray *_stackableArray;
    NSString * _xmlValue;
}


- (id)processResult:(id)result {
    result = [super processResult:result];
    
    if (![result isKindOfClass:[NSData class]]) return nil;

    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:result];
    parser.delegate = self;
    parser.shouldProcessNamespaces = YES;
    _xmlParseResult = [NSMutableDictionary new];
    _stackableArray = [NSMutableArray new];
    
    _waiter = dispatch_group_create();
    dispatch_group_enter(_waiter);
    [parser parse];
    
    dispatch_group_wait(_waiter, DISPATCH_TIME_FOREVER);    

    if (_xmlParserError) {
        return _xmlParserError;
    }
    NSLog(@"XML result: %@", _xmlParseResult);
    return _xmlParseResult;
}

#pragma mark - Private

- (void)pushTag:(NSString*)string {
    [_stackableArray addObject:string];
}

- (NSString*) popTag {
    if (_stackableArray.count) {
        NSString *tag = [_stackableArray lastObject];
        [_stackableArray removeLastObject];
        return tag;
    }
    return nil;
}

- (NSString*) tag {
    return _stackableArray.lastObject;
}


#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
    NSLog(@"foundCDATA: %@", CDATABlock);
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    dispatch_group_leave(_waiter);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(nonnull NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(nonnull NSDictionary<NSString *,NSString *> *)attributeDict {
    
    NSLog(@"didStartElement: %@, attributes: %@, qualifedName: %@", elementName, attributeDict, qName);
    
    if (_xmlValue == nil) {
        [_xmlParseResult setObject:[NSMutableDictionary new] forKey:elementName];
    }
    [self pushTag:elementName];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    NSLog(@"foundCharacters: %@", string);
    _xmlValue = string;
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    NSLog(@"didEndElement: %@, qualifedName: %@, nameSpace: %@", elementName, qName, namespaceURI);
    NSString *tag = [self popTag];
    
    if (_xmlValue) {
        
        NSMutableDictionary *dict = [_xmlParseResult objectForKey:tag];
//        if (dict == nil) {
//            dict = [NSMutableDictionary dictionaryWithObject:_xmlValue forKey:tag];
//        }
        [dict setObject:_xmlValue forKey:tag];
        _xmlValue = nil;
    }
//    else {
//        NSMutableDictionary *dict = [NSMutableDictionary new];
//        [_xmlParseResult setObject:dict forKey:elementName];
//    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"parseErrorOccurred: %@", parseError);
    _xmlParserError = parseError;
    dispatch_group_leave(_waiter);
}

@end
