//
//  DeviceDescription.h
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/7.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Service.h"

@class Device;
@interface DeviceDescription : NSObject

@property (copy, nonatomic) NSString *deviceType;
@property (copy, nonatomic) NSString *friendlyName;
@property (copy, nonatomic) NSString *manufacturer;
@property (copy, nonatomic) NSString *manufacturerURL;
@property (copy, nonatomic) NSString *modelDescription;
@property (copy, nonatomic) NSString *modelName;
@property (copy, nonatomic) NSString *udn;
@property (copy, nonatomic) NSArray<Service *> *services;
@property (copy, nonatomic) NSArray<Device *> *devices;
@property (weak, nonatomic) Device *device;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
