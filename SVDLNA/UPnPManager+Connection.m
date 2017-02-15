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

- (void)fetchDDDSuccessHandler:(DDDHandler)dddBlk failureHandler:(failureHandler)failBlk
{
    [self _requestDataWithURL:self.device.location successHandler:^(NSData * _Nullable data)
     {
         NSDictionary *dataDict = [NSDictionary dictionaryWithXMLData:data];
         DeviceDescription *ddd = [[DeviceDescription alloc] initWithDictionary:dataDict];
         dddBlk(ddd);
     }
               failureHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
     {
         failBlk(data, response, error);
     }];
}

- (void)fetchSDDSuccessHandler:(SDDHandler)sddBlk failureHandler:(failureHandler)failBlk
{
    NSString *url = nil;
    if ([self.service.SCPDURL hasPrefix:@"/"])
    {
        url = [NSString stringWithFormat:@"%@:%@%@", self.device.address.ipv4, self.device.address.port, self.service.SCPDURL];
    }
    else
    {
        url = [NSString stringWithFormat:@"%@:%@/%@", self.device.address.ipv4, self.device.address.port, self.service.SCPDURL];
    }
    NSString *urlStr = nil;
    if ([url hasPrefix:@"http"] == NO)
    {
        urlStr = [NSString stringWithFormat:@"http://%@", url];
    }
    else
    {
        urlStr = url;
    }
    [self _requestDataWithURL:urlStr successHandler:^(NSData * _Nullable data)
     {
         NSDictionary *dataDict = [NSDictionary dictionaryWithXMLData:data];
         ServiceDescription *sdd = [[ServiceDescription alloc] initWithDictionary:dataDict];
         sddBlk(sdd);
     }
               failureHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
     {
         failBlk(data, response, error);
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
