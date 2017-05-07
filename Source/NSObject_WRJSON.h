//
//  NSObject_WRJSON.h
//  WRService
//
//  Created by Евгений Богомолов on 06/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (WRJSON)

- (NSString *) wrJSONDescription;
- (NSDictionary *) wrEncodeToJSONObject;
- (NSDictionary *) wrEncodeToJSONObjectWithDateFormat:(NSString *)dateFormat;

- (void) wrPlainDecodeFromJSON:(NSDictionary*)json;
- (void) wrPlainDecodeFromJSON:(NSDictionary*)json dateFormat:(NSString*)dateFormat;

+ (NSString *) wrGenerateClass:(NSString*)className fromJSON:(id)jsonObject renamedProperties:(NSDictionary*_Nullable*_Nullable)propMap;
+ (NSString *) wrGenerateClass:(NSString*)className fromJSON:(id)jsonObject renamedProperties:(NSDictionary*_Nullable*_Nullable)propMap dateFormat:(NSString*)dateFormat;

@end

NS_ASSUME_NONNULL_END
