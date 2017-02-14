//
//  Device.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/7.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "Device.h"

@implementation Device

- (instancetype)initWithSsdpResponse:(SsdpResponseHeader *)header
{
    self = [super init];
    if (self)
    {
        _address = header.address;
        _location = header.location.copy;
        _server = header.server.copy;
        _maxAge = header.maxAge.copy;
        _usn = header.usn.copy;
        _bootid_upnp_org = header.bootid_upnp_org.copy;
        _configid_upnp_org = header.configid_upnp_org.copy;
        _st = header.st.copy;
        _date = header.date.copy;
    }
    return self;
}

@end