//
//  Address.h
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/7.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Address : NSObject

@property (copy, nonatomic) NSString *ipv4;
@property (copy, nonatomic) NSString *ipv6;
@property (copy, nonatomic) NSString *port;

@end
