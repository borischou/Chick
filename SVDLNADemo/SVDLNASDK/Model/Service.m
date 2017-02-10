//
//  Service.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/7.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "Service.h"
#import "XMLDictionary.h"

@implementation Service

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        if (dictionary == nil)
        {
            return nil;
        }
        _serviceID = [dictionary stringValueForKeyPath:@"serviceId"];
        _serviceType = [dictionary stringValueForKeyPath:@"serviceType"];
        _SCPDURL = [dictionary stringValueForKeyPath:@"SCPDURL"];
        _controlURL = [dictionary stringValueForKeyPath:@"controlURL"];
        _eventSubURL = [dictionary stringValueForKeyPath:@"eventSubURL"];
    }
    return self;
}

@end
