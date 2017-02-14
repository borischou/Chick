//
//  DeviceDescription.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/7.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "Device.h"
#import "XMLDictionary.h"

@implementation DeviceDescription

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        if (dictionary == nil)
        {
            return nil;
        }
        
        NSDictionary *aDict = [dictionary dictionaryValueForKeyPath:@"device"];
        if (aDict == nil)
        {
            return nil;
        }
        
        _udn = [aDict stringValueForKeyPath:@"UDN"];
        _deviceType = [aDict stringValueForKeyPath:@"deviceType"];
        _friendlyName = [aDict stringValueForKeyPath:@"friendlyName"];
        _manufacturer = [aDict stringValueForKeyPath:@"manufacturer"];
        _manufacturerURL = [aDict stringValueForKeyPath:@"manufacturerURL"];
        _modelName = [aDict stringValueForKeyPath:@"modelName"];
        _modelDescription = [aDict stringValueForKeyPath:@"modelDescription"];
        
        NSMutableArray *services = [NSMutableArray new];
        NSArray *serviceList = [aDict arrayValueForKeyPath:@"serviceList.service"];
        if (serviceList != nil && serviceList.count > 0)
        {
            for (NSDictionary *service in serviceList)
            {
                Service *serv = [[Service alloc] initWithDictionary:service];
                [services addObject:serv];
            }
        }
        _services = services.copy;
    }
    return self;
}

@end
