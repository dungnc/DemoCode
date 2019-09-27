//
//  FlightLogObject.h
//  Helicopter
//
//  Created by Judge Man on 12/03/15.
//  Copyright (c) 2015 Era Helicopter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlightLogObject : NSObject

@property (nonatomic, assign) NSInteger logNumber;
@property (nonatomic, strong) NSArray *locations;
@property (nonatomic, strong) NSArray *models;
@property (nonatomic, strong) NSArray *customers;
@property (nonatomic, strong) NSArray *employees;
@property (nonatomic, strong) NSArray *slotPurposes;
@property (nonatomic, strong) NSArray *acs;
@property (nonatomic, strong) NSArray *fuelOwners;

+ (FlightLogObject*)flightLogFromDict:(NSDictionary*)dict;

@end
