//
//  FuelCell.h
//  Helicopter
//
//  Created by Nguyen Chi Dung on 9/26/14.
//  Copyright (c) 2014 Era Helicopter. All rights reserved.
//

#import "ERATableViewCell.h"

@class LogLocationData;

@interface FuelCell : ERATableViewCell

@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet UITextField *gallonsTextField, *ownerTextField, *amountTextField;
@property (nonatomic, weak) IBOutlet UIButton *btGallons, *btAmount;
@property (nonatomic, strong) NSIndexPath *indexPath;

- (void) setLogLocation:(LogLocationData *)logLocation logSections:(NSArray *)logSections canEdit:(BOOL)isCanEdit withIndexPath:(NSIndexPath *)indexPath completionHandler:(VNTableViewCellBlock)handler;

@end
