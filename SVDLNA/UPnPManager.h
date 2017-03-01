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

static NSString *const UPnPVideoStateChangedNotification;   //视频播放状态改变通知

typedef NS_ENUM(NSInteger, UPnPEventTransportState)         //视频播放状态枚举
{
    UPnPEventTransportStateUnknown,
    UPnPEventTransportStatePlaying,
    UPnPEventTransportStatePaused,
    UPnPEventTransportStateStopped,
    UPnPEventTransportStateTransitioning
};

/**
 upnp动作请求响应类
 */
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

/**
 SSDP搜索设备请求响应代理
 */
@protocol UPnPSSDPDataDelegate <NSObject>

@optional

- (void)uPnpManagerDidSendData:(UPnPManager *)manager;

- (void)uPnpManager:(UPnPManager *)manager didNotSendDataDueToError:(NSError *)error;

- (void)uPnpManager:(UPnPManager *)manager didDiscoverDevice:(Device *)device;

@end

/**
 upnp控制请求响应代理
 */
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

- (void)uPnpManager:(UPnPManager *)manager didGetCurrentTransportActionsResponse:(UPnPActionResponse *)response;

- (void)uPnpManager:(UPnPManager *)manager didSetVolume:(NSString *)volume response:(UPnPActionResponse *)response;

@end

/**
 DLNA主管理类，负责搜索、订阅、控制的请求调用
 */
@interface UPnPManager : NSObject


/**
 当前设备
 */
@property (strong, nonatomic, readonly) Device *device;


/**
 当前服务
 */
@property (strong, nonatomic, readonly) Service *service;

/**
 全局共享管理类

 @return 管理类单例
 */
+ (_Nullable instancetype)sharedManager;

/**
 设置当前服务

 @param service 当前服务实例
 */
- (void)setService:(Service *)service;

/**
 设置当前连接的设备

 @param device 当前设备实例
 */
- (void)setDevice:(Device *)device;

/**
 搜索设备
 */
- (void)searchDevice;

/**
 订阅AVTransport服务的状态响应通知
 */
- (void)subscribeEventNotificationForAVTransport;

/**
 订阅AVTransport服务的状态响应通知

 @param responseBlock 回调闭包，可保存订阅ID用于请求续订
 */
- (void)subscribeEventNotificationForAVTransportResponse:(void (^)(NSString * _Nullable subscribeID, NSURLResponse * _Nullable response, NSError * _Nullable error))responseBlock;

/**
 订阅指定服务的状态响应通知

 @param service 指定的服务实例
 @param responseBlock 回调闭包
 */
- (void)subscribeEventNotificationForService:(Service *)service response:(void (^)(NSString * _Nullable subscribeID, NSURLResponse * _Nullable response, NSError * _Nullable error))responseBlock;

@property (weak, nonatomic) id <UPnPControlPointDelegate> _Nullable controlPointDelegate;

@property (weak, nonatomic) id <UPnPSSDPDataDelegate> ssdpDataDelegate;

@end

typedef void(^successHandler)(NSData * _Nullable data);
typedef void(^failureHandler)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

typedef void(^DDDHandler)(DeviceDescription * _Nullable ddd);
typedef void(^SDDHandler)(ServiceDescription * _Nullable sdd);

@interface UPnPManager (Connection)

/**
 请求设备描述文档
 */
- (void)fetchDDDSuccessHandler:(DDDHandler _Nullable)dddBlk failureHandler:(failureHandler _Nullable)failBlk;

/**
 请求服务描述文档
 */
- (void)fetchSDDSuccessHandler:(SDDHandler _Nullable)sddBlk failureHandler:(failureHandler _Nullable)failBlk;

@end

typedef void(^ActionResponseHandler)(UPnPActionResponse * _Nullable actionResponse, NSURLResponse * _Nullable response, NSError * _Nullable error);

@interface UPnPManager (ControlPoint)

#pragma mark - AVTransport

/**
 设置当前播放的网络视频URI

 @param uri 视频地址
 @param responseHandler
 */
- (void)setAVTransportURI:(NSString * _Nullable)uri response:(ActionResponseHandler _Nullable)responseHandler;

/**
 设置下一个联播视频URI

 @param uri 下一个视频地址
 @param responseHandler
 */
- (void)setNextAVTransportURI:(NSString *)uri response:(ActionResponseHandler)responseHandler;

/**
 请求播放视频
 */
- (void)playWithResponse:(ActionResponseHandler)responseHandler;

/**
 请求暂停视频
 */
- (void)pauseWithResponse:(ActionResponseHandler)responseHandler;

/**
 请求停止视频
 */
- (void)stopWithResponse:(ActionResponseHandler)responseHandler;

/**
 请求视频播放状态
 */
- (void)getTransportInfo:(ActionResponseHandler)responseHandler;

/**
 请求视频播放时间戳
 */
- (void)getPositionInfo:(ActionResponseHandler)responseHandler;

/**
 请求从指定时间点播放视频

 @param target 播放开始时间点，如"00:12:15"
 */
- (void)seekTo:(NSString *)target response:(ActionResponseHandler)responseHandler;

/**
 请求当前服务可调用的动作
 */
- (void)getCurrentTransportActions:(ActionResponseHandler)responseHandler;

#pragma mark - RenderingControl

/**
 请求设置当前音量（绝对值）

 @param volume 当前音量
 */
- (void)setVolume:(NSString *)volume response:(ActionResponseHandler)responseHandler;

@end
