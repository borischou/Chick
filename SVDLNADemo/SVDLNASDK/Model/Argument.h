//
//  Argument.h
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/7.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Argument : NSObject

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *direction;
@property (copy, nonatomic) NSString *relatedStateVariable;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
