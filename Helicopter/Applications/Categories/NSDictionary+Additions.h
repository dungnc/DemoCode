//
//  NSDictionary+Additions.h
//  Helicopter
//
//  Created by Nguyen Chi Dung on 9/3/14.
//  Copyright (c) 2014 Era Helicopter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Additions)

- (id)objectForKeyNotNull:(id)key;
- (id)valueForKeyPathNotNull:(id)key;

@end
