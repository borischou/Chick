//
//  DeviceDescription.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/7.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "DeviceDescription.h"
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
        _udn = [dictionary stringValueForKeyPath:@"UDN"];
        _deviceType = [dictionary stringValueForKeyPath:@"deviceType"];
        _friendlyName = [dictionary stringValueForKeyPath:@"friendlyName"];
        _manufacturer = [dictionary stringValueForKeyPath:@"manufacturer"];
        _manufacturerURL = [dictionary stringValueForKeyPath:@"manufacturerURL"];
        _modelName = [dictionary stringValueForKeyPath:@"modelName"];
        _modelDescription = [dictionary stringValueForKeyPath:@"modelDescription"];
        
        NSMutableArray *services = [NSMutableArray new];
        NSArray *serviceList = [dictionary arrayValueForKeyPath:@"serviceList"];
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
