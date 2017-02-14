//
//  UPnPManager.h
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/8.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SVDLNA/Service.h>
#import <SVDLNA/Device.h>

static NSString *const UPnPVideoStateChangedNotification;

typedef NS_ENUM(NSInteger, UPnPEventTransportState)
{
    UPnPEventTransportStateUnknown,
    UPnPEventTransportStatePlaying,
    UPnPEventTransportStatePaused,
    UPnPEventTransportStateStopped,
    UPnPEventTransportStateTransitioning
};

@interface UPnPActionResponse : NSObject

@property (assign, nonatomic) NSInteger statusCode;
@property (copy, nonatomic) NSString *respMsg;
@property (copy, nonatomic) NSString *errorCode;
@property (copy, nonatomic) NSString *errorDescription;
@property (copy, nonatomic) NSArray<Action *> *actions;
@property (copy, nonatomic) NSDictionary *xmlDictionary;

- (instancetype)initWithData:(NSData *)data;

@end

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

@property (strong, nonatomic, readonly) Device *device;

@property (strong, nonatomic, readonly) Service *service;

+ (_Nullable instancetype)sharedManager;

- (void)setService:(Service *)service;

- (void)setDevice:(Device *)device;

- (void)searchDevice;

- (void)subscribeEventNotificationFromDevice:(Device *)device service:(Service *)service;

- (void)subscribeEventNotificationFromDevice:(Device *)device service:(Service *)service response:(void (^)(NSString * _Nullable subscribeID, NSURLResponse * _Nullable response, NSError * _Nullable error))responseBlock;

@property (weak, nonatomic) id <UPnPControlPointDelegate> _Nullable controlPointDelegate;
@property (weak, nonatomic) id <UPnPSSDPDataDelegate> ssdpDataDelegate;

@end

typedef void(^successHandler)(NSData * _Nullable data);
typedef void(^failureHandler)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

typedef void(^DDDHandler)(DeviceDescription * _Nullable ddd);
typedef void(^SDDHandler)(ServiceDescription * _Nullable sdd);

@interface UPnPManager (Connection)

- (void)fetchDDDSuccessHandler:(DDDHandler _Nullable)dddBlk failureHandler:(failureHandler _Nullable)failBlk;

- (void)fetchSDDSuccessHandler:(SDDHandler _Nullable)dddBlk failureHandler:(failureHandler _Nullable)failBlk;

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
