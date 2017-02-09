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
#import "UPnPActionRequest.h"

@interface UPnPManager : NSObject

@property (strong, nonatomic) UPnPActionRequest *request;

+ (instancetype)sharedManager;

- (instancetype)initWithRequest:(UPnPActionRequest *)request;

- (void)setRequest:(UPnPActionRequest *)request;

@end
