//
//  StateVariable.h
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/8.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AllowedValueRange.h"

@interface StateVariable : NSObject

@property (nonatomic) BOOL isMulticast;
@property (nonatomic) BOOL sendEvents;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *dataType;
@property (copy, nonatomic) NSString *defaultValue;
@property (strong, nonatomic) AllowedValueRange *allowedValueRange;

@end
