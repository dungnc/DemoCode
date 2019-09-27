//
//  PilotCell.h
//  Helicopter
//
//  Created by Nguyen Chi Dung on 9/26/14.
//  Copyright (c) 2014 Era Helicopter. All rights reserved.
//

#import "ERATableViewCell.h"

@class ERA_Employee;

@interface PilotCell : ERATableViewCell

@property (weak, nonatomic) IBOutlet UILabel *pilotLabel;
@property (weak, nonatomic) IBOutlet UILabel *flightTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *nightLabel;
@property (weak, nonatomic) IBOutlet UILabel *ifrLabel;
@property (weak, nonatomic) IBOutlet UILabel *nvgLabel;
@property (weak, nonatomic) IBOutlet UILabel *vfrLabel;
@property (weak, nonatomic) NSNumber *crewCount;

- (void) setPilot:(ERA_Employee *)pilot copilotWeight:(NSNumber*)weight logSections:(NSArray *)logSections isCoPilot:(BOOL)coPilot withIndexPath:(NSIndexPath *)indexPath completionHandler:(VNTableViewCellBlock)handler;

@end
