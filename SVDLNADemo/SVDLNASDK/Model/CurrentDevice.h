//
//  CurrentDevice.h
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/9.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Device.h"

@interface CurrentDevice : NSObject

+ (_Nullable instancetype)sharedDevice;

- (void)setDevice:(Device * _Nullable)device;

- (void)setServices:(NSArray<Service *> * _Nullable)services;

- (void)resetDevice;

@property (strong, nonatomic, readonly) Device * _Nullable device;

@property (copy, nonatomic, readonly) NSArray<Service *> * _Nullable services;

@end
