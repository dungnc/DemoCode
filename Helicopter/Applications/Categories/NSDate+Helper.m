//
//  NSDate+Helper.m
//  Helicopter
//
//  Created by Nguyen Chi Dung on 2/26/14.
//  Copyright (c) 2014 Nguyen Chi Dung. All rights reserved.
//

#import "NSDate+Helper.h"
#import "Singleton.h"

NSString *const kLastSyncDate = @"last_sync_date";

@implementation NSDate (Helper)

- (NSDate*)removeDateAndSecond{
    return [[NSDate sharedDateFormatterX] dateFromString:[[NSDate sharedDateFormatterX] stringFromDate:self]];
}

+ (NSDateFormatter*) sharedDateFormatterX {
    static NSDateFormatter *sharedDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDateFormatter = [NSDateFormatter new];
        [sharedDateFormatter setLocale:[NSLocale currentLocale]];
        [sharedDateFormatter setDateFormat:@"HH:mm"];
    });
    
    return sharedDateFormatter;
}

+ (NSDate*)sharedNewDateValueFromString:(NSString*)dateString {
    static NSDateFormatter *sharedDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [sharedDateFormatter setDateFormat:@"yyyy'/'MM'/'dd HH:mm:ss"];
    });
    return [sharedDateFormatter dateFromString:dateString];
}

+ (NSDate*)sharedDateValueFromString:(NSString*)dateString {
   static NSDateFormatter *sharedDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [sharedDateFormatter setLocale:[NSLocale currentLocale]];
        [sharedDateFormatter setDateFormat:@"yyyy'/'MM'/'dd HH:mm:ss"];
        //[sharedDateFormatter setDateFormat:@"yyyy'-'MM'-'dd' 'HH':'mm':'ss'"];
    });
    return [sharedDateFormatter dateFromString:dateString];
}

+ (NSDateFormatter*) sharedFullDateFormatter {
    static NSDateFormatter *sharedDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDateFormatter = [NSDateFormatter new];
        [sharedDateFormatter setLocale:[NSLocale currentLocale]];
        [sharedDateFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
    });
    
    return sharedDateFormatter;
}

- (NSInteger)numberMinutesToDate:(NSDate*)toDate {
    NSDateComponents *components = [[Singleton sharedCalendar] components:NSMinuteCalendarUnit
                                                                 fromDate:[self removeDateAndSecond]
                                                                   toDate:[toDate removeDateAndSecond] options:0];
    return [components minute];
}

- (NSDate*)addCurrentDate {
    NSString *fullDate = [NSString stringWithFormat:@"%@ %@", [[Singleton sharedDateFormatter] stringFromDate:[NSDate date]], [[NSDate sharedDateFormatterX] stringFromDate:self]];
    return [[NSDate sharedFullDateFormatter] dateFromString:fullDate];
}

+ (void)saveLastSyncDate {
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate new] forKey:kLastSyncDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)lastSyncDate {
    NSDate *lastSync = [[NSUserDefaults standardUserDefaults] objectForKey:kLastSyncDate];
    if (lastSync) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateFormat:@"yyyy'/'MM'/'dd HH:mm:ss"];
        return [formatter stringFromDate:lastSync];
    }
    return @"2014/01/01 00:00:00";
}

@end
