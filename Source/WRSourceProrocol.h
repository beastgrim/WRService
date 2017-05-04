//
//  WRSourceProrocol.h
//  WRService
//
//  Created by FLS on 04/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#ifndef WRSourceProrocol_h
#define WRSourceProrocol_h


#import <Foundation/Foundation.h>

@protocol WRSourceProtocol <NSObject>

@required
- (NSURL*)sourceUrl;

@end

#endif /* WRSourceProrocol_h */
