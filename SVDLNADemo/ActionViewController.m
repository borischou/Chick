//
//  ActionViewController.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/8.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "ActionViewController.h"

#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height

@interface ActionViewController ()

@property (strong, nonatomic) Action *action;
@property (strong, nonatomic) UITextView *textView;

@end

@implementation ActionViewController

- (instancetype)initWithAction:(Action *)action
{
    self = [super init];
    if (self)
    {
        _action = action;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.action.name;
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 30, Screen_Width-40, Screen_Height*2/3)];
    [self.view addSubview:textView];
    self.textView = textView;
    textView.font = [UIFont systemFontOfSize:13.0];
    textView.text = [NSString stringWithFormat:@"Action name: %@\n\n%@", self.action.name, [self _argumentContent]];
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

@end
