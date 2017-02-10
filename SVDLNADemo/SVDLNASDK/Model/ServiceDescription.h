//
//  ServiceDescription.h
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/7.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Action.h"

@class Service;
@interface ServiceDescription : NSObject

@property (copy, nonatomic) NSArray<Action *> *actions;
@property (weak, nonatomic) Service *service;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
