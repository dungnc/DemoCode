//
//  SelectButton.m
//  Helicopter
//
//  Created by Nguyen Chi Dung on 1/10/14.
//  Copyright (c) 2014 Nguyen Chi Dung. All rights reserved.
//

#import "SelectButton.h"

@implementation SelectButton

- (id)initWithCoder:(NSCoder*) decoder {
	if (self = [super initWithCoder: decoder]) {
        [self setImage:[UIImage imageNamed:@"bt_select_selected"] forState:UIControlStateHighlighted];
        [self setImage:[UIImage imageNamed:@"bt_select"] forState:UIControlStateNormal];
    }
	return self;
}

@end
