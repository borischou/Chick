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

#define dispatch_async_main_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

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
        dispatch_async_main_safe(^{
            responseHandler(actResp, response, error);
        });
    }];
}

- (void)playWithResponse:(ActionResponseHandler)responseHandler
{
    [self.request addParameterWithKey:@"InstanceID" value:@"0"];
    [self.request addParameterWithKey:@"Speed" value:@"1"];
    [self.request composeRequest];
    
    [self _httpRequest:self.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        [self.controlPointDelegate uPnpManager:self didPlayResponse:actResp];
        dispatch_async_main_safe(^{
            responseHandler(actResp, response, error);
        });
    }];
}

- (void)pauseWithResponse:(ActionResponseHandler)responseHandler
{
    [self.request addParameterWithKey:@"InstanceID" value:@"0"];
    [self.request composeRequest];
    
    [self _httpRequest:self.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        [self.controlPointDelegate uPnpManager:self didPauseResponse:actResp];
        dispatch_async_main_safe(^{
            responseHandler(actResp, response, error);
        });
    }];
}

- (void)stopWithResponse:(ActionResponseHandler)responseHandler
{
    [self.request addParameterWithKey:@"InstanceID" value:@"0"];
    [self.request composeRequest];
    
    [self _httpRequest:self.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        dispatch_async_main_safe(^{
            responseHandler(actResp, response, error);
        });
    }];
}

- (void)getTransportInfo:(ActionResponseHandler)responseHandler
{
    [self.request addParameterWithKey:@"InstanceID" value:@"0"];
    [self.request composeRequest];
    
    [self _httpRequest:self.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        [self.controlPointDelegate uPnpManager:self didGetTransportInfoResponse:actResp];
        dispatch_async_main_safe(^{
            responseHandler(actResp, response, error);
        });
    }];
}

- (void)getPositionInfo:(ActionResponseHandler)responseHandler
{
    [self.request addParameterWithKey:@"InstanceID" value:@"0"];
    [self.request composeRequest];
    
    [self _httpRequest:self.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UPnPActionResponse *actResp = [[UPnPActionResponse alloc] initWithData:data];
        [self.controlPointDelegate uPnpManager:self didGetPositionInfoResponse:actResp];
        dispatch_async_main_safe(^{
            responseHandler(actResp, response, error);
        });
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
