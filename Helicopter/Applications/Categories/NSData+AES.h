//
//  NSData+AES.h
//  Helicopter
//
//  Created by Linh's iMac on 1/4/14.
//  Copyright (c) 2014 private. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES)
- (NSData *)AES128EncryptWithKey:(NSString *)key;
- (NSData *)AES128DecryptWithKey:(NSString *)key;

+ (NSData *)dataWithBase64EncodedString:(NSString *)string;
- (id)initWithBase64EncodedString:(NSString *)string;

- (NSString *)base64Encoding;
- (NSString *)base64EncodingWithLineLength:(NSUInteger)lineLength;

- (BOOL)hasPrefixBytes:(const void *)prefix length:(NSUInteger)length;
- (BOOL)hasSuffixBytes:(const void *)suffix length:(NSUInteger)length;

@end
