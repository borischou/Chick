//
//  SDDViewController.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/7.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "SDDViewController.h"
#import "XMLDictionary.h"
#import "UPnPManager.h"
#import "UPnPManager+Connection.h"
#import "ActionViewController.h"

#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height

static NSString *const REUSECELLID = @"reusecellid";

@interface SDDViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) ServiceDescription *sdd;
@property (strong, nonatomic) Service *service;
@property (copy, nonatomic) NSString *url;

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation SDDViewController

- (instancetype)initWithURL:(NSString *)url service:(Service *)service
{
    self = [super init];
    if (self)
    {
        _url = url;
        _service = service;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"SDD: Action List";
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:REUSECELLID];
    [self.view addSubview:self.tableView];
    
    [self loadSDDWithURL:self.url];
}

- (void)loadSDDWithURL:(NSString *)url
{
    NSString *urlStr = nil;
    if ([url hasPrefix:@"http"] == NO)
    {
        urlStr = [NSString stringWithFormat:@"http://%@", url];
    }
    else
    {
        urlStr = url;
    }
    
    [[UPnPManager sharedManager] fetchSDDWithLocation:urlStr successHandler:^(ServiceDescription * _Nullable sdd) {
        self.sdd = sdd;
        self.sdd.service = self.service;
        dispatch_async_main_safe(^{
            [self.tableView reloadData];
        });
    } failureHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async_main_safe(^{
            [self presentAlertWithError:error];
        });
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
    
    if (self.sdd)
    {
        Action *action = [self.sdd.actions objectAtIndex:indexPath.row];
        cell.textLabel.text = action.name;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sdd ? self.sdd.actions.count : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.sdd == nil || self.sdd.actions == nil || self.sdd.actions.count < indexPath.row+1)
    {
        return;
    }
    Action *action = [self.sdd.actions objectAtIndex:indexPath.row];
    ActionViewController *avc = [[ActionViewController alloc] initWithAction:action SDD:self.sdd];
    [self.navigationController pushViewController:avc animated:YES];
}

@end
