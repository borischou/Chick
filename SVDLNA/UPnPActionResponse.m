//
//  UPnPActionResponse.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/9.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "UPnPManager.h"
#import "XMLDictionary.h"

@implementation UPnPActionResponse

- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self)
    {
        if (data == nil)
        {
            return nil;
        }
        NSDictionary *dict = [NSDictionary dictionaryWithXMLData:data];
        _xmlDictionary = dict;
        _errorCode = [dict stringValueForKeyPath:@""];
        _errorDescription = [dict stringValueForKeyPath:@""];
    }
    return self;
}

@end
