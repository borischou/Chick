//
//  UPnPManager+ControlPoint.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/8.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "UPnPManager+ControlPoint.h"
#import "UPnPActionRequest.h"
#import <objc/runtime.h>

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

- (void)setAVTransportURI:(NSString * _Nullable)uri response:(actionResponseHandler _Nullable)responseHandler
{
    NSString *encodedURI = [uri stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self.request addParameterWithKey:@"InstanceID" value:@"0"];
    [self.request addParameterWithKey:@"CurrentURI" value:encodedURI];
    [self.request addParameterWithKey:@"CurrentURIMetaData"];
    [self.request composeRequest];
    
    [self _httpRequest:self.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
        actResp.statusCode = resp.statusCode;
        [self.controlPointDelegate uPnpManager:self didSetAVTransportURI:uri response:actResp];
        responseHandler(actResp, response, error);
    }];
}

- (void)playWithResponse:(actionResponseHandler _Nullable)responseHandler
{
    [self.request addParameterWithKey:@"InstanceID" value:@"0"];
    [self.request addParameterWithKey:@"Speed" value:@"1"];
    [self.request composeRequest];
    
    [self _httpRequest:self.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        [self.controlPointDelegate uPnpManager:self didPlayResponse:actResp];
        responseHandler(actResp, response, error);
    }];
}

- (void)pauseWithResponse:(actionResponseHandler _Nullable)responseHandler
{
    [self.request addParameterWithKey:@"InstanceID" value:@"0"];
    [self.request composeRequest];
    
    [self _httpRequest:self.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        [self.controlPointDelegate uPnpManager:self didPauseResponse:actResp];
        responseHandler(actResp, response, error);
    }];
}

- (void)stopWithResponse:(actionResponseHandler _Nullable)responseHandler
{
    [self.request addParameterWithKey:@"InstanceID" value:@"0"];
    [self.request composeRequest];
    
    [self _httpRequest:self.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        responseHandler(actResp, response, error);
    }];
}

- (void)getTransportInfo:(actionResponseHandler _Nullable)responseHandler
{
    [self.request addParameterWithKey:@"InstanceID" value:@"0"];
    [self.request composeRequest];
    
    [self _httpRequest:self.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        [self.controlPointDelegate uPnpManager:self didGetTransportInfoResponse:actResp];
        responseHandler(actResp, response, error);
    }];
}

- (void)getPositionInfo:(actionResponseHandler _Nullable)responseHandler
{
    [self.request addParameterWithKey:@"InstanceID" value:@"0"];
    [self.request composeRequest];
    
    [self _httpRequest:self.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        [self.controlPointDelegate uPnpManager:self didGetPositionInfoResponse:actResp];
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
