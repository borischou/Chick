//
//  Action.h
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/7.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Argument.h"

@interface Action : NSObject

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSArray<Argument *> *arguments;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
