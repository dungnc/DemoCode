//
//  UserObject.m
//  Helicopter
//
//  Created by Hoa Truong on 3/11/15.
//  Copyright (c) 2015 Era Helicopter. All rights reserved.
//

#import "UserObject.h"
#import "NSDictionary+Additions.h"
#import "NSString+Keychain.h"
//#import "NSString+StringAdditions.h"

NSString *const kUserObjectToken = @"token";

@implementation UserObject

@synthesize token = _token;

+ (UserObject*)currentUser {
    static UserObject *sharedUser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUser = [[self alloc] init];
    });
    return sharedUser;
}
- (void)modelObjectWithDictionary:(NSDictionary *)dict {
    NSLog(@"dict:%@",dict);
    if([dict isKindOfClass:[NSDictionary class]]) {
        self.token = [dict objectForKeyNotNull:kUserObjectToken];
    }
    NSLog(@"token:%@",self.token);
}
#pragma mark - Getter, Setter
- (void)setToken:(NSString *)token {
    [token saveToKeychainWithKey:kUserObjectToken];
}

- (NSString*)token {
    return [NSString keychainValueForKey:kUserObjectToken];
}
@end
