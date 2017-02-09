//
//  UPnPActionResponse.h
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/9.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Action.h"

@interface UPnPActionResponse : NSObject

@property (copy, nonatomic) NSString *errorCode;
@property (copy, nonatomic) NSString *errorDescription;
@property (copy, nonatomic) NSArray<Action *> *actions;
@property (copy, nonatomic) NSDictionary *xmlDictionary;

- (instancetype)initWithData:(NSData *)data;

@end
