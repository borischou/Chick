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

- (void)setAVTransportURI:(NSString * _Nullable)uri response:(actionResponseHandler _Nullable)handler
{
    NSString *encodedURI = [uri stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self.request addParameterWithKey:@"InstanceID" value:@"0"];
    [self.request addParameterWithKey:@"CurrentURI" value:encodedURI];
    [self.request addParameterWithKey:@"CurrentURIMetaData"];
    [self.request composeRequest];
    
    [self _httpRequest:self.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        handler(actResp, response, error);
    }];
}

- (void)playWithResponse:(actionResponseHandler _Nullable)handler
{
    [self.request addParameterWithKey:@"InstanceID" value:@"0"];
    [self.request addParameterWithKey:@"Speed" value:@"1"];
    [self.request composeRequest];
    
    [self _httpRequest:self.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        handler(actResp, response, error);
    }];
}

- (void)_httpRequest:(UPnPActionRequest *)request completionHandler:(completionHandler)handler
{
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        handler(data, response, error);
    }] resume];
}

@end
