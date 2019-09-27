//
//  PilotCell.m
//  Helicopter
//
//  Created by Nguyen Chi Dung on 9/26/14.
//  Copyright (c) 2014 Era Helicopter. All rights reserved.
//

#import "PilotCell.h"
#import "ERA_LogSection.h"
#import "NSDate+Helper.h"
#import "NSString+ERA.h"

@implementation PilotCell

- (void)setPilot:(ERA_Employee *)pilot copilotWeight:(NSNumber*)copilotWeight logSections:(NSArray *)logSections isCoPilot:(BOOL)coPilot withIndexPath:(NSIndexPath *)indexPath completionHandler:(VNTableViewCellBlock)handler {
    _pilotLabel.text = @"";
    _flightTimeLabel.text = @"";
    _dayLabel.text = @"";
    _nightLabel.text = @"";
    _vfrLabel.text = @"";
    _ifrLabel.text = @"";
    _nvgLabel.text = @"";
    _pilotLabel.font = [UIFont systemFontOfSize:13];
    _flightTimeLabel.font = [UIFont systemFontOfSize:13];
    _dayLabel.font = [UIFont systemFontOfSize:13];
    _nightLabel.font = [UIFont systemFontOfSize:13];
    _vfrLabel.font = [UIFont systemFontOfSize:13];
    _ifrLabel.font = [UIFont systemFontOfSize:13];
    _nvgLabel.font = [UIFont systemFontOfSize:13];
    
    if (indexPath.row ==0) {
        _pilotLabel.text = @"PILOT";
        _flightTimeLabel.text = @"FLIGHT TIME";
        _dayLabel.text = @"DAY";
        _nightLabel.text = @"NIGHT";
        _vfrLabel.text = @"VFR";
        _ifrLabel.text = @"IFR";
        _nvgLabel.text = @"NVG";
        _pilotLabel.font = [UIFont boldSystemFontOfSize:13];
        _flightTimeLabel.font = [UIFont boldSystemFontOfSize:13];
        _dayLabel.font = [UIFont boldSystemFontOfSize:13];
        _nightLabel.font = [UIFont boldSystemFontOfSize:13];
        _vfrLabel.font = [UIFont boldSystemFontOfSize:13];
        _ifrLabel.font = [UIFont boldSystemFontOfSize:13];
        _nvgLabel.font = [UIFont boldSystemFontOfSize:13];
        
    }
    else{
        if (_crewCount.integerValue == 2 && coPilot && !pilot) {
            return;
        }
        if (pilot) {
            _pilotLabel.text = [NSString stringWithFormat:@"%@ %@",[pilot.firstName trim],[pilot.lastName trim]];
        }
        else {
            _pilotLabel.text =  @"";
        }
        
        if(copilotWeight==nil) {
            _pilotLabel.text = @"";
            _flightTimeLabel.text = @"";
            _dayLabel.text = @"";
            _nightLabel.text = @"";
            _vfrLabel.text = @"";
            _ifrLabel.text = @"";
            _pilotLabel.text = @"";
            return;
        }
        
        NSInteger day = 0, night=0, flightTime=0, vfr=0, ifr=0, nvgP=0, nvgC=0;
        for (ERA_LogSection *value in logSections) {
            day += value.dayTime.integerValue;
            flightTime += [value.off numberMinutesToDate:value.on];
            vfr += value.vFRTimeIFRTime.integerValue;
            nvgC += value.nVGTimeC.integerValue;
            nvgP += value.nVGTimeP.integerValue;
        }
        
        night= flightTime - day;
        ifr = flightTime - vfr;
        
        if (flightTime ==0) {
            return;
        }
        
        _flightTimeLabel.text = [NSString stringWithFormat:@"%d",(int)flightTime];
        _dayLabel.text = [NSString stringWithFormat:@"%d",(int)day];
        _nightLabel.text = [NSString stringWithFormat:@"%d",(int)night];
        _vfrLabel.text = [NSString stringWithFormat:@"%d",(int)vfr];
        _ifrLabel.text = [NSString stringWithFormat:@"%d",(int)ifr];
        if (coPilot) {
            _nvgLabel.text = [NSString stringWithFormat:@"%d",(int)nvgC];
        }
        else{
            _nvgLabel.text = [NSString stringWithFormat:@"%d",(int)nvgP];
        }
        
        if(indexPath.row==2 && _crewCount.integerValue==1) {
            _flightTimeLabel.text = @"";
            _dayLabel.text = @"";
            _nightLabel.text = @"";
            _vfrLabel.text = @"";
            _ifrLabel.text = @"";
            _pilotLabel.text = @"";
        }
    }
}

@end
