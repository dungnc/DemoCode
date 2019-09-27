//
//  NSError+DetectError.m
//  Helicopter
//
//  Created by Hoa Truong on 3/10/15.
//  Copyright (c) 2015 Era Helicopter. All rights reserved.
//

#import "NSError+DetectError.h"

@implementation NSError (DetectError)

+ (NSError*)handleErrorWithResponse:(DResponseStatus)responseStatus {
    switch (responseStatus) {
        case 200:
        {
            return nil;
            break;
        }
        case 400:
        {
            return [NSError errorWithDomain:@"com.private"
                                       code:1000
                                   userInfo:@{NSLocalizedDescriptionKey: @"Missing Param"}];
            break;
        }
        case 401:
        {
            return [NSError errorWithDomain:@"com.private"
                                       code:1000
                                   userInfo:@{NSLocalizedDescriptionKey: @"Incorrect email, password or token, please try again."}];
            break;
        }
        case 405:
        {
            return [NSError errorWithDomain:@"com.private"
                                       code:1000
                                   userInfo:@{NSLocalizedDescriptionKey: @"Method Not Allow."}];
            break;
        }
        case 409:
        {
            return [NSError errorWithDomain:@"com.private"
                                       code:409
                                   userInfo:@{NSLocalizedDescriptionKey: @"Flight Log already does not exist in our system."}];
            break;
        }
        default:{
            return [NSError errorWithDomain:@"com.private"
                                       code:999
                                   userInfo:@{NSLocalizedDescriptionKey: @"hello error."}];
            break;
        }
            
    }
}

@end

