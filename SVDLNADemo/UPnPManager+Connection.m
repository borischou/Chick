//
//  UPnPManager+Connection.m
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/8.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import "UPnPManager+Connection.h"
#import "XMLDictionary.h"

@implementation UPnPManager (Connection)

- (void)fetchDDDWithLocation:(NSString *)location successHandler:(DDDHandler)dddBlk failureHandler:(failureHandler)failBlk
{
    [self _requestDataWithURL:location successHandler:^(NSData * _Nullable data)
    {
        NSDictionary *dataDict = [NSDictionary dictionaryWithXMLData:data];
        DeviceDescription *ddd = [[DeviceDescription alloc] initWithDictionary:dataDict];
        dispatch_async_main_safe(^{
            dddBlk(ddd);
        });
    }
    failureHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        dispatch_async_main_safe(^{
            failBlk(data, response, error);
        });
    }];
}

- (void)fetchSDDWithLocation:(NSString *)location successHandler:(SDDHandler)dddBlk failureHandler:(failureHandler)failBlk
{
    [self _requestDataWithURL:location successHandler:^(NSData * _Nullable data)
    {
        NSDictionary *dataDict = [NSDictionary dictionaryWithXMLData:data];
        ServiceDescription *sdd = [[ServiceDescription alloc] initWithDictionary:dataDict];
        dispatch_async_main_safe(^{
            dddBlk(sdd);
        });
    }
    failureHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        dispatch_async_main_safe(^{
            failBlk(data, response, error);
        });
    }];
}

#pragma mark - Private

- (void)_requestDataWithURL:(NSString * _Nullable)url
                 successHandler:(successHandler _Nonnull)successblk
                 failureHandler:(failureHandler _Nonnull)failureblk;
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
      {
          if (data && data.length > 0 && error == nil)
          {
              successblk(data);
          }
          else
          {
              failureblk(data, response, error);
          }
      }] resume];
}

@end
