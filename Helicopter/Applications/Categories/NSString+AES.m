//
//  NSString+AES.m
//  Helicopter
//
//  Created by Linh's iMac on 1/4/14.
//  Copyright (c) 2014 private. All rights reserved.
//

#import "NSString+AES.h"

#define KEY  @"privateKey"

@implementation NSString (AES)

- (NSString *)AES128Encrypt {
    NSData *plainData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [plainData AES128EncryptWithKey:KEY];
    
    NSString *encryptedString = [encryptedData base64Encoding];
    
    return encryptedString;
}

- (NSString *)AES128Decrypt {
    NSData *encryptedData = [NSData dataWithBase64EncodedString:self];
    NSData *plainData = [encryptedData AES128DecryptWithKey:KEY];
    
    NSString *plainString = [[NSString alloc] initWithData:plainData encoding:NSUTF8StringEncoding];
    
    return plainString;
}
@end
