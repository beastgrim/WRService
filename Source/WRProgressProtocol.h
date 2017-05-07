//
//  WRProgressProtocol.h
//  WRService
//
//  Created by FLS on 04/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#ifndef WRProgressProtocol_h
#define WRProgressProtocol_h

@class WROperation;

@protocol WRProgressProtocol <NSObject>

@optional
- (void) operation:(WROperation*)op didChangeProgress:(float)progress;

@end


#endif /* WRProgressProtocol_h */
