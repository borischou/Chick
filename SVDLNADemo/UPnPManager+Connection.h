//
//  UPnPManager+Connection.h
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/8.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "UPnPManager.h"
#import "DeviceDescription.h"
#import "ServiceDescription.h"

typedef void(^successHandler)(NSData * _Nullable data);
typedef void(^failureHandler)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

typedef void(^DDDHandler)(DeviceDescription * _Nullable ddd);
typedef void(^SDDHandler)(ServiceDescription * _Nullable sdd);

@interface UPnPManager (Connection)

- (void)fetchDDDWithLocation:(NSString * _Nullable)location successHandler:(DDDHandler _Nullable)dddBlk failureHandler:(failureHandler _Nullable)failBlk;
- (void)fetchSDDWithLocation:(NSString * _Nullable)location successHandler:(SDDHandler _Nullable)dddBlk failureHandler:(failureHandler _Nullable)failBlk;

@end
