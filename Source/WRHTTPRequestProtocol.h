//
//  WRHTTPRequestProtocol.h
//  WRService
//
//  Created by FLS on 05/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

#ifndef WRHTTPRequestProtocol_h
#define WRHTTPRequestProtocol_h


@protocol WRHttpRequestProtocol <NSObject>

@required
@property NSTimeInterval timeoutInterval;

@end

#endif /* WRHTTPRequestProtocol_h */
