//
//  Device.h
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/7.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Address.h"
#import "DeviceDescription.h"
#import "SsdpResponseHeader.h"

@interface Device : NSObject

@property (strong, nonatomic) DeviceDescription *ddd;
@property (strong, nonatomic) Address *address;
@property (copy, nonatomic) NSString *location;
@property (copy, nonatomic) NSString *maxAge;
@property (copy, nonatomic) NSString *server;
@property (copy, nonatomic) NSString *bootid_upnp_org;
@property (copy, nonatomic) NSString *configid_upnp_org;
@property (copy, nonatomic) NSString *usn;
@property (copy, nonatomic) NSString *st;
@property (copy, nonatomic) NSString *date;

- (instancetype)initWithSsdpResponse:(SsdpResponseHeader *)header;

@end
