//
//  UPnPManager+ControlPoint.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/8.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "UPnPManager+ControlPoint.h"
#import "UPnPActionRequest.h"

typedef void(^successHandler)(NSData * _Nullable data);
typedef void(^failureHandler)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

@implementation UPnPManager (ControlPoint)

- (void)setAVTransportURI:(NSString *)uri pathControlURL:(NSString *)pathControlURL
{
    UPnPActionRequest *request = [[UPnPActionRequest alloc] initWithAddress:self.address pathControlURL:pathControlURL];
}

- (void)_httpPostWithRequest:(UPnPActionRequest *)request successHandler:(successHandler)succBlk failureHandler:(failureHandler)failBlk
{
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data == nil || data.length == 0 || error != nil)
        {
            failBlk(data, response, error);
        }
        else
        {
            succBlk(data);
        }
    }] resume];
}

@end
