//
//  UPnPManager+ControlPoint.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/8.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "UPnPManager+ControlPoint.h"
#import "UPnPActionRequest.h"

@implementation UPnPManager (ControlPoint)

- (void)setAVTransportURI:(NSString * _Nullable)uri completion:(completionHandler _Nullable)completion
{
    UPnPActionRequest *request = [[UPnPActionRequest alloc] init];
    request.address = self.address;
    request.action = self.action;
    request.service = self.service;
    [request addParameterWithKey:@"InstanceID" value:@"0"];
    [request addParameterWithKey:@"CurrentURI" value:[uri stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [request addParameterWithKey:@"CurrentURIMetaData"];
    [request composeRequest];
    
    [self _httpPostWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        completion(data, response, error);
    }];
}

- (void)playCompletion:(completionHandler _Nullable)completion
{
    UPnPActionRequest *request = [[UPnPActionRequest alloc] init];
    request.address = self.address;
    request.action = self.action;
    request.service = self.service;
    [request addParameterWithKey:@"InstanceID" value:@"0"];
    [request addParameterWithKey:@"Speed" value:@"1"];
    [request composeRequest];
    
    [self _httpPostWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        completion(data, response, error);
    }];
}

- (void)_httpPostWithRequest:(UPnPActionRequest *)request completionHandler:(completionHandler)handler
{
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        handler(data, response, error);
    }] resume];
}

@end
