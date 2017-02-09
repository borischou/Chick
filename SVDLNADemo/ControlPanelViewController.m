//
//  ControlPanelViewController.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/9.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "ControlPanelViewController.h"
#import "ServiceDescription.h"

@interface ControlPanelViewController ()

@property (strong, nonatomic) UILabel *reminderLabel;
@property (strong, nonatomic) UIButton *playPauseButton;
@property (strong, nonatomic) UIButton *stopButton;

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
    
    _reminderLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, Below_Navbar+10, Screen_Width-40, 100)];
    _reminderLabel.numberOfLines = 0;
    _reminderLabel.font = [UIFont systemFontOfSize:13.0];
    [self.view addSubview:_reminderLabel];
    
    _playPauseButton = [UIButton new];
    [_playPauseButton setTitle:@"播放" forState:UIControlStateNormal];
    [_playPauseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_playPauseButton setBackgroundColor:[UIColor purpleColor]];
    [_playPauseButton addTarget:self action:@selector(playPauseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playPauseButton];
    
    _stopButton = [UIButton new];
    [_stopButton setTitle:@"停止" forState:UIControlStateNormal];
    [_stopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_stopButton setBackgroundColor:[UIColor purpleColor]];
    [_stopButton addTarget:self action:@selector(stopButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_stopButton];
}

- (void)playPauseButtonPressed:(UIButton *)sender
{
    
}

- (void)stopButtonPressed:(UIButton *)sender
{
    
}

@end
