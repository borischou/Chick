//
//  UPnPActionRequest.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/8.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

/***
 content-type必须为text/xml，应包括使用的字符编码，如utf-8
 
 ***/

#import "UPnPActionRequest.h"

@interface UPnPActionRequest ()

@property (strong, nonatomic) Address *address;

@property (copy, nonatomic) NSString *serviceId;
@property (copy, nonatomic) NSString *soapActionName;
@property (copy, nonatomic) NSString *pathControlURL;
@property (copy, nonatomic) NSString *requestURL;
@property (strong, nonatomic) NSData *requestBody;
@property (strong, nonatomic) NSMutableArray<NSString *> *xmlLines;

@end

@implementation UPnPActionRequest

- (instancetype)initWithAddress:(Address *)address pathControlURL:(NSString *)pathControlURL
{
    if (address == nil)
    {
        return nil;
    }
    NSString *url = nil;
    if ([pathControlURL hasPrefix:@"/"])
    {
        url = [NSString stringWithFormat:@"http://%@:%@%@", address.ipv4, address.port, pathControlURL];
    }
    else
    {
        url = [NSString stringWithFormat:@"http://%@:%@/%@", address.ipv4, address.port, pathControlURL];
    }
    self = [super initWithURL:[NSURL URLWithString:url]];
    if (self)
    {
        _address = address;
        _pathControlURL = pathControlURL;
        _requestURL = url;
        self.HTTPMethod = @"POST";
        [self addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
        [self addValue:@"SOAPAction" forHTTPHeaderField:[self _soapAction]];
    }
    return self;
}

- (NSMutableArray<NSString *> *)xmlLines
{
    if (_xmlLines == nil)
    {
        _xmlLines = [NSMutableArray new];
    }
    return _xmlLines;
}

- (void)addParameterWithKey:(NSString * _Nonnull)key value:(NSString * _Nonnull)value
{
    NSString *para = [NSString stringWithFormat:@"<%@>%@</%@>\n", key, value, key];
    [_xmlLines addObject:para];
}

-(void)_addXmlSoapWrapper
{
    NSString *start = [NSString stringWithFormat:@"<?xml version=\"1.0\"?>\n<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\n<s:Body>\n<u:%@ xmlns:u=\"%@\">\n", _soapActionName, _serviceId];
    NSString *end = [NSString stringWithFormat:@"/u:%@\n</s:Body>\n</s:Envelope>\r\n", _soapActionName];
    [_xmlLines insertObject:start atIndex:0];
    [_xmlLines addObject:end];
}

- (NSString *)_soapAction
{
    return [NSString stringWithFormat:@"\"%@#%@\"", _serviceId, _soapActionName];
}

- (NSData *)composeBodyData
{
    if (_xmlLines == nil || _xmlLines.count <= 0)
    {
        return nil;
    }
    [self _addXmlSoapWrapper];
    NSMutableString *mutStr = [NSMutableString new];
    for (NSString *line in _xmlLines)
    {
        [mutStr appendString:line];
    }
    NSData *data = [mutStr dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

@end
