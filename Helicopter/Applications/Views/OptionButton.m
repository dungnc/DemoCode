//
//  OptionButton.m
//  Helicopter
//
//  Created by Nguyen Chi Dung on 1/10/14.
//  Copyright (c) 2014 Nguyen Chi Dung. All rights reserved.
//

#import "OptionButton.h"

@implementation OptionButton

+ (id)buttonWithType:(UIButtonType)buttonType {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 60, 32);
    [button setBackgroundColor:[UIColor clearColor]];
    [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    return button;
}

@end
