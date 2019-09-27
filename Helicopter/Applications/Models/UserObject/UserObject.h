//
//  UserObject.h
//  Helicopter
//
//  Created by Hoa Truong on 3/11/15.
//  Copyright (c) 2015 Era Helicopter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserObject : NSObject
@property (nonatomic, strong) NSString *token;

+ (UserObject *)currentUser;
- (void)modelObjectWithDictionary:(NSDictionary *)dict;
@end
