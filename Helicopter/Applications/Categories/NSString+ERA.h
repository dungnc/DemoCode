//
//  NSString+ERA.h
//  Helicopter
//
//  Created by Nguyen Chi Dung on 4/24/14.
//  Copyright (c) 2014 Nguyen Chi Dung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ERA)

- (NSString *)trim;
- (BOOL)isValidEmail;
+ (NSString *)getUUID;
@end
