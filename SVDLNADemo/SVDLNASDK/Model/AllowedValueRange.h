//
//  AllowedValueRange.h
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/8.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AllowedValueRange : NSObject

@property (copy, nonatomic) NSString *minimum;
@property (copy, nonatomic) NSString *maximum;
@property (copy, nonatomic) NSString *step;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
