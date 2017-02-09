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

+ (instancetype)sharedDevice;

- (void)setDevice:(Device *)device;

@property (strong, nonatomic, readonly) Device *device;

@end
