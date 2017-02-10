//
//  SsdpResponseHeader.h
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/6.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Address.h"

@interface SsdpResponseHeader : NSObject

@property (copy, nonatomic) NSString *statusCode;
@property (copy, nonatomic) NSString *location;
@property (copy, nonatomic) NSString *maxAge;
@property (copy, nonatomic) NSString *server;
@property (copy, nonatomic) NSString *bootid_upnp_org;
@property (copy, nonatomic) NSString *configid_upnp_org;
@property (copy, nonatomic) NSString *usn;
@property (copy, nonatomic) NSString *st;
@property (copy, nonatomic) NSString *date;

@property (strong, nonatomic) Address *address;

- (instancetype)initWithReceivedMsg:(NSString *)message;

@end
