//
//  UPnPManager.h
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/8.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Address.h"
#import "Service.h"

@interface UPnPManager : NSObject

@property (strong, nonatomic) Address *address;
@property (strong, nonatomic) Service *service;
@property (strong, nonatomic) Action *action;

+ (instancetype)sharedManager;

@end
