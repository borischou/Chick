//
//  HttpResponseHeader.h
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/6.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpRespHeaderExtension.h"

@interface HttpResponseHeader : NSObject

@property (copy, nonatomic) NSString *statusCode;
@property (copy, nonatomic) NSString *location;
@property (copy, nonatomic) NSString *maxAge;
@property (copy, nonatomic) NSArray *serverInfo;
@property (strong, nonatomic) HttpRespHeaderExtension *ext;

- (instancetype)initWithReceivedMsg:(NSString *)message;

@end
