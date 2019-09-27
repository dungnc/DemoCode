//
//  NSDictionary+Additions.m
//  Helicopter
//
//  Created by Nguyen Chi Dung on 9/3/14.
//  Copyright (c) 2014 Era Helicopter. All rights reserved.
//

#import "NSDictionary+Additions.h"

@implementation NSDictionary (Additions)

- (id)objectForKeyNotNull:(id)key {
    id object = [self objectForKey:key];
    if(object == [NSNull null])
        return nil;
    return object;
}

- (id)valueForKeyPathNotNull:(id)key {
    id object = [self valueForKeyPath:key];
    if(object == [NSNull null])
        return nil;
    return object;
}

@end
