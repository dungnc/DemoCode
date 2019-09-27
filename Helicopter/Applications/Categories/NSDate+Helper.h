//
//  NSDate+Helper.h
//  Helicopter
//
//  Created by Nguyen Chi Dung on 2/26/14.
//  Copyright (c) 2014 Nguyen Chi Dung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Helper)

- (NSInteger)numberMinutesToDate:(NSDate*)toDate;
+ (NSDateFormatter*)sharedDateFormatterX;
- (NSDate*)removeDateAndSecond;
- (NSDate*)addCurrentDate;
+ (NSDate*)sharedDateValueFromString:(NSString*)dateString;
+ (NSDate*)sharedNewDateValueFromString:(NSString*)dateString;
+ (void)saveLastSyncDate;
+ (NSString *)lastSyncDate;
@end
