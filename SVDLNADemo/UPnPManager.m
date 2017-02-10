//
//  UPnPManager.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/8.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "UPnPManager.h"
#import "GCDAsyncUdpSocket.h"

@interface UPnPManager () <GCDAsyncUdpSocketDelegate>

@property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;

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

- (void)searchDevice
{
    [self _setupUdpSocketWithUdpPort:UDP_PORT];
    [self _startSSDPSearchWithHostIP:LAN_MULTICAST_HOST_IP hostPort:LAN_MULTICAST_HOST_PORT];
}

#pragma mark - Private

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
