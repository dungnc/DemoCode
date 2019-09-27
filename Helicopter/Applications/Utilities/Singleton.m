//
//  Singleton.m
//  Helicopter
//
//  Created by Nguyen Chi Dung on 1/3/14.
//  Copyright (c) 2014 Nguyen Chi Dung. All rights reserved.
//

#import "Singleton.h"
#import "ERA_Employee.h"
#import "ERA_Model.h"

@interface Singleton () {
}

@property (nonatomic, assign) int fltTime;
@property (nonatomic, strong) NSMutableArray *listLogLocation;
@property (nonatomic, strong) ERA_Employee *employeeObj;
@property (nonatomic, strong) ERA_Model *mode;
@property (nonatomic, assign) int customer_id;
@property (nonatomic, strong) NSArray *locationNames;
@property (nonatomic, strong) NSArray *baseNames;
@property (nonatomic, assign) int contractCharterUsing;
@property (nonatomic, assign) int jobNameUsing;

@end

@implementation Singleton

+ (NSCalendar*)sharedCalendar {
    static NSCalendar *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        [sharedInstance setLocale:[NSLocale currentLocale]];
    });
    return sharedInstance;
}

+ (id)sharedManager {
    static Singleton *sharedSingleton = nil;
    @synchronized(self) {
        if (sharedSingleton == nil) {
            sharedSingleton = [[self alloc] init];
        }
    }
    return sharedSingleton;
}

+ (NSDateFormatter*)sharedDateFormatter {
    static NSDateFormatter *sharedDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDateFormatter = [NSDateFormatter new];
        [sharedDateFormatter setLocale:[NSLocale currentLocale]];
        [sharedDateFormatter setDateFormat:@"MM/dd/yyyy"];
    });
    
    return sharedDateFormatter;
}
+ (NSDateFormatter*)sharedDateFormatter1 {
    static NSDateFormatter *sharedDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDateFormatter = [NSDateFormatter new];
        [sharedDateFormatter setLocale:[NSLocale currentLocale]];
        [sharedDateFormatter setDateFormat:@"yyyy-MM-dd"];
    });
    
    return sharedDateFormatter;
}
+ (NSDateFormatter*)sharedFullDateFormatter {
    static NSDateFormatter *sharedDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDateFormatter = [NSDateFormatter new];
        [sharedDateFormatter setLocale:[NSLocale currentLocale]];
        [sharedDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    });
    
    return sharedDateFormatter;
}
+ (NSDateFormatter*)sharedTimeFormatter {
    static NSDateFormatter *sharedTimeFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTimeFormatter = [NSDateFormatter new];
        [sharedTimeFormatter setLocale:[NSLocale currentLocale]];
        [sharedTimeFormatter setDateFormat:@"HH:mm"];
    });
    
    return sharedTimeFormatter;
}

+ (BOOL)checkNetworkStatus{
    return NO;
}

#pragma mark Get/Set methods
- (void)setLocationNames:(NSArray *)locationNames {
    _locationNames = locationNames;
}

- (NSArray *)getLocationNames {
    return _locationNames;
}

- (void)setBaseNames:(NSArray *)baseNames {
    _baseNames = baseNames;
}

- (NSArray *)getBaseNames {
    return _baseNames;
}

- (void)setFltTime:(int)aFlightTime{
    _fltTime = aFlightTime;
}

- (int)getFltTime{
    return _fltTime;
}

- (void)setListLogLocation:(NSMutableArray *)aList{
    _listLogLocation = aList;
}

- (NSMutableArray*)getListLogLocation{
    return _listLogLocation;
}

- (void)setEmployeeLogin:(ERA_Employee *)aEmployeeLogin{
    _employeeObj = aEmployeeLogin;
}

- (ERA_Employee*)getEmployeeLogin{
    return _employeeObj;
}

- (void)setModeObj:(ERA_Model*)aMode{
    _mode = aMode;
}

- (ERA_Model*)getModeObj{
    return _mode;
}

- (void)setCustomerUsing:(int)customerID {
    _customer_id = customerID;
}

- (int)getCustomerUsing {
    return _customer_id;
}

#pragma mark - Helper methods
+ (BOOL)isNumeric:(NSString*)string {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *number = [formatter numberFromString:string];
    return number!=nil;
}

+ (BOOL)isFloat:(NSString*)string {
    NSScanner *scanner = [NSScanner scannerWithString:string];
    [scanner scanFloat:NULL];
    return [scanner isAtEnd];
}

- (void)setContractCharterUsing:(int)contractID {
    _contractCharterUsing = contractID;
}

- (int)getContractCharterUsing {
    return _contractCharterUsing;
}

- (void)setJobNameUsing:(int)jobID {
    _jobNameUsing = jobID;
}

- (int)getJobNameUsing {
    return _jobNameUsing;
}

@end
