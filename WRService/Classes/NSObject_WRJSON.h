//
//  NSObject_WRJSON.h
//  WRService
//
//  Created by Евгений Богомолов on 06/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString * const WRKey;

extern WRKey WRDefaultDateFormat;
extern WRKey WRErrorDomain;

extern WRKey WRDateFormatKey;
extern WRKey WRDictOfClassKey;
extern WRKey WRClassNameKey;
extern WRKey WRClassPropertyNameForDictKey;

/**
 @brief Use this key for decoding when json keys not the same that Class properties names.
 Value is NSDictionary <ClassPropertyName: JSONKey>
 */
extern NSString * const WRPropertyNamesMapKey;

/**
 @brief Use this for decoding Class with required properties. If JSON doesn't have this key -wrDecodeFromJSON:options:error: return an error. Value is NSSet of strings.
 */
extern NSString * const WRRequiredPropertiesKey;


@interface NSObject (WRJSON)

- (NSString *) wrJSONDescription;
- (NSDictionary *) wrEncodeToJSONObject;
- (NSDictionary *) wrEncodeToJSONObjectWithDateFormat:(NSString *)dateFormat;
- (NSDictionary *) wrEncodeToJSONObjectWithOptions:(NSDictionary*_Nullable)options error:(NSError *_Nullable*_Nullable)error;

- (void) wrPlainDecodeFromJSON:(NSDictionary*)json;
- (void) wrPlainDecodeFromJSON:(NSDictionary*)json dateFormat:(NSString*)dateFormat;
- (void) wrDecodeFromJSON:(NSDictionary*)json options:(NSDictionary*_Nullable)options;
- (BOOL) wrDecodeFromJSON:(NSDictionary*)json options:(NSDictionary*_Nullable)options error:(NSError *_Nullable*_Nullable)error;

+ (NSString *) wrGenerateClass:(NSString*)className fromJSON:(id)jsonObject renamedProperties:(NSDictionary *_Nullable*_Nullable)propMap;
+ (NSString *) wrGenerateClass:(NSString*)className fromJSON:(id)jsonObject renamedProperties:(NSDictionary *_Nullable*_Nullable)propMap options:(NSDictionary*)options;

@end

NS_ASSUME_NONNULL_END
