//
//  SDDViewController.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/7.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "SDDViewController.h"
#import "ServiceDescription.h"
#import "XMLDictionary.h"

#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height

static NSString *const REUSECELLID = @"reusecellid";

@interface SDDViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) ServiceDescription *sdd;
@property (copy, nonatomic) NSString *url;

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation SDDViewController

- (instancetype)initWithURL:(NSString *)url
{
    self = [super init];
    if (self)
    {
        _url = url;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSString *urlStr = nil;
    if ([url hasPrefix:@"http"] == NO)
    {
        urlStr = [NSString stringWithFormat:@"http://%@", url];
    }
    else
    {
        urlStr = url;
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data)
        {
            NSDictionary *dataDict = [NSDictionary dictionaryWithXMLData:data];
            ServiceDescription *sdd = [[ServiceDescription alloc] initWithDictionary:dataDict];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.sdd = sdd;
                [self.tableView reloadData];
            });
        }
    }] resume];
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

@end
