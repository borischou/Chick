//
//  ViewController.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/6.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncUdpSocket.h"
#import "HttpResponseHeader.h"
#import "XMLDictionary.h"
#import "ARCWeakRef.h"

#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height

#define UDP_PORT 2345
#define HOST_IP @"239.255.255.250"
#define HOST_PORT 1900
#define TIMEOUT -1
#define USER_AGENT @""

@interface ViewController () <GCDAsyncUdpSocketDelegate>

@property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;
@property (strong, nonatomic) UITextView *resultTextView;
@property (strong, nonatomic) NSMutableArray *devices;
@property (strong, nonatomic) HttpResponseHeader *header;
@property (strong, nonatomic) NSArray *currentServices;
@property (strong, nonatomic) NSDictionary *currentService;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self _initUI];
    [self _refreshUdpSocket];
}

- (void)_initUI
{
    UITextView *textView = [UITextView new];
    textView.frame = CGRectMake(20, 30, [UIScreen mainScreen].bounds.size.width-40, Screen_Height-30-20-40-10);
    textView.textColor = [UIColor blackColor];
    textView.font = [UIFont systemFontOfSize:15];
    textView.editable = NO;
    [self.view addSubview:textView];
    self.resultTextView = textView;
    
    CGFloat buttonWidth = (Screen_Width-40-10)/3;
    
    UIButton *sendButton = [UIButton new];
    [sendButton setTitle:@"搜索设备" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sendButton.backgroundColor = [UIColor purpleColor];
    sendButton.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y+textView.frame.size.height+10, buttonWidth, 40);
    [sendButton addTarget:self action:@selector(_sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendButton];
    
    UIButton *serviceButton = [UIButton new];
    [serviceButton setTitle:@"可用服务" forState:UIControlStateNormal];
    [serviceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    serviceButton.backgroundColor = [UIColor redColor];
    serviceButton.frame = CGRectMake(sendButton.frame.origin.x+buttonWidth+5, sendButton.frame.origin.y, buttonWidth, 40);
    [serviceButton addTarget:self action:@selector(_serviceButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:serviceButton];
    
    UIButton *actionButton = [UIButton new];
    [actionButton setTitle:@"可用动作" forState:UIControlStateNormal];
    [actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    actionButton.backgroundColor = [UIColor blackColor];
    actionButton.frame = CGRectMake(serviceButton.frame.origin.x+buttonWidth+5, sendButton.frame.origin.y, buttonWidth, 40);
    [actionButton addTarget:self action:@selector(_actionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:actionButton];
}

- (void)_serviceButtonPressed:(UIButton *)sender
{
    if (self.currentServices)
    {
        self.resultTextView.text = self.currentServices.description;
    }
}

- (void)_actionButtonPressed:(UIButton *)sender
{
    if (self.currentService)
    {
        self.resultTextView.text = self.currentService.description;
    }
}

- (void)_sendButtonPressed:(UIButton *)sender
{
    [self _refreshUdpSocket];
}

- (void)_refreshUdpSocket
{
    if (self.udpSocket == nil)
    {
        self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        NSError *socketError = nil;
        [self.udpSocket bindToPort:UDP_PORT error:&socketError];
        if (socketError)
        {
            NSLog(@"套接字绑定错误: %@", socketError);
        }
        else
        {
            [self.udpSocket beginReceiving:&socketError];
        }
    }
    
    NSString *searchText = [self _ssdpRequestHeader];
    
    NSLog(@"发送请求:\n%@", searchText);
    NSData *socketData = [searchText dataUsingEncoding:NSUTF8StringEncoding];
    [self.udpSocket sendData:socketData toHost:HOST_IP port:HOST_PORT withTimeout:TIMEOUT tag:12];
}

- (NSString *)_ssdpRequestHeader
{
    NSMutableString *mutRequestString = [NSMutableString new];
    [mutRequestString appendString:@"M-SEARCH * HTTP/1.1\r\n"];
    [mutRequestString appendString:[NSString stringWithFormat:@"HOST:%@:%@\r\n", HOST_IP, [NSString stringWithFormat:@"%d", HOST_PORT]]];
    [mutRequestString appendString:@"MAN:\"ssdp:discover\"\r\n"];
    [mutRequestString appendString:@"MX:5\r\n"];
    [mutRequestString appendString:@"ST:upnp:rootdevice\r\n"];
    [mutRequestString appendString:[NSString stringWithFormat:@"USER-AGENT:%@\r\n\r\n\r\n", USER_AGENT]];
    
    return mutRequestString.copy;
}

- (void)_updateTextView:(NSString *)text
{
    if (self.resultTextView)
    {
        self.resultTextView.text = text;
    }
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"发送信息成功");
    [self _updateTextView:@"发送信息成功，正在搜索可用设备和服务..."];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"发送信息失败");
    [self _updateTextView:@"发送信息失败"];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    NSString *text = [NSString stringWithFormat:@"从地址: %@\n收到UDP套接字数据:\n%@", [[NSString alloc] initWithData:address encoding:NSUTF8StringEncoding], [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    NSLog(@"%@", text);
    [self _updateTextView:text];
    
    HttpResponseHeader *header = [[HttpResponseHeader alloc] initWithReceivedMsg:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    self.header = header;
    
    if (self.header.location && self.header.location.length > 0)
    {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.header.location] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSString *xmlStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
            NSDictionary *xmlDict = [NSDictionary dictionaryWithXMLParser:parser];
            
            NSArray *services = [xmlDict arrayValueForKeyPath:@"device.serviceList.service"];
            self.currentServices = services;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self _updateTextView:[NSString stringWithFormat:@"Header: %@\n\n\n\nXML DDD:\n%@\n\n\n\nXML services:\n%@", self.header, xmlStr, services.description]];
            });
            
            NSDictionary *service = [services objectAtIndex:0];
            NSString *serviceUrlStr = [NSString stringWithFormat:@"%@%@", [self.header.location substringToIndex:self.header.location.length-1], [service stringValueForKeyPath:@"SCPDURL"]];
            NSURLSessionDataTask *serviceTask = [session dataTaskWithURL:[NSURL URLWithString:serviceUrlStr] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *serviceDict = [NSDictionary dictionaryWithXMLData:data];
                self.currentService = serviceDict;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self _updateTextView:[NSString stringWithFormat:@"Service:\n%@", serviceDict]];
                });
            }];
            [serviceTask resume];
            
        }];
        [task resume];
    }
}

@end
