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

#define UDP_PORT 2345

//SSDP M-SEARCH Header
#define LAN_MULTICAST_HOST_IP @"239.255.255.250"
#define LAN_MULTICAST_HOST_PORT 1900
#define TIMEOUT -1
#define USER_AGENT @""
#define MAN @"ssdp:discover" //请勿修改
#define MX @"5"
#define ST UPNP_ROOT_DEVICE

//SSDP DEVICE
#define UPNP_ALL @"ssdp:all"
#define UPNP_ROOT_DEVICE @"upnp:rootdevice" //包括智能电视、机顶盒、路由器、支持DLNA的电脑设备等
#define UPNP_MEDIA_RENDERER @"urn:schemas-upnp-org:device:MediaRenderer:1"
#define UPNP_MEDIA_SERVER @"urn:schemas-upnp-org:device:MediaServer:1"
#define UPNP_INTERNET_GATEWAY_DEVICE @"urn:schemas-upnp-org:device:InternetGatewayDevice:1"
#define UPNP_WFA_DEVICE @"urn:schemas-wifialliance-org:device:WFADevice:1"
#define UPNP_DEVICE_WITH(__UUID) [NSString stringWithFormat:@"uuid:device-%@", __UUID]

//Server
#define SERVER_PATH @"/dlna/callback"

@interface UPnPManager () <GCDAsyncUdpSocketDelegate>

@property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;
@property (strong, nonatomic) Address *address;
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

- (instancetype)initWithRequest:(UPnPActionRequest *)request
{
    self = [UPnPManager sharedManager];
    self.request = request;
    return self;
}

- (void)setRequest:(UPnPActionRequest *)request;
{
    _request = request;
}

- (void)setService:(Service *)service
{
    _service = service;
}

- (void)setAddress:(Address *)address
{
    _address = address;
}

- (void)searchDevice
{
    if (self.webServer == nil)
    {
        self.webServer = [[GCDWebServer alloc] init];
        [self _startGCDWebServer];
    }
    [self _setupUdpSocketWithUdpPort:UDP_PORT];
    [self _startSSDPSearchWithHostIP:LAN_MULTICAST_HOST_IP hostPort:LAN_MULTICAST_HOST_PORT];
}

- (void)subscribeEventNotificationFromDeviceAddress:(Address *)address service:(Service *)service response:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))responseBlock
{
    self.address = address;
    self.service = service;
    NSString *url = nil;
    NSString *eventSubURL = self.service.eventSubURL;
    if ([self.service.eventSubURL hasPrefix:@"/"])
    {
        url = [NSString stringWithFormat:@"http://%@:%@%@", self.address.ipv4, self.address.port, eventSubURL];
    }
    else
    {
        url = [NSString stringWithFormat:@"http://%@:%@/%@", self.address.ipv4, self.address.port, eventSubURL];
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
    [request addValue:@"Second-3600" forHTTPHeaderField:@"TIMEOUT"];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //SubscribeID
        responseBlock(data, response, error);
    }] resume];
}

- (void)subscribeEventNotificationFromDeviceAddress:(Address *)address service:(Service *)service
{
    [self subscribeEventNotificationFromDeviceAddress:address service:service response:nil];
}

#pragma mark - Private

#pragma mark - GCDWebServer

- (void)_startGCDWebServer
{
    __weak typeof(self) weakSelf = self;
    [weakSelf.webServer addHandlerForMethod:@"NOTIFY" path:SERVER_PATH requestClass:[GCDWebServerDataRequest class] processBlock:^GCDWebServerResponse *(__kindof GCDWebServerRequest *request) {
        GCDWebServerDataRequest *req = (GCDWebServerDataRequest *)request;
        __strong typeof(self) strongSelf = weakSelf;
        if (req.hasBody && strongSelf)
        {
            [strongSelf _parseEventNotificationMessage:req.data];
        }
        return [GCDWebServerDataResponse responseWithHTML:@"<html><body><p>Hello World</p></body></html>"];
    }];
    [self.webServer startWithPort:8899 bonjourName:nil];
}

- (void)_parseEventNotificationMessage:(NSData *)data
{
    if (data == nil)
    {
        return;
    }
    NSDictionary *dictData = [NSDictionary dictionaryWithXMLData:data];
    NSLog(@"事件通知:\n%@", dictData);
}

#pragma mark - UDP

- (void)_setupUdpSocketWithUdpPort:(NSUInteger)port
{
    if (self.udpSocket == nil)
    {
        self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        NSError *socketErr = nil;
        [self.udpSocket bindToPort:port error:&socketErr];
        if (socketErr)
        {
            NSLog(@"UDP套接字绑定错误: %@", socketErr);
        }
        else
        {
            [self.udpSocket beginReceiving:&socketErr];
        }
    }
}

- (void)_startSSDPSearchWithHostIP:(NSString *)host hostPort:(NSUInteger)port
{
    NSString *m_search_header_string = [self _SSDP__M_SEARCH_REQUEST_HEADER];
    NSLog(@"发送请求:\n%@", m_search_header_string);
    NSData *socketData = [m_search_header_string dataUsingEncoding:NSUTF8StringEncoding];
    [self.udpSocket sendData:socketData toHost:host port:port withTimeout:TIMEOUT tag:12];
}

- (NSString *)_SSDP__M_SEARCH_REQUEST_HEADER
{
    NSMutableString *mutRequestString = [NSMutableString new];
    [mutRequestString appendString:@"M-SEARCH * HTTP/1.1\r\n"];
    [mutRequestString appendString:[NSString stringWithFormat:@"HOST:%@:%@\r\n", LAN_MULTICAST_HOST_IP, [NSString stringWithFormat:@"%d", LAN_MULTICAST_HOST_PORT]]];
    [mutRequestString appendString:[NSString stringWithFormat:@"MAN:\"%@\"\r\n", MAN]];
    [mutRequestString appendString:[NSString stringWithFormat:@"MX:%@\r\n", MX]];
    [mutRequestString appendString:[NSString stringWithFormat:@"ST:%@\r\n", ST]];
    [mutRequestString appendString:[NSString stringWithFormat:@"USER-AGENT:%@\r\n\r\n\r\n", USER_AGENT]];
    return mutRequestString.copy;
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    NSString *text = [NSString stringWithFormat:@"从地址:\n\n%@\n\n收到UDP套接字数据:\n\n%@", [[NSString alloc] initWithData:address encoding:NSUTF8StringEncoding], [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    NSLog(@"%@", text);
    //异步接收数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
