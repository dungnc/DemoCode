//
//  ERATableViewCell.h
//  Helicopter
//
//  Created by Nguyen Chi Dung on 4/17/14.
//  Copyright (c) 2014 Nguyen Chi Dung. All rights reserved.
//

#import "VNTableViewCell.h"

#define EDIT_IMAGE               [UIImage imageNamed:@"bt_edit"]
#define OPTION_IMAGE             [UIImage imageNamed:@"bt_select"]
#define CHECKED_IMAGE            [UIImage imageNamed:@"cb_checked"]
#define UNCHECKED_IMAGE          [UIImage imageNamed:@"cb_unChecked"]
#define SELECT_IMAGE             [UIImage imageNamed:@"img_selectimages"]

@interface ERATableViewCell : VNTableViewCell 

- (void)setValue:(id)value completionHandler:(VNTableViewCellBlock)handler;
- (void)setValue:(id)value canEdit:(BOOL )iscanEdit withIndexPath:(NSIndexPath *)indexPath completionHandler:(VNTableViewCellBlock)handler;
- (void)setValue:(id)value canEdit:(BOOL )iscanEdit withIndexPath:(NSIndexPath *)indexPath order:(NSInteger)order maxGross:(double)maxGrossWeight completionHandler:(VNTableViewCellBlock)handler;
- (void)didFinishSetData:(BOOL)isCanEdit;
- (BOOL)validateSpecialCharactor:(NSString *) text;

@end
