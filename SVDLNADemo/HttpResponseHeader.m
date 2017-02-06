//
//  HttpResponseHeader.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/6.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "HttpResponseHeader.h"

@implementation HttpResponseHeader

- (instancetype)initWithReceivedMsg:(NSString *)message
{
    self = [super init];
    
    if (self)
    {
        if (message == nil || message.length == 0)
        {
            return nil;
        }
        
        [message enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {
            NSArray *items = [line componentsSeparatedByString:@" "];
            NSString *first = [items.firstObject lowercaseString];
            if ([first hasPrefix:@"http/1.1"])
            {
                _statusCode = [items objectAtIndex:1];
            }
            else if ([first hasPrefix:@"location"])
            {
                _location = [items objectAtIndex:1];
            }
            else if ([first hasPrefix:@"cache-control"])
            {
                NSString *maxAgeStr = [items objectAtIndex:1];
                _maxAge = [maxAgeStr substringFromIndex:8];
            }
            else if ([first hasPrefix:@"server"])
            {
                NSMutableArray *mutItems = items.mutableCopy;
                [mutItems removeObjectAtIndex:0];
                _serverInfo = [NSArray arrayWithArray:mutItems];
            }
            else if ([first hasPrefix:@"ext"])
            {
                NSRange range = [message rangeOfString:@"ext" options:NSCaseInsensitiveSearch];
                NSString *extStr = [message substringFromIndex:range.location];
                _ext = [[HttpRespHeaderExtension alloc] initFromHeaderMsg:extStr responseHeader:self];
            }
        }];
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"http/1.1: %@\nlocation: %@\ncache-control: max-age=%@\nserver: %@\next: %@", self.statusCode, self.location, self.maxAge, self.serverInfo, self.ext];
}

@end
