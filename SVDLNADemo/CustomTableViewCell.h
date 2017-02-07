//
//  CustomTableViewCell.h
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/7.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"

@interface CustomTableViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *subtitleLabel;

- (void)loadDevice:(Device *)device;

@end
