//
//  DDDViewController.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/7.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "DDDViewController.h"
#import "XMLDictionary.h"
#import "DeviceDescription.h"
#import "SDDViewController.h"
#import "UPnPManager.h"
#import "UPnPManager+Connection.h"
#import "Device+Current.h"

#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height

static NSString *const REUSECELLID = @"reusecellid";

@interface DDDViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) DeviceDescription *ddd;
@property (copy, nonatomic) NSString *location;
@property (strong, nonatomic) Device *device;

@end

@implementation DDDViewController

- (instancetype)initWithLocation:(NSString *)location device:(Device *)device
{
    self = [super init];
    if (self)
    {
        _location = location;
        _device = device;
        [Device currentDevice].address = device.address;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:REUSECELLID];
    [self.view addSubview:self.tableView];
    
    self.title = @"正在加载...";
    [self loadDDDWithLocation:self.location];
}

- (void)loadDDDWithLocation:(NSString *)location
{
    [[UPnPManager sharedManager] fetchDDDWithLocation:location successHandler:^(DeviceDescription * _Nullable ddd) {
        self.title = ddd.friendlyName ? ddd.friendlyName : @"DDD";
        self.ddd = ddd;
        [self.tableView reloadData];
    } failureHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        self.title = @"DDD";
        [self presentAlertWithError:error];
    }];
}

- (void)presentAlertWithError:(NSError *)error
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"错误" message:[NSString stringWithFormat:@"无效地址或发生错误\n%@", error ? error.description : @""] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [ac addAction:confirmAction];
    [self.navigationController presentViewController:ac animated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:REUSECELLID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:13.0];
    if (self.ddd)
    {
        cell.textLabel.textColor = [UIColor blackColor];
        DeviceDescription *ddd = self.ddd;
        switch (indexPath.row)
        {
            case 0:
                cell.textLabel.text = ddd.deviceType;
                break;
            case 1:
                cell.textLabel.text = ddd.udn;
                break;
            case 2:
                cell.textLabel.text = ddd.friendlyName;
                break;
            case 3:
                cell.textLabel.text = ddd.manufacturer;
                break;
            case 4:
                cell.textLabel.text = ddd.manufacturerURL;
                break;
            case 5:
                cell.textLabel.text = ddd.modelDescription;
                break;
            case 6:
                cell.textLabel.text = ddd.modelName;
                break;
            default:
                break;
        }
        
        if (indexPath.row > 6)
        {
            NSInteger idx = indexPath.row-7;
            Service *service = [ddd.services objectAtIndex:idx];
            cell.textLabel.textColor = [UIColor blueColor];
            cell.textLabel.text = service.serviceID;
            cell.textLabel.numberOfLines = 0;
        }
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.ddd && self.ddd.services ? self.ddd.services.count+7 : 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row <= 6)
    {
        return;
    }
    if (self.device == nil)
    {
        return;
    }
    Service *service = [self.ddd.services objectAtIndex:indexPath.row-7];
    NSString *url = nil;
    if ([service.SCPDURL hasPrefix:@"/"])
    {
        url = [NSString stringWithFormat:@"%@:%@%@", self.device.address.ipv4, self.device.address.port, service.SCPDURL];
    }
    else
    {
        url = [NSString stringWithFormat:@"%@:%@/%@", self.device.address.ipv4, self.device.address.port, service.SCPDURL];
    }
    SDDViewController *sddvc = [[SDDViewController alloc] initWithURL:url service:service];
    [self.navigationController pushViewController:sddvc animated:YES];
}

@end
