//
//  Device+Current.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/8.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "Device+Current.h"

@implementation Device (Current)

+ (instancetype)currentDevice
{
    static Device *device = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (device == nil)
        {
            device = [[Device alloc] init];
        }
    });
    return device;
}

@end
