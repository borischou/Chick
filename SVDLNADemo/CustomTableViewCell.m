//
//  CustomTableViewCell.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/7.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "CustomTableViewCell.h"

@interface CustomTableViewCell ()

@property (strong, nonatomic) Device *device;

@end

@implementation CustomTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self _setupUI];
    }
    return self;
}

- (void)_setupUI
{
    _titleLabel = [UILabel new];
    _subtitleLabel = [UILabel new];
    _titleLabel.numberOfLines = 0;
    _subtitleLabel.numberOfLines = 0;
    _titleLabel.font = [UIFont systemFontOfSize:13.0];
    _subtitleLabel.font = [UIFont systemFontOfSize:13.0];
    [self.contentView addSubview:_titleLabel];
    [self.contentView addSubview:_subtitleLabel];
}

- (void)loadDevice:(Device *)device
{
    _device = device;
    [self setNeedsLayout];
}

- (void)clearUI
{
    _titleLabel.text = nil;
    _subtitleLabel.text = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self clearUI];

    _titleLabel.frame = CGRectMake(20, 10, self.contentView.frame.size.width-40, 40);
    _subtitleLabel.frame = CGRectMake(20, 10+40+10, self.contentView.frame.size.width-40, 40);
    
    if (_device)
    {
        _titleLabel.text = _device.location;
        _subtitleLabel.text = _device.server;
    }
}

@end
