//
//  NSString+AES.h
//  Helicopter
//
//  Created by Linh's iMac on 1/4/14.
//  Copyright (c) 2014 private. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "NSData+AES.h"


@interface NSString (AES)
- (NSString *)AES128Encrypt;
- (NSString *)AES128Decrypt;
@end
