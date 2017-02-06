//
//  HttpRespHeaderExtension.h
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/6.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HttpResponseHeader;
@interface HttpRespHeaderExtension : NSObject

@property (copy, nonatomic) NSString *bootid_upnp_org;
@property (copy, nonatomic) NSString *configid_upnp_org;
@property (copy, nonatomic) NSString *usn;
@property (copy, nonatomic) NSString *st;
@property (weak, nonatomic) HttpResponseHeader *header;

- (instancetype)initFromHeaderMsg:(NSString *)message responseHeader:(HttpResponseHeader *)header;

@end
