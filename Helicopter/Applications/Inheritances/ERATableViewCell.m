//
//  ERATableViewCell.m
//  Helicopter
//
//  Created by Nguyen Chi Dung on 4/17/14.
//  Copyright (c) 2014 Nguyen Chi Dung. All rights reserved.
//

#import "ERATableViewCell.h"

@implementation ERATableViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
    if(IS_IOS_8) {
        self.layoutMargins = UIEdgeInsetsZero;
    }
}

- (void)setValue:(id)value completionHandler:(VNTableViewCellBlock)handler {
    _handler = handler;
}

- (void)setValue:(id)value canEdit:(BOOL )iscanEdit withIndexPath:(NSIndexPath *)indexPath completionHandler:(VNTableViewCellBlock)handler {    
}

- (void)setValue:(id)value canEdit:(BOOL )iscanEdit withIndexPath:(NSIndexPath *)indexPath order:(NSInteger)order maxGross:(double)maxGrossWeight completionHandler:(VNTableViewCellBlock)handler {
    
}

- (void)didFinishSetData:(BOOL)isCanEdit {
    if (isCanEdit) {
        return;
    }
    for (UIView *view in self.contentView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            view.hidden = YES;
        }
        else if ([view isKindOfClass:[UISlider class]]) {
            [(UISlider *)view setUserInteractionEnabled:NO];
        }
    }
}

@end
