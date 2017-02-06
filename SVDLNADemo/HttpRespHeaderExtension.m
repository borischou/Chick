//
//  HttpRespHeaderExtension.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/6.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "HttpRespHeaderExtension.h"

@implementation HttpRespHeaderExtension

- (instancetype)initFromHeaderMsg:(NSString *)message responseHeader:(HttpResponseHeader *)header
{
    self = [super init];
    if (self)
    {
        if (message == nil || message.length == 0)
        {
            return nil;
        }
        
        _header = header;
        
        [message enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {
            NSArray *items = [line componentsSeparatedByString:@" "];
            NSString *first = [items.firstObject lowercaseString];
            if ([first hasPrefix:@"bootid.upnp.org"])
            {
                _bootid_upnp_org = [items objectAtIndex:1];
            }
            else if ([first hasPrefix:@"configid.upnp.org"])
            {
                _configid_upnp_org = [items objectAtIndex:1];
            }
            else if ([first hasPrefix:@"usn"])
            {
                _usn = [items objectAtIndex:1];
            }
            else if ([first hasPrefix:@"st"])
            {
                _st = [items objectAtIndex:1];
            }
        }];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"bootid_upnp_org: %@\nconfigid_upnp_org: %@\nusn: %@\nst: %@", self.bootid_upnp_org, self.configid_upnp_org, self.usn, self.st];
}

@end
