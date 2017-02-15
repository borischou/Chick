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

#define LOCAL_UDP_PORT  0       //本地UDP端口 0代表系统随机分配 可防止冲突 建议不要修改
#define SERVER_PORT     8899    //本地服务器TCP端口

//SSDP M-SEARCH Header
#define SSDP_MULTICAST_HOST_IP           @"239.255.255.250"  //默认组网IP 请勿修改
#define SSDP_MULTICAST_HOST_PORT         1900                //默认组网端口 请勿修改
#define TIMEOUT                         -1                  //过期时间无限
#define USER_AGENT @" "                                     //可增加CP版本信息等
#define MAN                             @"ssdp:discover"    //默认搜索模式 请勿修改
#define MX                              @"5"                //随机接收时间最大值
#define ST                              UPNP_ROOT_DEVICE    //搜索设备类型

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

static NSString *const UPnPVideoStateChangedNotification = @"UPnPVideoStateChangedNotification";

@interface UPnPManager () <GCDAsyncUdpSocketDelegate>

@property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;
@property (strong, nonatomic) Device *device;
@property (strong, nonatomic) Service *service;
@property (strong, nonatomic) GCDWebServer *webServer;

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

- (void)subscribeEventNotificationResponse:(void (^)(NSString * _Nullable subscribeID, NSURLResponse * _Nullable response, NSError * _Nullable error))responseBlock
{
    NSString *url = nil;
    NSString *eventSubURL = self.service.eventSubURL;
    if ([self.service.eventSubURL hasPrefix:@"/"])
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

- (void)subscribeEventNotification
{
    [self subscribeEventNotificationResponse:nil];
}

#pragma mark - Private

#pragma mark - GCDWebServer

- (void)_startGCDWebServer
{
    if (self.webServer == nil)
    {
        self.webServer = [[GCDWebServer alloc] init];
    }
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
    
    [self.webServer startWithPort:SERVER_PORT bonjourName:nil];
}

- (void)_parseEventNotificationMessage:(NSData *)data
{
    if (data == nil)
    {
        return;
    }
    NSDictionary *dictData = [NSDictionary dictionaryWithXMLData:data];
    NSDictionary *eproperty = [NSDictionary dictionaryWithXMLString:[dictData stringValueForKeyPath:@"e:property.LastChange"]];
    NSString *transportstate = [eproperty stringValueForKeyPath:@"InstanceID.TransportState._val"] ? [eproperty stringValueForKeyPath:@"InstanceID.TransportState._val"] : [eproperty stringValueForKeyPath:@"InstanceID.TransportState.val"];
    if (transportstate == nil || transportstate.length <= 0)
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
    if (self.webServer && self.webServer.isRunning)
    {
        [self.webServer stop];
        [self.webServer startWithPort:SERVER_PORT bonjourName:nil];
    }
    if (self.udpSocket == nil)
    {
        self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
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
    [mutRequestString appendString:[NSString stringWithFormat:@"Host: %@:%@\r\n", SSDP_MULTICAST_HOST_IP, [NSString stringWithFormat:@"%d", SSDP_MULTICAST_HOST_PORT]]];
    [mutRequestString appendString:[NSString stringWithFormat:@"MAN: \"%@\"\r\n", MAN]];
    [mutRequestString appendString:[NSString stringWithFormat:@"MX: %@\r\n", MX]];
    [mutRequestString appendString:[NSString stringWithFormat:@"ST: %@\r\n", ST]];
    [mutRequestString appendString:[NSString stringWithFormat:@"User-Agent: %@\r\n\r\n\r\n", USER_AGENT]];
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

@end
