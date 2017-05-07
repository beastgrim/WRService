//
//  NSObject_WRJSON.m
//  WRService
//
//  Created by Евгений Богомолов on 06/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#import "NSObject_WRJSON.h"
#import <objc/runtime.h>

#define DATE_FORMAT @"YYYY-MM-dd'T'HH:mm:ss'Z'"


typedef NS_ENUM(NSInteger, WRPropertyType) {
    WRPropertyTypeUnknown = 0,
    WRPropertyTypeNull,
    WRPropertyTypeObject,
    WRPropertyTypeBool,
    WRPropertyTypeInteger,
    WRPropertyTypeUInteger,
    WRPropertyTypeFloat,
    WRPropertyTypeDouble,
    WRPropertyTypeInt,
    WRPropertyTypeUInt,
    WRPropertyTypeShort,
    WRPropertyTypeUShort,
    WRPropertyTypeChar,
    WRPropertyTypeUChar,
    WRPropertyTypeCharPointer,
    WRPropertyTypeVoidPointer,
    WRPropertyTypeId
};


@implementation NSObject (WRJSON)


#pragma mark - Public

- (NSString *)wrJSONDescription {
    return [NSString stringWithFormat:@"<%@>: %@", NSStringFromClass([self class]), [self wrEncodeToJSONObject]];
}

- (NSDictionary *)wrEncodeToJSONObject {
    return [self wrEncodeToJSONObjectWithDateFormat:DATE_FORMAT];
}

- (NSDictionary *)wrEncodeToJSONObjectWithDateFormat:(NSString *)dateFormat {
    
    NSArray *names = [self _encodedPropertyNames];
    NSDateFormatter *df = [NSDateFormatter new];
    df.dateFormat = dateFormat;
    
    NSDictionary *map = [self mapOfClass];
    BOOL useMappedProperties = map != nil;
    
    NSMutableDictionary *result = [NSMutableDictionary new];
    /* A class for converting JSON to Foundation objects and converting Foundation objects to JSON.
     
     An object that may be converted to JSON must have the following properties:
     - Top level object is an NSArray or NSDictionary
     - All objects are NSString, NSNumber, NSArray, NSDictionary, or NSNull
     - All dictionary keys are NSStrings
     - NSNumbers are not NaN or infinity
     */
    for (NSString *propName in names) {
        id ivar = [self valueForKey:propName];
        NSString *name = propName;
        NSString *replacedName = map[name];
        if (useMappedProperties && replacedName) {
            name = replacedName;
        }
        
        if (ivar == Nil) {
            ivar = [NSNull null];
            
            [result setValue:ivar forKey:name];
            
        } else {
            static NSArray *availableClasses;
            if (availableClasses == nil) {
                availableClasses = [NSArray arrayWithObjects:[NSString class],[NSNumber class],[NSArray class],[NSDictionary class], nil];
            }
            
            BOOL jProperty = NO;
            
            for (Class class in availableClasses) {
                if ([ivar isKindOfClass:class]) {
                    jProperty = YES;
                    break;
                }
            }
            if (jProperty) {
                [result setValue:ivar forKey:name];
            } else if ([ivar isKindOfClass:[NSDate class]]) {
                NSString *dateString = [df stringFromDate:ivar];
                [result setValue:dateString forKey:name];
                
            } else {
                
                NSDictionary *dict = [ivar wrEncodeToJSONObject];
                [result setValue:dict forKey:name];
            }
        }
    }
    
    return result;
}

- (void)wrPlainDecodeFromJSON:(NSDictionary *)json {
    [self wrPlainDecodeFromJSON:json dateFormat:DATE_FORMAT];
}

- (void)wrPlainDecodeFromJSON:(NSDictionary *)json dateFormat:(NSString *)dateFormat {
    
    NSArray *names = [self allPropertyNames];
    NSDateFormatter *df = [NSDateFormatter new];
    df.dateFormat = dateFormat;
    
    NSDictionary *map = [self mapOfClass];
    BOOL useMappedProperties = map != nil;
    
    for (NSString *name in names) {
        NSString *jsonName = name;
        NSString *replacedName = map[name];
        if (useMappedProperties && replacedName) {
            jsonName = replacedName;
        }
        id val = json[jsonName];
        
        NSString *typeName = nil;
        WRPropertyType type = [self propertyType:name typeName:&typeName];
        
        switch (type) {
            case WRPropertyTypeVoidPointer:
            case WRPropertyTypeCharPointer:
                
                NSLog(@"Pointer types unsupported: %@", name);
                break;
                
            case WRPropertyTypeNull:
            case WRPropertyTypeObject:
            case WRPropertyTypeId: {
                
                Class class = NSClassFromString(typeName);
                
                if ([class isSubclassOfClass:[NSDate class]]) {
                    NSDate *date = [df dateFromString:[val description]];
                    [self setValue:date forKey:name];
                } else {
                    [self setValue:val forKey:name];
                }
            } break;
                
            case WRPropertyTypeUInt:
                [self setValue:@([val unsignedIntValue]) forKey:name];
                break;
            case WRPropertyTypeInt:
                [self setValue:@([val intValue]) forKey:name];
                break;
            case WRPropertyTypeDouble:
                [self setValue:@([val doubleValue]) forKey:name];
                break;
            case WRPropertyTypeUShort:
                [self setValue:@([val unsignedShortValue]) forKey:name];
                break;
            case WRPropertyTypeFloat:
                [self setValue:@([val floatValue]) forKey:name];
                break;
            case WRPropertyTypeInteger:
                [self setValue:@([val integerValue]) forKey:name];
                break;
            case WRPropertyTypeUInteger:
                [self setValue:@([val unsignedIntegerValue]) forKey:name];
                break;
            case WRPropertyTypeBool:
                [self setValue:@([val boolValue]) forKey:name];
                break;
            case WRPropertyTypeShort:
                [self setValue:@([val shortValue]) forKey:name];
                break;
            case WRPropertyTypeChar:
            case WRPropertyTypeUChar: {
                NSString *str = val;
                if ([str isKindOfClass:[NSString class]] && str.length) {
                    const char *cStr = [(NSString*)val UTF8String];
                    char c = cStr[0];
                    [self setValue:@(c) forKey:name];
                } else if ([val isKindOfClass:[NSNumber class]]) {
                    [self setValue:val forKey:name];
                }
            } break;
                
            case WRPropertyTypeUnknown:
                NSLog(@"ERROR: unimplemeted primitive type to decode: %@!", typeName);
                break;
        }
        
    }
}

+ (NSString *)wrGenerateClass:(NSString *)className fromJSON:(nonnull id)jsonObject renamedProperties:(NSDictionary *__autoreleasing  _Nullable * _Nullable)propMap {
    return [NSObject wrGenerateClass:className fromJSON:jsonObject renamedProperties:propMap dateFormat:DATE_FORMAT];
}

+ (NSString *)wrGenerateClass:(NSString *)className fromJSON:(id)jsonObject renamedProperties:(NSDictionary *__autoreleasing  _Nullable * _Nullable)propMap dateFormat:(nonnull NSString *)dateFormat {
    NSDictionary *map = @{@"description":@"desc"};
    return [NSObject wrGenerateClass:className fromJSON:jsonObject dateFormat:dateFormat mappedProperties:map renamedProperties:propMap];
}

+ (NSString *)wrGenerateClass:(NSString *)className fromJSON:(id)jsonObject dateFormat:(nonnull NSString *)dateFormat mappedProperties:(NSDictionary*)map renamedProperties:(NSDictionary *__autoreleasing  _Nullable * _Nullable)propMap {
    
    NSDictionary *json = nil;
    
    if ([jsonObject isKindOfClass:[NSArray class]]) {
        NSDictionary *j = [jsonObject firstObject];
        if ([j isKindOfClass:[NSDictionary class]]) {
            json = j;
        }
    } else if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        json = jsonObject;
    }
    
    if (json == nil) return @"";
    NSLog(@"[WRService]: Generating class from JSON:\n%@\n\n", json);

    NSDateFormatter *df = [NSDateFormatter new];
    df.dateFormat = dateFormat;

    NSMutableDictionary <NSString*,NSString*> *otherClasses = [NSMutableDictionary new];
    NSMutableDictionary *arrayProperties = [NSMutableDictionary new];
    NSMutableDictionary <NSString*,NSString*> *changedProps = [NSMutableDictionary new];

    
    NSMutableString *properties = [NSMutableString new];
    
    [json enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        NSString *replacedPropName = [map valueForKey:[key lowercaseString]];
        if (replacedPropName) {
            [changedProps setValue:key forKey:replacedPropName];
            key = replacedPropName;
        }
        
        if ([obj isKindOfClass:[NSDictionary class]]) {
            
            NSString *className = [key capitalizedString];
            NSString *propName = [key lowercaseString];
            
            if (![self _isValidClassName:className]) {
                NSString *validClassName = [self _validClassNameFromString:className];
                [changedProps setValue:className forKey:validClassName];
                className = validClassName;
            }
            
            NSDictionary *subChanges = nil;
            NSString *classInterface = [NSObject wrGenerateClass:className fromJSON:obj renamedProperties:&subChanges];
            if (subChanges) {
                [changedProps addEntriesFromDictionary:subChanges];
            }
            [otherClasses setObject:classInterface forKey:className];
            [properties appendFormat:@"@property (nonatomic, strong) %@ *%@;\n", className, propName];
            
//            if ([self _isValidClassName:className]) {
//                NSDictionary *subChanges = nil;
//                NSString *classInterface = [NSObject wrGenerateClass:className fromJSON:obj renamedProperties:&subChanges];
//                if (subChanges) {
//                    [changedProps addEntriesFromDictionary:subChanges];
//                }
//                [otherClasses setObject:classInterface forKey:className];
//                [properties appendFormat:@"@property (nonatomic, strong) %@ *%@;\n", className, propName];
//            } else {
//                NSString *validClassName = [self _validClassNameFromString:className];
//                [changedProps setValue:className forKey:validClassName];
//                [properties appendFormat:@"@property (nonatomic, strong) NSDictionary *%@;\n", validClassName];
//            }

        
        } else if ([obj isKindOfClass:[NSArray class]]) {
            
            id item = [obj firstObject];
            if (item) {
                if ([item isKindOfClass:[NSString class]]) {
                    [arrayProperties setObject:NSStringFromClass([NSString class]) forKey:key];
                } else if ([item isKindOfClass:[NSArray class]]) {
                    [arrayProperties setObject:NSStringFromClass([NSArray class]) forKey:key];
                } else if ([item isKindOfClass:[NSDictionary class]]) {
                    [arrayProperties setObject:NSStringFromClass([NSDictionary class]) forKey:key];
                }
            } else {
                [arrayProperties setObject:[NSNull null] forKey:key];
            }
            
        } else {
            
            WRPropertyType type = [self _propertyTypeForValue:obj];
            
            switch (type) {
                case WRPropertyTypeNull: {
                    [properties appendFormat:@"@property (nonatomic, copy) id %@;\n", key];
                } break;
                case WRPropertyTypeObject: {
                    BOOL isDate = [obj isKindOfClass:[NSString class]] && [df dateFromString:obj];
                    if (isDate) {
                        [properties appendFormat:@"@property (nonatomic, copy) NSDate *%@;\n", key];
                    } else {
                        [properties appendFormat:@"@property (nonatomic, copy) NSString *%@;\n", key];
                    }
                } break;
                    
                case WRPropertyTypeBool: {
                    [properties appendFormat:@"@property (nonatomic, assign) BOOL %@;\n", key];
                } break;
                    
                case WRPropertyTypeInteger: {
                    [properties appendFormat:@"@property (nonatomic, assign) NSInteger %@;\n", key];
                } break;
                    
                case WRPropertyTypeFloat: {
                    [properties appendFormat:@"@property (nonatomic, assign) float %@;\n", key];
                } break;
                    
                case WRPropertyTypeDouble: {
                    [properties appendFormat:@"@property (nonatomic, assign) double %@;\n", key];
                } break;
                    
                case WRPropertyTypeShort: {
                    [properties appendFormat:@"@property (nonatomic, assign) short %@;\n", key];
                } break;
                    
                default:
                    NSLog(@"Unexpected type while generate class: %@, value: %@", className, obj);
                    break;
            }
            
        }

    }];
    

    
    NSMutableString *result = [NSMutableString stringWithFormat:@"\n\n\n"];
    
    NSString *additionalClassNames = [[otherClasses allKeys] componentsJoinedByString:@", "];
    if (otherClasses.count) {
        [result appendFormat:@"@class %@;", additionalClassNames];
    }

    [result appendFormat:@"\n\n\n@interface %@ : NSObject <WRObjectOperationProtocol>\n\n", className];
    [result appendFormat:@"%@", properties];
    [result appendFormat:@"\n\n@end\n"];
    
    [otherClasses enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull key, NSString*  _Nonnull interface, BOOL * _Nonnull stop) {
        [result appendFormat:@"%@", interface];
    }];
    
    // Create implementation
    [result appendFormat:@"\n\n\n\n@implementation %@\n\n\
- (instancetype)initFromJSONObject:(id)jsonObject {\n\n\
    if (self = [super init]) {\n\
        [self wrPlainDecodeFromJSON:jsonObject];\n\
    }\n\
    return self;\n\
}\n\n@end", className ];
    
    
    if (changedProps.count && propMap) {
        *propMap = changedProps;
    }
    
    return result;
}


#pragma mark - Helpers

- (NSDictionary * __nullable) mapOfClass {
    NSString *mapPath = [[NSBundle mainBundle] pathForResource:NSStringFromClass([self class]) ofType:@"map"];
    NSDictionary *map = nil;
    if (mapPath) {
        NSData *jsonData = [NSData dataWithContentsOfFile:mapPath];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
        if (json && [json isKindOfClass:[NSDictionary class]]) {
            map = json[@"map"];
            return map;
        }
    }
    return nil;
}

- (NSArray *)allPropertyNames {
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    NSMutableArray *rv = [NSMutableArray array];
    
    unsigned i;
    for (i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        
        if ([name isEqualToString:@"hash"]) {
            break;
        }
        [rv addObject:name];
    }
    
    free(properties);
    
    return rv;
}

- (NSArray*) _encodedPropertyNames {
    
    NSArray *properties = [self allPropertyNames];
    NSMutableArray *result = [NSMutableArray new];
    
    for (NSString *name in properties) {
        if ([self _isPropertySupportDecode:name]) {
            [result addObject:name];
        }
    }
    
    return result;
}

- (BOOL) _isPropertySupportDecode:(NSString*)name {

    WRPropertyType type = [self propertyType:name typeName:nil];
    
    switch (type) {
        case WRPropertyTypeObject:
        case WRPropertyTypeId:
        case WRPropertyTypeInt:
        case WRPropertyTypeUInt:
        case WRPropertyTypeFloat:
        case WRPropertyTypeShort:
        case WRPropertyTypeUShort:
        case WRPropertyTypeInteger:
        case WRPropertyTypeUInteger:
        case WRPropertyTypeChar:
            
            return YES;
            break;
            
        default:
            return NO;
            break;
    }
}

+ (BOOL) _isValidClassName:(NSString*)className {
    static NSCharacterSet *set; if (!set) set = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    NSRange range = [className rangeOfCharacterFromSet:set];
    
    return range.location == NSNotFound;
}

+ (NSString*) _validClassNameFromString:(NSString*)inName {
    static NSCharacterSet *set; if (!set) set = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    NSString *result = [[inName componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@"_"];
    return result;
}

- (WRPropertyType) propertyType:(NSString*)name typeName:(NSString**)typeName {
    
    objc_property_t theProperty = class_getProperty([self class], name.UTF8String);
    const char * propertyAttrs = property_getAttributes(theProperty);
    NSString *fullType = [NSString stringWithFormat:@"%s", propertyAttrs];
    
    NSRange range = [fullType rangeOfString:@","];
    NSString *type = nil;
    if (range.location != NSNotFound) {
        type = [fullType substringWithRange:NSMakeRange(1, range.location-1)];
        

        if ([type hasPrefix:@"@\""]) {  // object types
            
            if (typeName) {
                NSString *className = [type substringWithRange:NSMakeRange(2, type.length-3)];
                *typeName = className;
            }
            return WRPropertyTypeObject;
            
        } else {    // primitive types
            
            if (typeName) {
                *typeName = type;
            }
            if ([type isEqualToString:@"B"]) {
                return WRPropertyTypeBool;
            } else if ([type isEqualToString:@"Q"]) {
                return WRPropertyTypeUInteger;
            } else if ([type isEqualToString:@"q"]) {
                return WRPropertyTypeInteger;
            } else if ([type isEqualToString:@"f"]) {
                return WRPropertyTypeFloat;
            } else if ([type isEqualToString:@"s"]) {
                return WRPropertyTypeShort;
            } else if ([type isEqualToString:@"S"]) {
                return WRPropertyTypeUShort;
            } else if ([type isEqualToString:@"d"]) {
                return WRPropertyTypeDouble;
            } else if ([type isEqualToString:@"i"]) {
                return WRPropertyTypeInt;
            } else if ([type isEqualToString:@"I"]) {
                return WRPropertyTypeUInt;
            } else if ([type isEqualToString:@"c"]) {
                return WRPropertyTypeChar;
            } else if ([type isEqualToString:@"C"]) {
                return WRPropertyTypeUChar;
            } else if ([type isEqualToString:@"*"]) {
                return WRPropertyTypeCharPointer;
            } else if ([type isEqualToString:@"^v"]) {
                return WRPropertyTypeVoidPointer;
            } else if ([type isEqualToString:@"@"]) {
                return WRPropertyTypeId;
            } else {
                NSLog(@"ERROR: unimplemeted primitive type to decode!");
                return WRPropertyTypeUnknown;
            }
        }
    }
    
    return WRPropertyTypeUnknown;
}

+ (WRPropertyType) _propertyTypeForValue:(id)value {
    
    if ([value isKindOfClass:[NSString class]]) {
        
        NSString *str = [value lowercaseString];
        
        static NSCharacterSet *numberSet;
        if (!numberSet) numberSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        
        NSRange range = [str rangeOfCharacterFromSet:numberSet];
        
        if (range.location != NSNotFound) {     // String
            
            if ([str isEqualToString:@"yes"] ||
                [str isEqualToString:@"no"] ||
                [str isEqualToString:@"true"] ||
                [str isEqualToString:@"false"] ||
                [str isEqualToString:@"y"] ||
                [str isEqualToString:@"n"]) {
                
                return WRPropertyTypeBool;
            }
            return WRPropertyTypeObject;
        } else {                                // primitive value
            
            NSUInteger length = str.length;
            if (length == 0) {
                return WRPropertyTypeObject;
            } else if (length < 4) {
                return WRPropertyTypeShort;
            } else if (length < 2 && [str intValue] < 2 && [str intValue] > 0) {
                return WRPropertyTypeBool;
            }
            return WRPropertyTypeInteger;
        }
        
    } else if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber *num = value;
        
        CFNumberType numberType = CFNumberGetType((CFNumberRef)num);

        switch (numberType) {
            case kCFNumberSInt8Type:
            case kCFNumberCharType:
            case kCFNumberShortType:
                return WRPropertyTypeShort;
                break;
                
            case kCFNumberIntType:
            case kCFNumberSInt16Type:
            case kCFNumberSInt32Type:
                return WRPropertyTypeInt;
                break;
                
            case kCFNumberNSIntegerType:
            case kCFNumberLongType:
            case kCFNumberMaxType:
            case kCFNumberSInt64Type:
                return WRPropertyTypeInteger;
                break;
                
            case kCFNumberDoubleType:
            case kCFNumberFloat64Type:
                return WRPropertyTypeDouble;
                break;
                
            case kCFNumberFloatType:
            case kCFNumberFloat32Type:
                return WRPropertyTypeFloat;
                break;
                
            default:
                return WRPropertyTypeInteger;
                break;
        }
        
    } else if ([value isKindOfClass:[NSNull class]]) {
        return WRPropertyTypeNull;
    }
    return WRPropertyTypeUnknown;
}


@end