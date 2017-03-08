//
//  Device.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/7.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "Device.h"

@implementation Device

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        _address = [aDecoder decodeObjectForKey:@"dlna_device_address"];
        _location = [aDecoder decodeObjectForKey:@"dlna_device_location"];
        _server = [aDecoder decodeObjectForKey:@"dlna_device_server"];
        _maxAge = [aDecoder decodeObjectForKey:@"dlna_device_maxage"];
        _usn = [aDecoder decodeObjectForKey:@"dlna_device_usn"];
        _bootid_upnp_org = [aDecoder decodeObjectForKey:@"dlna_device_bootid_upnp_org"];
        _configid_upnp_org = [aDecoder decodeObjectForKey:@"dlna_device_configid_upnp_org"];
        _st = [aDecoder decodeObjectForKey:@"dlna_device_st"];
        _date = [aDecoder decodeObjectForKey:@"dlna_device_date"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_address forKey:@"dlna_device_address"];
    [aCoder encodeObject:_location forKey:@"dlna_device_location"];
    [aCoder encodeObject:_server forKey:@"dlna_device_server"];
    [aCoder encodeObject:_maxAge forKey:@"dlna_device_maxage"];
    [aCoder encodeObject:_usn forKey:@"dlna_device_usn"];
    [aCoder encodeObject:_bootid_upnp_org forKey:@"dlna_device_bootid_upnp_org"];
    [aCoder encodeObject:_configid_upnp_org forKey:@"dlna_device_configid_upnp_org"];
    [aCoder encodeObject:_st forKey:@"dlna_device_st"];
    [aCoder encodeObject:_date forKey:@"dlna_device_date"];
}

- (id)copyWithZone:(NSZone *)zone
{
    Device *device = [[Device allocWithZone:zone] init];
    device.address = self.address.copy;
    device.location = self.location.copy;
    device.maxAge = self.maxAge.copy;
    device.server = self.server.copy;
    device.bootid_upnp_org = self.bootid_upnp_org.copy;
    device.configid_upnp_org = self.configid_upnp_org.copy;
    device.usn = self.usn.copy;
    device.st = self.st.copy;
    device.date = self.date.copy;
    return device;
}

- (instancetype)initWithSsdpResponse:(SsdpResponseHeader *)header
{
    self = [super init];
    if (self)
    {
        _address = header.address.copy;
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

- (BOOL)isIPv4Equal:(Device *)object
{
    if ([self.address.ipv4 isEqualToString:object.address.ipv4] && [self.address.port isEqualToString:object.address.port])
    {
        return YES;
    }
    return NO;
}

@end
