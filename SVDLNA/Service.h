//
//  Service.h
//  SVDLNADemo
//
//  Created by  bolizhou on 17/2/7.
//  Copyright © 2017年  bolizhou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Argument : NSObject

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *direction;
@property (copy, nonatomic) NSString *relatedStateVariable;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

@interface Action : NSObject

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSArray<Argument *> *arguments;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

@interface AllowedValueRange : NSObject

@property (copy, nonatomic) NSString *minimum;
@property (copy, nonatomic) NSString *maximum;
@property (copy, nonatomic) NSString *step;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

@interface StateVariable : NSObject

@property (nonatomic) BOOL isMulticast;
@property (nonatomic) BOOL sendEvents;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *dataType;
@property (copy, nonatomic) NSString *defaultValue;
@property (strong, nonatomic) AllowedValueRange *allowedValueRange;

@end

@class Service;

@interface ServiceDescription : NSObject

@property (copy, nonatomic) NSArray<Action *> *actions;
@property (weak, nonatomic) Service *service;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

@interface Service : NSObject

@property (copy, nonatomic) NSString *serviceID;
@property (copy, nonatomic) NSString *serviceType;
@property (copy, nonatomic) NSString *SCPDURL;
@property (copy, nonatomic) NSString *controlURL;
@property (copy, nonatomic) NSString *eventSubURL;
@property (strong, nonatomic) ServiceDescription *sdd;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
