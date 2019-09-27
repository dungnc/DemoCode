//
//  ERAObject.m
//  Helicopter
//
//  Created by Nguyen Chi Dung on 4/21/14.
//  Copyright (c) 2014 Nguyen Chi Dung. All rights reserved.
//
#import <objc/runtime.h>
#import "ERAObject.h"

@implementation ERAObject

- (NSDictionary *)dictionary {
    unsigned int propertyCount = 0;
    objc_property_t * properties = class_copyPropertyList([self class], &propertyCount);
    NSMutableArray * keys = [NSMutableArray array];
    NSMutableArray * values = [NSMutableArray array];
    
    for (unsigned int i = 0; i < propertyCount; ++i) {
        objc_property_t property = properties[i];
        const char * name = property_getName(property);
        [keys addObject:[NSString stringWithUTF8String:name]];
        id value  = [self valueForKey:[NSString stringWithUTF8String:name]];
        if (value == nil) {
            [values addObject:@""];
        }
        else {
            [values addObject:value];
        }
    }
    free(properties);
    NSDictionary *dic = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    return dic;
}

- (NSArray *)properties {
    unsigned int propertyCount = 0;
    objc_property_t * properties = class_copyPropertyList([self class], &propertyCount);
    NSMutableArray * propertyNames = [NSMutableArray array];
    
    for (unsigned int i = 0; i < propertyCount; ++i) {
        objc_property_t property = properties[i];
        const char * name = property_getName(property);
        [propertyNames addObject:[NSString stringWithUTF8String:name]];
        
    }
    free(properties);
    return propertyNames;
}

@end
