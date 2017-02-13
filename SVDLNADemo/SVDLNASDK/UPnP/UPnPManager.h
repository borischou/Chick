//
//  UPnPManager.h
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/8.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPnPActionRequest.h"
#import "UPnPManager.h"
#import "Device.h"
#import "DeviceDescription.h"
#import "ServiceDescription.h"
#import "UPnPActionResponse.h"

@class UPnPManager;

@protocol UPnPSSDPDataDelegate <NSObject>

@optional
- (void)uPnpManagerDidSendData:(UPnPManager *)manager;
- (void)uPnpManager:(UPnPManager *)manager didNotSendDataDueToError:(NSError *)error;
- (void)uPnpManager:(UPnPManager *)manager didDiscoverDevice:(Device *)device;

@end

@protocol UPnPControlPointDelegate <NSObject>

@optional
- (void)uPnpManager:(UPnPManager * _Nullable)manager didGetTransportInfoResponse:(UPnPActionResponse * _Nullable)response;
- (void)uPnpManager:(UPnPManager * _Nullable)manager didGetPositionInfoResponse:(UPnPActionResponse * _Nullable)response;
- (void)uPnpManager:(UPnPManager * _Nullable)manager didPlayResponse:(UPnPActionResponse * _Nullable)response;
- (void)uPnpManager:(UPnPManager * _Nullable)manager didPauseResponse:(UPnPActionResponse * _Nullable)response;
- (void)uPnpManager:(UPnPManager * _Nullable)manager didStopResponse:(UPnPActionResponse * _Nullable)response;
- (void)uPnpManager:(UPnPManager * _Nullable)manager didSeekTo:(NSString *)target response:(UPnPActionResponse *)response;
- (void)uPnpManager:(UPnPManager * _Nullable)manager didSetAVTransportURI:(NSString * _Nullable)uri response:(UPnPActionResponse * _Nullable)response;
- (void)uPnpManager:(UPnPManager * _Nullable)manager didSetNextAVTransportURI:(NSString * _Nullable)uri response:(UPnPActionResponse * _Nullable)response;

@end

@interface UPnPManager : NSObject

@property (strong, nonatomic) UPnPActionRequest * _Nullable request;

+ (_Nullable instancetype)sharedManager;

- (_Nullable instancetype)initWithRequest:(UPnPActionRequest * _Nullable)request;

- (void)setRequest:(UPnPActionRequest * _Nullable)request;

- (void)setService:(Service *)service;

- (void)setAddress:(Address *)address;

- (void)searchDevice;

- (void)subscribeEventNotificationFromDeviceAddress:(Address *)address service:(Service *)service;

- (void)subscribeEventNotificationFromDeviceAddress:(Address *)address service:(Service *)service response:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))responseBlock;

@property (weak, nonatomic) id <UPnPControlPointDelegate> _Nullable controlPointDelegate;
@property (weak, nonatomic) id <UPnPSSDPDataDelegate> ssdpDataDelegate;

@end

typedef void(^successHandler)(NSData * _Nullable data);
typedef void(^failureHandler)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

typedef void(^DDDHandler)(DeviceDescription * _Nullable ddd);
typedef void(^SDDHandler)(ServiceDescription * _Nullable sdd);

@interface UPnPManager (Connection)

- (void)fetchDDDWithLocation:(NSString * _Nullable)location successHandler:(DDDHandler _Nullable)dddBlk failureHandler:(failureHandler _Nullable)failBlk;
- (void)fetchSDDWithLocation:(NSString * _Nullable)location successHandler:(SDDHandler _Nullable)dddBlk failureHandler:(failureHandler _Nullable)failBlk;

@end

typedef void(^ActionResponseHandler)(UPnPActionResponse * _Nullable actionResponse, NSURLResponse * _Nullable response, NSError * _Nullable error);

@interface UPnPManager (ControlPoint)

- (void)setAVTransportURI:(NSString * _Nullable)uri response:(ActionResponseHandler _Nullable)responseHandler;

- (void)playWithResponse:(ActionResponseHandler)responseHandler;

- (void)pauseWithResponse:(ActionResponseHandler)responseHandler;

- (void)stopWithResponse:(ActionResponseHandler)responseHandler;

- (void)getTransportInfo:(ActionResponseHandler)responseHandler;

- (void)getPositionInfo:(ActionResponseHandler)responseHandler;

- (void)seekTo:(NSString *)target response:(ActionResponseHandler)responseHandler;

- (void)getCurrentTransportActions:(ActionResponseHandler)responseHandler;

@end
