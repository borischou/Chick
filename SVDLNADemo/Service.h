//
//  Service.h
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/7.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceDescription.h"

@interface Service : NSObject

@property (copy, nonatomic) NSString *serviceID;
@property (copy, nonatomic) NSString *serviceType;
@property (copy, nonatomic) NSString *SCPDURL;
@property (copy, nonatomic) NSString *controlURL;
@property (copy, nonatomic) NSString *eventSubURL;
@property (strong, nonatomic) ServiceDescription *sdd;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
