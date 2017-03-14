//
//  ActionViewController.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/8.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "ActionViewController.h"
#import "ControlPanelViewController.h"

@interface ActionViewController ()

@property (strong, nonatomic) Action *action;
@property (strong, nonatomic) ServiceDescription *sdd;

@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIButton *actionButton;

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
    
    UIButton *actionButton = [UIButton new];
    [actionButton setTitle:self.action.name forState:UIControlStateNormal];
    [actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [actionButton setBackgroundColor:[UIColor purpleColor]];
    actionButton.frame = CGRectMake(20, textView.frame.origin.y+textView.frame.size.height+10, textView.frame.size.width, 40);
    [actionButton addTarget:self action:@selector(actionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:actionButton];
    self.actionButton = actionButton;
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

- (void)actionButtonPressed:(UIButton *)sender
{
    UPnPManager *manager = [UPnPManager sharedManager];
    [manager stopWithResponse:^(UPnPActionResponse * _Nullable actionResponse, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"Stop的回调:\n%@", actionResponse.xmlDictionary);
        UPnPManager *aManager = [UPnPManager sharedManager];
        dispatch_async_main_safe(^{
            NSLog(@"Stop的回调:\n%@", actionResponse.xmlDictionary);
            [aManager setAVTransportURI:TEST_URL response:^(UPnPActionResponse * _Nullable actionResponse, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                ControlPanelViewController *cpvc = [[ControlPanelViewController alloc] initWithSDD:self.sdd];
                dispatch_async_main_safe(^{
                    NSLog(@"setAVTransportURI的回调:\n%@", actionResponse.xmlDictionary);
                    [self.navigationController pushViewController:cpvc animated:YES];
                });
            }];
        });
    }];
}

@end
