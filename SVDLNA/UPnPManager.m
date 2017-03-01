//
//  UPnPManager.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/8.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "UPnPManager.h"
#import "GCDAsyncUdpSocket.h"
#import "GCDWebServer.h"
#import "GCDWebServerDataRequest.h"
#import "GCDWebServerDataResponse.h"
#import "XMLDictionary.h"
#import "UPnPActionRequest.h"

#define LOCAL_UDP_PORT    0         //本地UDP端口 0:系统随机分配 可防止冲突 建议不要修改
#define LOCAL_SERVER_PORT 10190     //本地服务器TCP端口

//SSDP M-SEARCH Header
#define SSDP_MULTICAST_HOST_IP          @"239.255.255.250"  //默认组网IP 请勿修改
#define SSDP_MULTICAST_HOST_PORT        1900                //默认组网端口 请勿修改
#define TIMEOUT                         -1                  //过期时间 -1:无限
#define USER_AGENT @"Sohu TV iOS DLNA Test"                 //可增加CP版本信息等
#define MAN                             @"ssdp:discover"    //默认搜索模式 请勿修改
#define MX                              @"1"                //随机接收时间最大值
#define ST                              UPNP_ROOT_DEVICE    //搜索设备类型
#define CONNECTION                      @"close"            //连接状态 Keep-Alive:保持 close:不保持

//SSDP DEVICE
#define UPNP_ALL                        @"ssdp:all"                                             //所有支持DLNA的智能设备
#define UPNP_ROOT_DEVICE                @"upnp:rootdevice"                                      //智能电视、机顶盒、路由器、支持DLNA的电脑设备等
#define UPNP_MEDIA_RENDERER             @"urn:schemas-upnp-org:device:MediaRenderer:1"          //可渲染设备
#define UPNP_MEDIA_SERVER               @"urn:schemas-upnp-org:device:MediaServer:1"            //DLNA服务器
#define UPNP_INTERNET_GATEWAY_DEVICE    @"urn:schemas-upnp-org:device:InternetGatewayDevice:1"  //网关设备
#define UPNP_WFA_DEVICE                 @"urn:schemas-wifialliance-org:device:WFADevice:1"
#define UPNP_DEVICE_WITH(__UUID)        [NSString stringWithFormat:@"uuid:device-%@", __UUID]   //指定UUID的设备

//Server
#define SERVER_PATH @"/dlna/callback"

typedef void(^completionHandler)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

static NSString *const UPnPVideoStateChangedNotification = @"UPnPVideoStateChangedNotification";

@interface UPnPManager () <GCDAsyncUdpSocketDelegate>

@property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;
@property (strong, nonatomic) GCDWebServer *webServer;
@property (strong, nonatomic) Device *device;
@property (strong, nonatomic) Service *service;
@property (strong, nonatomic) Service *avTransportService;
@property (strong, nonatomic) Service *renderingControlService;
@property (strong, nonatomic) NSURLSession *sharedSession;

@end

@implementation UPnPManager

+ (instancetype)sharedManager
{
    static UPnPManager *manager;
    static dispatch_once_t onceToken;
    if (manager == nil)
    {
        dispatch_once(&onceToken, ^{
            manager = [[UPnPManager alloc] init];
        });
    }
    return manager;
}

- (void)setService:(Service *)service
{
    _service = service;
}

- (void)setDevice:(Device *)device
{
    _device = device;
}

- (void)searchDevice
{
    //先启动服务器后启动UDP，调用顺序不可改变
    [self _startGCDWebServer];
    [self _startUdpService];
}

- (void)subscribeEventNotificationForService:(Service *)service response:(void (^)(NSString * _Nullable subscribeID, NSURLResponse * _Nullable response, NSError * _Nullable error))responseBlock
{
    NSString *url = nil;
    NSString *eventSubURL = service.eventSubURL;
    if ([service.eventSubURL hasPrefix:@"/"])
    {
        url = [NSString stringWithFormat:@"http://%@:%@%@", self.device.address.ipv4, self.device.address.port, eventSubURL];
    }
    else
    {
        url = [NSString stringWithFormat:@"http://%@:%@/%@", self.device.address.ipv4, self.device.address.port, eventSubURL];
    }
    NSString *str = self.webServer.serverURL.absoluteString;
    if ([str hasSuffix:@"/"])
    {
        str = [str substringToIndex:str.length-1];
    }
    NSString *webServerURL = [NSString stringWithFormat:@"<%@%@>", str, SERVER_PATH];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url.stringByRemovingPercentEncoding]];
    request.HTTPMethod = @"SUBSCRIBE";
    [request addValue:webServerURL forHTTPHeaderField:@"CALLBACK"];
    [request addValue:@"upnp:event" forHTTPHeaderField:@"NT"];
    [request addValue:@"Infinite" forHTTPHeaderField:@"TIMEOUT"];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //SubscribeID
        if (error == nil)
        {
            NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
            if (resp.statusCode == 200)
            {
                NSString *sid = resp.allHeaderFields[@"SID"] ? resp.allHeaderFields[@"SID"] : nil;
                NSLog(@"DLNA事件订阅成功:\nSID: %@", sid);
                responseBlock(sid, response, nil);
            }
            else
            {
                responseBlock(nil, response, nil);
            }
        }
        else
        {
            responseBlock(nil, response, error);
        }
    }] resume];
}

- (void)subscribeEventNotificationForAVTransport
{
    [self subscribeEventNotificationForService:self.avTransportService response:nil];
}

- (void)subscribeEventNotificationForAVTransportResponse:(void (^)(NSString * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))responseBlock
{
    [self subscribeEventNotificationForService:self.avTransportService response:responseBlock];
}

#pragma mark - Private

#pragma mark - GCDWebServer

- (void)_startGCDWebServer
{
    if (self.webServer == nil)
    {
        self.webServer = [[GCDWebServer alloc] init];
        __weak typeof(self) weakSelf = self;
        
        //(Asynchronous version) The handler returns immediately and calls back GCDWebServer later with the generated HTTP response
        [weakSelf.webServer addHandlerForMethod:@"NOTIFY" path:SERVER_PATH requestClass:[GCDWebServerDataRequest class] asyncProcessBlock:^(__kindof GCDWebServerRequest *request, GCDWebServerCompletionBlock completionBlock) {
            // Do some async operation like network access or file I/O (simulated here using dispatch_after())
            GCDWebServerDataRequest *req = (GCDWebServerDataRequest *)request;
            __strong typeof(self) strongSelf = weakSelf;
            if (req.hasBody && strongSelf)
            {
                [strongSelf _parseEventNotificationMessage:req.data];
            }
            GCDWebServerDataResponse* response = [GCDWebServerDataResponse responseWithHTML:@"<html><body><p>Hello World</p></body></html>"];
            completionBlock(response);
        }];
        
        [self.webServer startWithPort:LOCAL_SERVER_PORT bonjourName:nil];
    }
}

- (void)_parseEventNotificationMessage:(NSData *)data
{
    if (data == nil)
    {
        return;
    }
    NSDictionary *dictData = [NSDictionary dictionaryWithXMLData:data];
    NSString *lastChange = [dictData stringValueForKeyPath:@"e:property.LastChange"];
    if (lastChange == nil || [lastChange isKindOfClass:[NSNull class]] || lastChange.length <= 0)
    {
        return;
    }
    NSDictionary *eproperty = [NSDictionary dictionaryWithXMLString:lastChange];
    NSString *transportstate = [eproperty stringValueForKeyPath:@"InstanceID.TransportState._val"] ? [eproperty stringValueForKeyPath:@"InstanceID.TransportState._val"] : [eproperty stringValueForKeyPath:@"InstanceID.TransportState.val"];
    if (transportstate == nil || [transportstate isKindOfClass:[NSNull class]] || transportstate.length <= 0)
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"事件通知:\n%@\n%@\n状态:%@", dictData, eproperty, transportstate);
        [[NSNotificationCenter defaultCenter] postNotificationName:UPnPVideoStateChangedNotification object:nil userInfo:@{@"transportState": @([self _transportStateWith:transportstate])}];
    });
}

- (UPnPEventTransportState)_transportStateWith:(NSString *)origin
{
    if (origin == nil || origin.length <= 0)
    {
        return UPnPEventTransportStateUnknown;
    }
    else if ([origin isEqualToString:@"PAUSED_PLAYBACK"])
    {
        return UPnPEventTransportStatePaused;
    }
    else if ([origin isEqualToString:@"PLAYING"])
    {
        return UPnPEventTransportStatePlaying;
    }
    else if ([origin isEqualToString:@"STOPPED"])
    {
        return UPnPEventTransportStateStopped;
    }
    else if ([origin isEqualToString:@"TRANSITIONING"])
    {
        return UPnPEventTransportStateTransitioning;
    }
    else
    {
        return UPnPEventTransportStateUnknown;
    }
}

#pragma mark - UDP

- (void)_startUdpService
{
    [self _setupUdpSocket];
    [self _startSSDPSearch];
}

- (void)_setupUdpSocket
{
    if (self.udpSocket == nil)
    {
        self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    else if (self.udpSocket.isConnected || self.udpSocket.isClosed == NO)
    {
        [self.udpSocket close];
    }
    [self.udpSocket setIPv6Enabled:NO];
    NSError *bindPortErr = nil;
    if(![self.udpSocket bindToPort:LOCAL_UDP_PORT error:&bindPortErr])
    {
        NSLog(@"UDP绑定本地端口错误，重复绑定错误可忽略:\n%@\n", bindPortErr);
    }
    NSError *bindBroadErr = nil;
    if (![self.udpSocket enableBroadcast:YES error:&bindBroadErr])
    {
        NSLog(@"UDP广播开启错误:\n%@\n", bindBroadErr);
    }
    NSError *joinGroupErr = nil;
    if(![self.udpSocket joinMulticastGroup:SSDP_MULTICAST_HOST_IP error:&joinGroupErr])
    {
        NSLog(@"UDP加入组网错误，重复加入错误可忽略:\n%@\n", joinGroupErr);
    }
    NSError *recvErr = nil;
    if (![self.udpSocket beginReceiving:&recvErr])
    {
        [self.udpSocket close];
        NSLog(@"UDP开启接收错误: %@", recvErr);
    }
}

- (void)_startSSDPSearch
{
    NSString *m_search_header_string = [self _SSDP__M_SEARCH_REQUEST_HEADER];
    NSLog(@"发送请求:\n%@", m_search_header_string);
    NSData *socketData = [m_search_header_string dataUsingEncoding:NSUTF8StringEncoding];
    [self.udpSocket sendData:socketData toHost:SSDP_MULTICAST_HOST_IP port:SSDP_MULTICAST_HOST_PORT withTimeout:TIMEOUT tag:12];
}

- (NSString *)_SSDP__M_SEARCH_REQUEST_HEADER
{
    NSMutableString *mutRequestString = [NSMutableString new];
    [mutRequestString appendString:@"M-SEARCH * HTTP/1.1\r\n"];
    [mutRequestString appendString:[NSString stringWithFormat:@"MX: %@\r\n", MX]];
    [mutRequestString appendString:[NSString stringWithFormat:@"ST: %@\r\n", ST]];
    [mutRequestString appendString:[NSString stringWithFormat:@"MAN: \"%@\"\r\n", MAN]];
    [mutRequestString appendString:[NSString stringWithFormat:@"User-Agent: %@\r\n", USER_AGENT]];
    [mutRequestString appendString:[NSString stringWithFormat:@"Connection: %@\r\n", CONNECTION]];
    [mutRequestString appendString:[NSString stringWithFormat:@"Host: %@:%@\r\n\r\n", SSDP_MULTICAST_HOST_IP, [NSString stringWithFormat:@"%d", SSDP_MULTICAST_HOST_PORT]]];
    return mutRequestString.copy;
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    //异步处理数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *text = [NSString stringWithFormat:@"从地址:\n\n%@\n\n收到UDP套接字数据:\n\n%@", [[NSString alloc] initWithData:address encoding:NSUTF8StringEncoding], [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        NSLog(@"%@", text);
        SsdpResponseHeader *header = [[SsdpResponseHeader alloc] initWithReceivedMsg:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        Device *device = [[Device alloc] initWithSsdpResponse:header];
        if ([self.ssdpDataDelegate respondsToSelector:@selector(uPnpManager:didDiscoverDevice:)])
        {
            [self.ssdpDataDelegate uPnpManager:self didDiscoverDevice:device];
        }
    });
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"发送信息成功");
    if ([self.ssdpDataDelegate respondsToSelector:@selector(uPnpManagerDidSendData:)])
    {
        [self.ssdpDataDelegate uPnpManagerDidSendData:self];
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"发送信息失败");
    if ([self.ssdpDataDelegate respondsToSelector:@selector(uPnpManager:didNotSendDataDueToError:)])
    {
        [self.ssdpDataDelegate uPnpManager:self didNotSendDataDueToError:error];
    }
}

#pragma mark - Connection

- (void)fetchDDDSuccessHandler:(DDDHandler)dddBlk failureHandler:(failureHandler)failBlk
{
    [self _requestDataWithURL:self.device.location successHandler:^(NSData * _Nullable data)
    {
        NSDictionary *dataDict = [NSDictionary dictionaryWithXMLData:data];
        DeviceDescription *ddd = [[DeviceDescription alloc] initWithDictionary:dataDict];
        [self _saveMainServices:ddd.services];
        dddBlk(ddd);
    }
    failureHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        failBlk(data, response, error);
    }];
}

- (void)fetchSDDSuccessHandler:(SDDHandler)sddBlk failureHandler:(failureHandler)failBlk
{
    NSString *url = nil;
    if ([self.service.SCPDURL hasPrefix:@"/"])
    {
        url = [NSString stringWithFormat:@"%@:%@%@", self.device.address.ipv4, self.device.address.port, self.service.SCPDURL];
    }
    else
    {
        url = [NSString stringWithFormat:@"%@:%@/%@", self.device.address.ipv4, self.device.address.port, self.service.SCPDURL];
    }
    NSString *urlStr = nil;
    if ([url hasPrefix:@"http"] == NO)
    {
        urlStr = [NSString stringWithFormat:@"http://%@", url];
    }
    else
    {
        urlStr = url;
    }
    [self _requestDataWithURL:urlStr successHandler:^(NSData * _Nullable data)
    {
        NSDictionary *dataDict = [NSDictionary dictionaryWithXMLData:data];
        ServiceDescription *sdd = [[ServiceDescription alloc] initWithDictionary:dataDict];
        sddBlk(sdd);
    }
    failureHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        failBlk(data, response, error);
    }];
}

#pragma mark - Private

- (void)_saveMainServices:(NSArray *)services;
{
    NSArray<Service *> *aServices = services;
    if (aServices != nil || aServices.count > 0)
    {
        [aServices enumerateObjectsUsingBlock:^(Service * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
         {
             Service *service = (Service *)obj;
             if (service.serviceID != nil && service.serviceID.length > 0)
             {
                 if ([service.serviceID.lowercaseString containsString:@"avtransport"])
                 {
                     self.avTransportService = service;
                 }
                 else if ([service.serviceID.lowercaseString containsString:@"renderingcontrol"])
                 {
                     self.renderingControlService = service;
                 }
             }
         }];
    }
}

- (void)_requestDataWithURL:(NSString * _Nullable)url
             successHandler:(successHandler _Nonnull)successblk
             failureHandler:(failureHandler _Nonnull)failureblk;
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
      {
          if (data && data.length > 0 && error == nil)
          {
              successblk(data);
          }
          else
          {
              failureblk(data, response, error);
          }
      }] resume];
}

#pragma mark - ControlPoint

#pragma mark - AVTransport

- (void)setAVTransportURI:(NSString * _Nullable)uri response:(ActionResponseHandler)responseHandler
{
    UPnPActionRequest *request = [[UPnPActionRequest alloc] initWithActionName:@"SetAVTransportURI"];
    request.service = self.avTransportService;
    request.device = self.device;
    NSString *encodedURI = uri.stringByRemovingPercentEncoding;
    [request addParameterWithKey:@"InstanceID" value:@"0"];
    [request addParameterWithKey:@"CurrentURI" value:encodedURI];
    [request addParameterWithKey:@"CurrentURIMetaData" value:@""];
    [request composeRequest];
    
    [self _httpRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
        actResp.statusCode = resp.statusCode;
        if ([self.controlPointDelegate respondsToSelector:@selector(uPnpManager:didSetAVTransportURI:response:)])
        {
            [self.controlPointDelegate uPnpManager:self didSetAVTransportURI:uri response:actResp];
        }
        responseHandler(actResp, response, error);
    }];
}

- (void)setNextAVTransportURI:(NSString *)uri response:(ActionResponseHandler)responseHandler
{
    UPnPActionRequest *request = [[UPnPActionRequest alloc] initWithActionName:@"SetNextAVTransportURI"];
    request.service = self.avTransportService;
    request.device = self.device;
    NSString *encodedURI = uri.stringByRemovingPercentEncoding;
    [request addParameterWithKey:@"InstanceID" value:@"0"];
    [request addParameterWithKey:@"NextURI" value:encodedURI];
    [request addParameterWithKey:@"NextURIMetaData" value:@""];
    [request composeRequest];
    
    [self _httpRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
        actResp.statusCode = resp.statusCode;
        if ([self.controlPointDelegate respondsToSelector:@selector(uPnpManager:didSetNextAVTransportURI:response:)])
        {
            [self.controlPointDelegate uPnpManager:self didSetNextAVTransportURI:uri response:actResp];
        }
        responseHandler(actResp, response, error);
    }];
}

- (void)seekTo:(NSString *)target response:(ActionResponseHandler)responseHandler
{
    UPnPActionRequest *request = [[UPnPActionRequest alloc] initWithActionName:@"Seek"];
    request.service = self.avTransportService;
    request.device = self.device;
    [request addParameterWithKey:@"InstanceID" value:@"0"];
    [request addParameterWithKey:@"Unit" value:@"REL_TIME"];
    [request addParameterWithKey:@"Target" value:target];
    [request composeRequest];
    
    [self _httpRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
        actResp.statusCode = resp.statusCode;
        if ([self.controlPointDelegate respondsToSelector:@selector(uPnpManager:didSeekTo:response:)])
        {
            [self.controlPointDelegate uPnpManager:self didSeekTo:target response:actResp];
        }
        responseHandler(actResp, response, error);
    }];
}

- (void)playWithResponse:(ActionResponseHandler)responseHandler
{
    UPnPActionRequest *request = [[UPnPActionRequest alloc] initWithActionName:@"Play"];
    request.service = self.avTransportService;
    request.device = self.device;
    [request addParameterWithKey:@"InstanceID" value:@"0"];
    [request addParameterWithKey:@"Speed" value:@"1"];
    [request composeRequest];
    
    [self _httpRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        if ([self.controlPointDelegate respondsToSelector:@selector(uPnpManager:didPlayResponse:)])
        {
            [self.controlPointDelegate uPnpManager:self didPlayResponse:actResp];
        }
        responseHandler(actResp, response, error);
    }];
}

- (void)pauseWithResponse:(ActionResponseHandler)responseHandler
{
    UPnPActionRequest *request = [[UPnPActionRequest alloc] initWithActionName:@"Pause"];
    request.service = self.avTransportService;
    request.device = self.device;
    [request addParameterWithKey:@"InstanceID" value:@"0"];
    [request composeRequest];
    
    [self _httpRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        if ([self.controlPointDelegate respondsToSelector:@selector(uPnpManager:didPauseResponse:)])
        {
            [self.controlPointDelegate uPnpManager:self didPauseResponse:actResp];
        }
        responseHandler(actResp, response, error);
    }];
}

- (void)stopWithResponse:(ActionResponseHandler)responseHandler
{
    UPnPActionRequest *request = [[UPnPActionRequest alloc] initWithActionName:@"Stop"];
    request.service = self.avTransportService;
    request.device = self.device;
    [request addParameterWithKey:@"InstanceID" value:@"0"];
    [request composeRequest];
    
    [self _httpRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        if ([self.controlPointDelegate respondsToSelector:@selector(uPnpManager:didStopResponse:)])
        {
            [self.controlPointDelegate uPnpManager:self didStopResponse:actResp];
        }
        responseHandler(actResp, response, error);
    }];
}

- (void)getTransportInfo:(ActionResponseHandler)responseHandler
{
    UPnPActionRequest *request = [[UPnPActionRequest alloc] initWithActionName:@"GetTransportInfo"];
    request.service = self.avTransportService;
    request.device = self.device;
    [request addParameterWithKey:@"InstanceID" value:@"0"];
    [request composeRequest];
    
    [self _httpRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        if ([self.controlPointDelegate respondsToSelector:@selector(uPnpManager:didGetTransportInfoResponse:)])
        {
            [self.controlPointDelegate uPnpManager:self didGetTransportInfoResponse:actResp];
        }
        responseHandler(actResp, response, error);
    }];
}

- (void)getPositionInfo:(ActionResponseHandler)responseHandler
{
    UPnPActionRequest *request = [[UPnPActionRequest alloc] initWithActionName:@"GetPositionInfo"];
    request.service = self.avTransportService;
    request.device = self.device;
    [request addParameterWithKey:@"InstanceID" value:@"0"];
    [request composeRequest];
    
    [self _httpRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        if ([self.controlPointDelegate respondsToSelector:@selector(uPnpManager:didGetPositionInfoResponse:)])
        {
            [self.controlPointDelegate uPnpManager:self didGetPositionInfoResponse:actResp];
        }
        responseHandler(actResp, response, error);
    }];
}

- (void)getCurrentTransportActions:(ActionResponseHandler)responseHandler
{
    UPnPActionRequest *request = [[UPnPActionRequest alloc] initWithActionName:@"GetCurrentTransportActions"];
    request.service = self.avTransportService;
    request.device = self.device;
    [request addParameterWithKey:@"InstanceID" value:@"0"];
    [request composeRequest];
    
    [self _httpRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        responseHandler(actResp, response, error);
    }];
}

#pragma mark - RenderingControl

- (void)setVolume:(NSString *)volume response:(ActionResponseHandler)responseHandler
{
    UPnPActionRequest *request = [[UPnPActionRequest alloc] initWithActionName:@"SetVolume"];
    request.service = self.renderingControlService;
    request.device = self.device;
    [request addParameterWithKey:@"InstanceID" value:@"0"];
    [request addParameterWithKey:@"Channel" value:@"Master"];
    [request addParameterWithKey:@"DesiredVolume" value:volume];
    [request composeRequest];
    
    [self _httpRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        responseHandler(actResp, response, error);
    }];
}

#pragma mark - Private

- (void)_httpRequest:(UPnPActionRequest *)request completionHandler:(completionHandler)handler
{
    if (self.sharedSession == nil)
    {
        self.sharedSession = [NSURLSession sharedSession];
    }
    NSURLSession *session = self.sharedSession;
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        handler(data, response, error);
    }] resume];
}

@end
