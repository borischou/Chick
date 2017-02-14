//
//  UPnPManager+ControlPoint.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/8.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "UPnPManager.h"
#import "UPnPActionRequest.h"
#import <objc/runtime.h>

typedef void(^completionHandler)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

static NSString *const KEY_SHARED_SESSION = @"sharedSessionKey";

@interface UPnPManager ()

@property (strong, nonatomic) NSURLSession *sharedSession;

@end

@implementation UPnPManager (ControlPoint)

- (NSURLSession *)sharedSession
{
    return objc_getAssociatedObject(self, (__bridge const void *)(KEY_SHARED_SESSION));
}

- (void)setSharedSession:(NSURLSession *)sharedSession
{
    objc_setAssociatedObject(self, (__bridge const void *)(KEY_SHARED_SESSION), sharedSession, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setAVTransportURI:(NSString * _Nullable)uri response:(ActionResponseHandler)responseHandler
{
    UPnPActionRequest *request = [[UPnPActionRequest alloc] initWithActionName:@"SetAVTransportURI"];
    request.service = self.service;
    request.device = self.device;
    NSString *encodedURI = uri.stringByRemovingPercentEncoding;
    [request addParameterWithKey:@"InstanceID" value:@"0"];
    [request addParameterWithKey:@"CurrentURI" value:encodedURI];
    [request addParameterWithKey:@"CurrentURIMetaData" value:@""];
    [request composeRequest];
    
    [self _httpRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
        actResp.statusCode = resp.statusCode;
        if ([self.controlPointDelegate respondsToSelector:@selector(uPnpManager:didSetAVTransportURI:response:)])
        {
            [self.controlPointDelegate uPnpManager:self didSetAVTransportURI:uri response:actResp];
        }
        responseHandler(actResp, response, error);
    }];
}

- (void)setNextAVTransportURI:(NSString *)uri response:(ActionResponseHandler)responseHandler
{
    UPnPActionRequest *request = [[UPnPActionRequest alloc] initWithActionName:@"SetNextAVTransportURI"];
    request.service = self.service;
    request.device = self.device;
    NSString *encodedURI = uri.stringByRemovingPercentEncoding;
    [request addParameterWithKey:@"InstanceID" value:@"0"];
    [request addParameterWithKey:@"NextURI" value:encodedURI];
    [request addParameterWithKey:@"NextURIMetaData" value:@""];
    [request composeRequest];
    
    [self _httpRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
        actResp.statusCode = resp.statusCode;
        if ([self.controlPointDelegate respondsToSelector:@selector(uPnpManager:didSetNextAVTransportURI:response:)])
        {
            [self.controlPointDelegate uPnpManager:self didSetNextAVTransportURI:uri response:actResp];
        }
        responseHandler(actResp, response, error);
    }];
}

- (void)seekTo:(NSString *)target response:(ActionResponseHandler)responseHandler
{
    UPnPActionRequest *request = [[UPnPActionRequest alloc] initWithActionName:@"Seek"];
    request.service = self.service;
    request.device = self.device;
    [request addParameterWithKey:@"InstanceID" value:@"0"];
    [request addParameterWithKey:@"Unit" value:@"REL_TIME"];
    [request addParameterWithKey:@"Target" value:@"00:00:01"];
    [request composeRequest];
    
    [self _httpRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
        actResp.statusCode = resp.statusCode;
        if ([self.controlPointDelegate respondsToSelector:@selector(uPnpManager:didSeekTo:response:)])
        {
            [self.controlPointDelegate uPnpManager:self didSeekTo:target response:actResp];
        }
        responseHandler(actResp, response, error);
    }];
}

- (void)playWithResponse:(ActionResponseHandler)responseHandler
{
    UPnPActionRequest *request = [[UPnPActionRequest alloc] initWithActionName:@"Play"];
    request.service = self.service;
    request.device = self.device;
    [request addParameterWithKey:@"InstanceID" value:@"0"];
    [request addParameterWithKey:@"Speed" value:@"1"];
    [request composeRequest];
    
    [self _httpRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        if ([self.controlPointDelegate respondsToSelector:@selector(uPnpManager:didPlayResponse:)])
        {
            [self.controlPointDelegate uPnpManager:self didPlayResponse:actResp];
        }
        responseHandler(actResp, response, error);
    }];
}

- (void)pauseWithResponse:(ActionResponseHandler)responseHandler
{
    UPnPActionRequest *request = [[UPnPActionRequest alloc] initWithActionName:@"Pause"];
    request.service = self.service;
    request.device = self.device;
    [request addParameterWithKey:@"InstanceID" value:@"0"];
    [request composeRequest];
    
    [self _httpRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        if ([self.controlPointDelegate respondsToSelector:@selector(uPnpManager:didPauseResponse:)])
        {
            [self.controlPointDelegate uPnpManager:self didPauseResponse:actResp];
        }
        responseHandler(actResp, response, error);
    }];
}

- (void)stopWithResponse:(ActionResponseHandler)responseHandler
{
    UPnPActionRequest *request = [[UPnPActionRequest alloc] initWithActionName:@"Stop"];
    request.service = self.service;
    request.device = self.device;
    [request addParameterWithKey:@"InstanceID" value:@"0"];
    [request composeRequest];
    
    [self _httpRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        if ([self.controlPointDelegate respondsToSelector:@selector(uPnpManager:didStopResponse:)])
        {
            [self.controlPointDelegate uPnpManager:self didStopResponse:actResp];
        }
        responseHandler(actResp, response, error);
    }];
}

- (void)getTransportInfo:(ActionResponseHandler)responseHandler
{
    UPnPActionRequest *request = [[UPnPActionRequest alloc] initWithActionName:@"GetTransportInfo"];
    request.service = self.service;
    request.device = self.device;
    [request addParameterWithKey:@"InstanceID" value:@"0"];
    [request composeRequest];
    
    [self _httpRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        if ([self.controlPointDelegate respondsToSelector:@selector(uPnpManager:didGetTransportInfoResponse:)])
        {
            [self.controlPointDelegate uPnpManager:self didGetTransportInfoResponse:actResp];
        }
        responseHandler(actResp, response, error);
    }];
}

- (void)getPositionInfo:(ActionResponseHandler)responseHandler
{
    UPnPActionRequest *request = [[UPnPActionRequest alloc] initWithActionName:@"GetPositionInfo"];
    request.service = self.service;
    request.device = self.device;
    [request addParameterWithKey:@"InstanceID" value:@"0"];
    [request composeRequest];
    
    [self _httpRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        if ([self.controlPointDelegate respondsToSelector:@selector(uPnpManager:didGetPositionInfoResponse:)])
        {
            [self.controlPointDelegate uPnpManager:self didGetPositionInfoResponse:actResp];
        }
        responseHandler(actResp, response, error);
    }];
}

- (void)getCurrentTransportActions:(ActionResponseHandler)responseHandler
{
    UPnPActionRequest *request = [[UPnPActionRequest alloc] initWithActionName:@"GetCurrentTransportActions"];
    request.service = self.service;
    request.device = self.device;
    [request addParameterWithKey:@"InstanceID" value:@"0"];
    [request composeRequest];
    
    [self _httpRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        responseHandler(actResp, response, error);
    }];
}

#pragma mark - Private

- (void)_httpRequest:(UPnPActionRequest *)request completionHandler:(completionHandler)handler
{
    if (self.sharedSession == nil)
    {
        self.sharedSession = [NSURLSession sharedSession];
    }
    NSURLSession *session = self.sharedSession;
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        handler(data, response, error);
    }] resume];
}

@end