//
//  UPnPManager+ControlPoint.h
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/8.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "UPnPManager.h"

typedef void(^successHandler)(NSData * _Nullable data);
typedef void(^failureHandler)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);
typedef void(^completionHandler)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

@interface UPnPManager (ControlPoint)

- (void)setAVTransportURI:(NSString * _Nullable)uri completion:(completionHandler _Nullable)completion;

- (void)playCompletion:(completionHandler _Nullable)completion;

@end
