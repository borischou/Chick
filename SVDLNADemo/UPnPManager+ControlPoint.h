//
//  UPnPManager+ControlPoint.h
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/8.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "UPnPManager.h"
#import "UPnPActionResponse.h"

@interface UPnPManager (ControlPoint)

- (void)setAVTransportURI:(NSString * _Nullable)uri response:(actionResponseHandler _Nullable)responseHandler;

- (void)playWithResponse:(actionResponseHandler _Nullable)responseHandler;

- (void)pauseWithResponse:(actionResponseHandler _Nullable)responseHandler;

- (void)stopWithResponse:(actionResponseHandler _Nullable)responseHandler;

- (void)getTransportInfo:(actionResponseHandler _Nullable)responseHandler;

- (void)getPositionInfo:(actionResponseHandler _Nullable)responseHandler;

@end
