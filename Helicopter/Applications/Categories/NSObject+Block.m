//
//  NSObject+Block.m
//  Helicopter
//
//  Created by Nguyen Chi Dung on 12/30/13.
//  Copyright (c) 2013 Nguyen Chi Dung. All rights reserved.
//

#import "NSObject+Block.h"

@implementation NSObject (Block)

- (void)performBlock:(void (^)())block {
    block();
}

- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay {
    void (^block_)() = [block copy];
    [self performSelector:@selector(performBlock:) withObject:block_ afterDelay:delay];
}

- (void)performInBackgroundBlock:(void (^)())block {
    void (^block_)() = [block copy];
    [self performSelectorInBackground:@selector(performBlock:) withObject:block_];
}

@end
