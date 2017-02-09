//
//  CurrentDevice.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/9.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "CurrentDevice.h"

@interface CurrentDevice ()

@property (strong, nonatomic) Device *device;

@end

@implementation CurrentDevice

+ (instancetype)sharedDevice
{
    static CurrentDevice *currentDevice;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (currentDevice == nil)
        {
            currentDevice = [[CurrentDevice alloc] init];
        }
    });
    return currentDevice;
}

- (void)setDevice:(Device *)device
{
    _device = device;
}

@end
