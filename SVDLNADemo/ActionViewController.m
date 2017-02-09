//
//  ActionViewController.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/8.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "ActionViewController.h"
#import "UPnPManager+ControlPoint.h"
#import "ControlPanelViewController.h"
#import "CurrentDevice.h"

#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height

#define Below_Navbar [UIApplication sharedApplication].statusBarFrame.size.height+self.navigationController.navigationBar.frame.size.height

#define VIDEO_URL @"http://baobab.wdjcdn.com/14571455324031.mp4"

@interface ActionViewController ()

@property (strong, nonatomic) Action *action;
@property (strong, nonatomic) ServiceDescription *sdd;

@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIButton *playButton;

@end

@implementation ActionViewController

- (instancetype)initWithAction:(Action *)action SDD:(ServiceDescription *)sdd
{
    self = [super init];
    if (self)
    {
        _action = action;
        _sdd = sdd;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.action.name;
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20, Below_Navbar+10, Screen_Width-40, Screen_Height*2/3)];
    [self.view addSubview:textView];
    textView.font = [UIFont systemFontOfSize:13.0];
    textView.editable = NO;
    textView.text = [NSString stringWithFormat:@"Action name: %@\n\n%@", self.action.name, [self _argumentContent]];
    self.textView = textView;
    
    if ([[self.action.name lowercaseString] isEqualToString:@"setavtransporturi"])
    {
        UIButton *playButton = [UIButton new];
        [playButton setTitle:@"播放" forState:UIControlStateNormal];
        [playButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [playButton setBackgroundColor:[UIColor purpleColor]];
        playButton.frame = CGRectMake(20, textView.frame.origin.y+textView.frame.size.height+10, textView.frame.size.width, 40);
        [playButton addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:playButton];
        self.playButton = playButton;
    }
}

- (NSString *)_argumentContent
{
    NSMutableString *mstr = [NSMutableString new];
    for (Argument *arg in self.action.arguments)
    {
        [mstr appendString:[NSString stringWithFormat:@"arg:\nname: %@\ndirection: %@\nrelatedStateVariable: %@\n\n", arg.name, arg.direction, arg.relatedStateVariable]];
    }
    return mstr.copy;
}

- (void)playButtonPressed:(UIButton *)sender
{
    UPnPManager *manager = [UPnPManager sharedManager];
    Address *address = [CurrentDevice sharedDevice].device.address;
    UPnPActionRequest *request = [[UPnPActionRequest alloc] init];
    request.address = address;
    request.action = self.action;
    request.service = self.sdd.service;
    [manager setRequest:request];
    
    [manager setAVTransportURI:VIDEO_URL response:^(UPnPActionResponse * _Nullable actionResponse, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"发送视频地址(setAVTransportURI)的回调:\n%@", actionResponse.xmlDictionary);

    }];
}

@end
