//
//  ViewController.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/6.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncUdpSocket.h"
#import "SsdpResponseHeader.h"
#import "XMLDictionary.h"
#import "ARCWeakRef.h"
#import "Device.h"
#import "CustomTableViewCell.h"
#import "DDDViewController.h"

static NSString *const REUSECELLID = @"reuseid";

@interface ViewController () <GCDAsyncUdpSocketDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;
@property (strong, nonatomic) NSMutableArray<Device *> *devices;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"设备列表";
    self.view.backgroundColor = [UIColor whiteColor];
    [self _initUI];
    [self _refreshUdpSocket];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

#pragma mark - UI

- (void)_initUI
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.tableView registerClass:[CustomTableViewCell class] forCellReuseIdentifier:REUSECELLID];
    [self.view addSubview:self.tableView];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:self action:@selector(refreshButtonPressed:)];
    self.navigationItem.rightBarButtonItem = refreshButton;
}

#pragma mark - Action

- (void)refreshButtonPressed:(UIBarButtonItem *)sender
{
    [_devices removeAllObjects];
    [self.tableView reloadData];
    [self _refreshUdpSocket];
}

#pragma mark - Table View Delegate & Datasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:REUSECELLID forIndexPath:indexPath];
    
    if (self.devices && self.devices.count > 0)
    {
        Device *device = [self.devices objectAtIndex:indexPath.row];
        [cell loadDevice:device];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.devices ? self.devices.count : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Device *device = [self.devices objectAtIndex:indexPath.row];
    DDDViewController *dddvc = [[DDDViewController alloc] initWithLocation:device.location device:device];
    dddvc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:dddvc animated:YES];
}

#pragma mark - Data

- (NSMutableArray<Device *> *)devices
{
    if (_devices == nil)
    {
        _devices = [NSMutableArray new];
    }
    return _devices;
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
    
    NSString *searchText = [self _SSDP_M_Search_RequestHeader];
    
    NSLog(@"发送请求:\n%@", searchText);
    NSData *socketData = [searchText dataUsingEncoding:NSUTF8StringEncoding];
    [self.udpSocket sendData:socketData toHost:LAN_MULTICAST_HOST_IP port:LAN_MULTICAST_HOST_PORT withTimeout:TIMEOUT tag:12];
}

- (NSString *)_SSDP_M_Search_RequestHeader
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

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"发送信息成功");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"发送信息失败");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    NSString *text = [NSString stringWithFormat:@"从地址:\n\n%@\n\n收到UDP套接字数据:\n\n%@", [[NSString alloc] initWithData:address encoding:NSUTF8StringEncoding], [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    NSLog(@"%@", text);
    
    //异步接收数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SsdpResponseHeader *header = [[SsdpResponseHeader alloc] initWithReceivedMsg:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        Device *device = [[Device alloc] initWithSsdpResponse:header];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.devices addObject:device];
            [self.tableView reloadData];
            self.title = [NSString stringWithFormat:@"DLNA设备列表(%lu)", (unsigned long)self.devices.count];
        });
    });
}

@end
