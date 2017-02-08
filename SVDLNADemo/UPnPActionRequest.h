//
//  UPnPActionRequest.h
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/8.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Address.h"

@interface UPnPActionRequest : NSMutableURLRequest

- (instancetype)initWithAddress:(Address *)address pathControlURL:(NSString *)pathControlURL;

/*
 * 添加动作参数的键值对
 */
- (void)addParameterWithKey:(NSString * _Nonnull)key value:(NSString * _Nonnull)value;

/*
 * 只能在参数添加完毕后调用
 */
- (NSData * _Nonnull)composeBodyData;

@end
