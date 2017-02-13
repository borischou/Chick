//
//  ViewController.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/6.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "ViewController.h"
#import "CustomTableViewCell.h"
#import "DDDViewController.h"
#import "ARCWeakRef.h"

static NSString *const REUSECELLID = @"reuseid";

@interface ViewController () <UPnPSSDPDataDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableArray<Device *> *devices;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"设备列表";
    self.view.backgroundColor = [UIColor whiteColor];
    [self _initUI];
    [self _searchDevice];
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
    [self _searchDevice];
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
    return self.devices && self.devices.count > 0 ? self.devices.count : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Device *device = [self.devices objectAtIndex:indexPath.row];
    DDDViewController *dddvc = [[DDDViewController alloc] initWithDevice:device];
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

- (void)_searchDevice
{
    UPnPManager *manager = [UPnPManager sharedManager];
    manager.ssdpDataDelegate = self;
    [manager searchDevice];
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)uPnpManager:(UPnPManager *)manager didDiscoverDevice:(Device *)device
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.devices addObject:device];
        [self.tableView reloadData];
        self.title = [NSString stringWithFormat:@"DLNA设备列表(%lu)", (unsigned long)self.devices.count];
    });
}

@end
