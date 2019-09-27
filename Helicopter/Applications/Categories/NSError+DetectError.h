//
//  NSError+DetectError.h
//  Helicopter
//
//  Created by Hoa Truong on 3/10/15.
//  Copyright (c) 2015 Era Helicopter. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, DResponseStatus) {
    DResponseSuccess = 200,
    DResponseMissingParam = 400,
    DResponseInvalidUsernamePasswordToken = 401,
    DResponseMethodNotAllow = 405,
    DResponseFlightLogAlreadyExists = 409
};
@interface NSError (DetectError)
+ (NSError*)handleErrorWithResponse:(DResponseStatus)responseStatus;
@end
