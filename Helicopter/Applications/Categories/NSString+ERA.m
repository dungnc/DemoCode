//
//  NSString+ERA.m
//  Helicopter
//
//  Created by Nguyen Chi Dung on 4/24/14.
//  Copyright (c) 2014 Nguyen Chi Dung. All rights reserved.
//

#import "NSString+ERA.h"

@implementation NSString (ERA)

- (NSString *)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL)isValidEmail {
	BOOL stricterFilter = YES;
	NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
	NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
	NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
	NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
	return [emailTest evaluateWithObject:self];
}
+(NSString *)getUUID {
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
    NSString * uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    CFRelease(newUniqueId);
    
    return uuidString;
}

@end
