//
//  UPnPManager+ControlPoint.h
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/8.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "UPnPManager.h"
#import "UPnPActionResponse.h"

typedef void(^ActionResponseHandler)(UPnPActionResponse * _Nullable actionResponse, NSURLResponse * _Nullable response, NSError * _Nullable error);

@interface UPnPManager (ControlPoint)

- (void)setAVTransportURI:(NSString * _Nullable)uri response:(ActionResponseHandler _Nullable)responseHandler;

- (void)playWithResponse:(ActionResponseHandler)responseHandler;

- (void)pauseWithResponse:(ActionResponseHandler)responseHandler;

- (void)stopWithResponse:(ActionResponseHandler)responseHandler;

- (void)getTransportInfo:(ActionResponseHandler)responseHandler;

- (void)getPositionInfo:(ActionResponseHandler)responseHandler;

- (void)seekTo:(NSString *)target response:(ActionResponseHandler)responseHandler;

@end
