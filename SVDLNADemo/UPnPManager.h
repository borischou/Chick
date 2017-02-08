//
//  UPnPManager.h
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/8.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Address.h"

@interface UPnPManager : NSObject

@property (strong, nonatomic) Address *address;

+ (instancetype)sharedManager;

@end
