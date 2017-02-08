//
//  ActionViewController.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/8.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "ActionViewController.h"
#import "Device+Current.h"
#import "UPnPManager+ControlPoint.h"

#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height

#define VIDEO_URL @"http://10.2.15.163/movie/Homeless.mp4"

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
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 60, Screen_Width-40, Screen_Height*2/3)];
    [self.view addSubview:textView];
    textView.font = [UIFont systemFontOfSize:13.0];
    textView.editable = NO;
    textView.text = [NSString stringWithFormat:@"Action name: %@\n\n%@", self.action.name, [self _argumentContent]];
    self.textView = textView;
    
    UIButton *playButton = [UIButton new];
    [playButton setTitle:@"播放" forState:UIControlStateNormal];
    [playButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [playButton setBackgroundColor:[UIColor purpleColor]];
    playButton.frame = CGRectMake(20, textView.frame.origin.y+textView.frame.size.height+10, textView.frame.size.width, 40);
    [playButton addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playButton];
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
    Address *address = [Device currentDevice].address;
    manager.address = address;
    manager.action = self.action;
    manager.service = self.sdd.service;
    
    weakify(manager);
    [manager setAVTransportURI:VIDEO_URL completion:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        strongify(manager);
        if (data != nil && data.length > 0)
        {
            NSDictionary *dataDict = [NSDictionary dictionaryWithXMLData:data];
            NSLog(@"视频地址发送完毕:\n%@", dataDict);
            [manager playCompletion:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (data && data.length > 0)
                {
                    
                }
            }];
        }
    }];
}

@end
