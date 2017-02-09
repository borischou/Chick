//
//  ControlPanelViewController.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/9.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "ControlPanelViewController.h"
#import "ServiceDescription.h"
#import "CurrentDevice.h"

@interface ControlPanelViewController ()

@property (strong, nonatomic) UILabel *reminderLabel;
@property (strong, nonatomic) UIButton *pauseButton;
@property (strong, nonatomic) UIButton *stopButton;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UIButton *seekButton;

@property (strong, nonatomic) ServiceDescription *sdd;

@end

@implementation ControlPanelViewController

- (instancetype)initWithSDD:(ServiceDescription *)sdd
{
    if (self = [super init])
    {
        _sdd = sdd;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _reminderLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, Below_Navbar+10, Screen_Width-40, 100)];
    _reminderLabel.numberOfLines = 0;
    _reminderLabel.font = [UIFont systemFontOfSize:13.0];
    [self.view addSubview:_reminderLabel];
    
    _playButton = [UIButton new];
    [_playButton setTitle:@"播放" forState:UIControlStateNormal];
    [_playButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_playButton setBackgroundColor:[UIColor purpleColor]];
    [_playButton addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playButton];
    
    _pauseButton = [UIButton new];
    [_pauseButton setTitle:@"暂停" forState:UIControlStateNormal];
    [_pauseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_pauseButton setBackgroundColor:[UIColor purpleColor]];
    [_pauseButton addTarget:self action:@selector(pauseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_pauseButton];
    
    _stopButton = [UIButton new];
    [_stopButton setTitle:@"停止" forState:UIControlStateNormal];
    [_stopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_stopButton setBackgroundColor:[UIColor purpleColor]];
    [_stopButton addTarget:self action:@selector(stopButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_stopButton];
    
    _seekButton = [UIButton new];
    [_seekButton setTitle:@"跳播" forState:UIControlStateNormal];
    [_seekButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_seekButton setBackgroundColor:[UIColor purpleColor]];
    [_seekButton addTarget:self action:@selector(seekButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_seekButton];
    
    CGFloat top = _reminderLabel.frame.origin.y+_reminderLabel.frame.size.height+10;
    CGFloat width = (Screen_Width-80)/3;
    CGFloat height = 40;
    
    _playButton.frame = CGRectMake(20, top, width, height);
    _pauseButton.frame = CGRectMake(_playButton.frame.origin.x+_playButton.frame.size.width+20, top, width, height);
    _stopButton.frame = CGRectMake(_pauseButton.frame.origin.x+_pauseButton.frame.size.width+20, top, width, height);
    _seekButton.frame = CGRectMake(20, _playButton.frame.origin.y+_playButton.frame.size.height+10, width, height);
}

- (void)seekButtonPressed:(UIButton *)sender
{
    UPnPManager *manager = [UPnPManager sharedManager];
    Address *address = [CurrentDevice sharedDevice].device.address;
    UPnPActionRequest *request = [UPnPActionRequest request];
    request.address = address;
    request.service = self.sdd.service;
    [manager setRequest:request];
    [manager seekTo:@"00:00:01" response:^(UPnPActionResponse * _Nullable actionResponse, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async_main_safe(^{
            NSLog(@"Seek的回调:\n%@", actionResponse.xmlDictionary);
        });
    }];
}

- (void)playButtonPressed:(UIButton *)sender
{
    UPnPManager *manager = [UPnPManager sharedManager];
    Address *address = [CurrentDevice sharedDevice].device.address;
    UPnPActionRequest *request = [[UPnPActionRequest alloc] init];
    request.address = address;
    request.service = self.sdd.service;
    [manager setRequest:request];
    [manager playWithResponse:^(UPnPActionResponse * _Nullable actionResponse, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async_main_safe(^{
            NSLog(@"Play的回调:\n%@", actionResponse.xmlDictionary);
        });
    }];
}

- (void)pauseButtonPressed:(UIButton *)sender
{
    UPnPManager *manager = [UPnPManager sharedManager];
    Address *address = [CurrentDevice sharedDevice].device.address;
    UPnPActionRequest *request = [[UPnPActionRequest alloc] init];
    request.address = address;
    request.service = self.sdd.service;
    [manager setRequest:request];
    [manager pauseWithResponse:^(UPnPActionResponse * _Nullable actionResponse, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async_main_safe(^{
            NSLog(@"Pause的回调:\n%@", actionResponse.xmlDictionary);
        });
    }];
}

- (void)stopButtonPressed:(UIButton *)sender
{
    UPnPManager *manager = [UPnPManager sharedManager];
    Address *address = [CurrentDevice sharedDevice].device.address;
    UPnPActionRequest *request = [[UPnPActionRequest alloc] init];
    request.address = address;
    request.service = self.sdd.service;
    [manager setRequest:request];
    [manager stopWithResponse:^(UPnPActionResponse * _Nullable actionResponse, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async_main_safe(^{
            NSLog(@"Stop的回调:\n%@", actionResponse.xmlDictionary);
        });
    }];
}

@end
