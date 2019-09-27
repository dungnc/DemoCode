//
//  NSObject+Block.h
//  Helicopter
//
//  Created by Nguyen Chi Dung on 12/30/13.
//  Copyright (c) 2013 Nguyen Chi Dung. All rights reserved.
//

@interface NSObject (Block)

- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay;
- (void)performInBackgroundBlock:(void (^)())block;

@end
