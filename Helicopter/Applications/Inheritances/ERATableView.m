//
//  ERATableView.m
//  Helicopter
//
//  Created by Nguyen Chi Dung on 4/23/14.
//  Copyright (c) 2014 Nguyen Chi Dung. All rights reserved.
//

#import "ERATableView.h"

@interface ERATableView() {
    UITapGestureRecognizer *_tapRecognizer;
}

@end

@implementation ERATableView

- (void)reloadData {
    [super reloadData];
    for (UIView *view in self.subviews) {
        if ([view isEqual:self.tableHeaderView]) {
            NSLog(@"tableHeaderView");
        }
//        [view removeGestureRecognizer:_tapRecognizer];
    }
}

@end
