//
//  Singleton.h
//  Helicopter
//
//  Created by Nguyen Chi Dung on 1/3/14.
//  Copyright (c) 2014 Nguyen Chi Dung. All rights reserved.
//
#import "ERA_Employee.h"

@class ERA_Model;

@interface Singleton : NSObject

+ (id)sharedManager;
+ (NSCalendar*)sharedCalendar;
+ (NSDateFormatter*) sharedDateFormatter;
+ (NSDateFormatter*) sharedDateFormatter1;
+ (NSDateFormatter*)sharedFullDateFormatter;
+ (NSDateFormatter*) sharedTimeFormatter;
+ (BOOL)checkNetworkStatus;
+ (BOOL)isNumeric:(NSString*)string ;
+ (BOOL)isFloat:(NSString*)string ;
- (void)setFltTime:(int)aFlightTime;
- (int)getFltTime;
- (void)setListLogLocation:(NSMutableArray *)aList;
- (NSMutableArray*)getListLogLocation;
- (void)setModeObj:(ERA_Model*)aMode;
- (ERA_Model*)getModeObj;
- (void)setEmployeeLogin:(ERA_Employee *)aEmployeeLogin;
- (ERA_Employee*)getEmployeeLogin;
- (void)setLocationNames:(NSArray *)locationNames;
- (NSArray *)getLocationNames;
- (void)setBaseNames:(NSArray *)baseNames;
- (NSArray *)getBaseNames;
- (void)setContractCharterUsing:(int)contractID;
- (int)getContractCharterUsing;
- (void)setJobNameUsing:(int)jobID;
- (int)getJobNameUsing;
- (void)setCustomerUsing:(int)customerID;
- (int)getCustomerUsing;

@end
