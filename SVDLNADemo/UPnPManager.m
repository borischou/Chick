//
//  UPnPManager.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/8.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "UPnPManager.h"

@interface UPnPManager ()

@end

@implementation UPnPManager

+ (instancetype)sharedManager
{
    static UPnPManager *manager;
    static dispatch_once_t onceToken;
    if (manager == nil)
    {
        dispatch_once(&onceToken, ^{
            manager = [[UPnPManager alloc] init];
            
        });
    }
    return manager;
}

- (instancetype)initWithRequest:(UPnPActionRequest *)request
{
    self = [UPnPManager sharedManager];
    self.request = request;
    return self;
}

- (void)setRequest:(UPnPActionRequest *)request;
{
    _request = request;
}

@end
