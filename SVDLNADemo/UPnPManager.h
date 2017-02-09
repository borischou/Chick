//
//  UPnPManager.h
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/8.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Address.h"
#import "Service.h"
#import "UPnPActionRequest.h"

@class UPnPManager;
@protocol UPnPControlPointDelegate <NSObject>

@optional
- (void)uPnpManager:(UPnPManager * _Nullable)manager didGetTransportInfoResponse:(UPnPActionResponse * _Nullable)response;
- (void)uPnpManager:(UPnPManager * _Nullable)manager didGetPositionInfoResponse:(UPnPActionResponse * _Nullable)response;
- (void)uPnpManager:(UPnPManager * _Nullable)manager didSetAVTransportURI:(NSString * _Nullable)uri response:(UPnPActionResponse * _Nullable)response;
- (void)uPnpManager:(UPnPManager * _Nullable)manager didPlayResponse:(UPnPActionResponse * _Nullable)response;
- (void)uPnpManager:(UPnPManager * _Nullable)manager didPauseResponse:(UPnPActionResponse * _Nullable)response;
- (void)uPnpManager:(UPnPManager * _Nullable)manager didStopResponse:(UPnPActionResponse * _Nullable)response;

@end

@interface UPnPManager : NSObject

@property (strong, nonatomic) UPnPActionRequest * _Nullable request;

+ (_Nullable instancetype)sharedManager;

- (_Nullable instancetype)initWithRequest:(UPnPActionRequest * _Nullable)request;

- (void)setRequest:(UPnPActionRequest * _Nullable)request;

@property (weak, nonatomic) id <UPnPControlPointDelegate> _Nullable controlPointDelegate;

@end
