//
//  FlightDetailCell.m
//  Helicopter
//
//  Created by Nguyen Chi Dung on 9/26/14.
//  Copyright (c) 2014 Era Helicopter. All rights reserved.
//

#import "FlightDetailCell.h"
#import "LogSectionData.h"
#import "ERA_Customer.h"
#import "ERA_SlotPurpose.h"
#import "ERA_Location.h"
#import "ERA_FuelOwner.h"
#import "ERA_Log.h"
#import "ERA_LogSection.h"

@interface FlightDetailCell()<UITextFieldDelegate> {
    LogSectionData *_logSection;
    FlightDetailCellAction _action1, _action2,_action3;
    double _maxGrossWeight;
}
@end

@implementation FlightDetailCell

static float pixelForAPercent1;
static float pixelForAPercent2;

- (void)setValue:(id)value canEdit:(BOOL )iscanEdit withIndexPath:(NSIndexPath *)indexPath order:(NSInteger)order maxGross:(double)maxGrossWeight completionHandler:(VNTableViewCellBlock)handler {
    _maxGrossWeight = maxGrossWeight;
    _handler = handler;
    _indexPath = indexPath;
    _logSection = (LogSectionData *)value;
    _title1Label.hidden = NO;
    _title2Label.hidden = NO;
    _title3Label.hidden = NO;
    _title1Label.enabled = YES;
    _title2Label.enabled = YES;
    _title3Label.enabled = YES;
    _title1Label.text = @"";
    _title2Label.text = @"";
    _title3Label.text = @"";
    _title21Label.hidden = YES;
    _title22Label.hidden = YES;
    _value1TextField.hidden = NO;
    _value2TextField.hidden = NO;
    _value3TextField.hidden = NO;
    _value1TextField.enabled = NO;
    _value2TextField.enabled = NO;
    _value3TextField.enabled = NO;
    _value1TextField.placeholder = @"";
    _value2TextField.placeholder = @"";
    _value3TextField.placeholder = @"";
    _value1TextField.text = @"";
    _value2TextField.text = @"";
    _value3TextField.text = @"";
    _value1TextField.keyboardType = UIKeyboardTypeDecimalPad;
    _value2TextField.keyboardType = UIKeyboardTypeDecimalPad;
    _value3TextField.keyboardType = UIKeyboardTypeDecimalPad;
    _value1TextField.userInteractionEnabled = YES;
    _value2TextField.userInteractionEnabled = YES;
    _value3TextField.userInteractionEnabled = YES;
    _rangeFromTextField.hidden = YES;
    _rangeToTextField.hidden = YES;
    _rangeFromTextField.enabled = NO;
    _rangeToTextField.enabled = NO;
    _rangeFromTextField.placeholder = @"";
    _rangeToTextField.placeholder = @"";
    _rangeToTextField.text = @"";
    _rangeFromTextField.keyboardType = UIKeyboardTypeDecimalPad;
    _rangeToTextField.keyboardType = UIKeyboardTypeDecimalPad;
    _bt1.hidden = NO;
    _bt2.hidden = NO;
    _bt3.hidden = NO;
    _bt1.enabled = YES;
    _bt2.enabled = YES;
    _bt3.enabled = YES;
    _action1 = FlightDetailCellActionActionNone;
    _action2 = FlightDetailCellActionActionNone;
    _action3 = FlightDetailCellActionActionNone;
    _btRangeFrom.hidden = YES;
    _btRangeTo.hidden = YES;
    _rangeToLabel.hidden = YES;
    _sliderValueLabel2.hidden = YES;
    _sliderValueLabel2.text = @"0";
    _sliderValueLabel3.hidden = YES;
    _sliderValueLabel3.text = @"0";
    _slider2.hidden = YES;
    _slider2.userInteractionEnabled = YES;
    _slider2.value = 0.0;
    _slider3.hidden = YES;
    _slider3.userInteractionEnabled = YES;
    _slider3.value = 0.0;
    
    if(indexPath.section==0) {
        switch (indexPath.row) {
            case 0: {
                _title1Label.text = @"Load Schedule";
                _title2Label.text = @"A/C Started";
                _title3Label.text = @"Slot Purpose";
                _value3TextField.placeholder = @"Required";
                _value2TextField.placeholder = @"";
                _value1TextField.hidden = YES;
                [_bt1 setImage:UNCHECKED_IMAGE forState:UIControlStateNormal];
                [_bt2 setImage:UNCHECKED_IMAGE forState:UIControlStateNormal];
                [_bt3 setImage:OPTION_IMAGE forState:UIControlStateNormal];
                _action1 = FlightDetailCellActionActionCheck;
                _action2 = FlightDetailCellActionActionCheck;
                _action3 = FlightDetailCellActionActionDropDown;
                
                if (_logSection.listLogSections.count && !_logSection.isEdit && !_logSection.isInsert) {
                    _bt3.hidden = YES;
                   
                } else {
                    _bt3.hidden = NO;
                }
                
                if (_logSection.loadSchedule.boolValue) {
                    [_bt1 setImage:CHECKED_IMAGE forState:UIControlStateNormal];
                }
                if (_logSection.acStarted.boolValue) {
                    [_bt2 setImage:CHECKED_IMAGE forState:UIControlStateNormal];
                }
                if (_logSection.eraSlotPurpose) {
                    _value3TextField.text = _logSection.eraSlotPurpose.name;
                }
                
                if (_logSection.cargoWeight.doubleValue > 0) {
                    _bt1.enabled = NO;
                    _title1Label.enabled = NO;
                    [_bt1 setImage:UNCHECKED_IMAGE forState:UIControlStateNormal];
                    _logSection.loadSchedule = [NSNumber numberWithBool:NO];
                }else{
                    _bt1.enabled = YES;
                    _title1Label.enabled = YES;
                }
                
            }
                break;
                
            case 1: {
                _title1Label.text = @"Total Fuel (Hours)";
                _title2Label.text = @"From";
                _title3Label.text = @"To";
                _value1TextField.placeholder = @"Required";
                _value2TextField.placeholder = @"";
                _value3TextField.placeholder = @"Required";
                
                [_bt1 setImage:EDIT_IMAGE forState:UIControlStateNormal];
                [_bt3 setImage:OPTION_IMAGE forState:UIControlStateNormal];
                
                if ((_logSection.isAdd && _logSection.orderID.intValue == 1)||(_logSection.orderID.intValue == 0 && _logSection.isInsert) || (_logSection.orderID.intValue == 1 && _logSection.isEdit)) {
                    [_bt2 setImage:OPTION_IMAGE forState:UIControlStateNormal];
                    _action2 = FlightDetailCellActionActionDropDown;
                }else{
                    _bt2.hidden = YES;
                    _action2 = FlightDetailCellActionActionNone;
                }
                
                _action1 = FlightDetailCellActionActionEdit;
                _action3 = FlightDetailCellActionActionDropDown;
                
                if (_logSection.eraFromLocation) {
                    _value2TextField.text= _logSection.eraFromLocation.name;
                }
                if (_logSection.eraToLocation) {
                    _value3TextField.text = _logSection.eraToLocation.name;
                }
                if (_logSection.fuel.doubleValue >0) {
                    _value1TextField.text = [_logSection.fuel getNumberString];
                }
            }
                break;
                
            case 2: {
                _title1Label.text = @"Manifest#";
                _title2Label.text = @"Passengers ";
                _title3Label.text = @"Emp By";
                
                _value2TextField.placeholder = @"Required";
                _value3TextField.placeholder = @"";
                [_bt1 setImage:SELECT_IMAGE forState:UIControlStateNormal];
                [_bt2 setImage:OPTION_IMAGE forState:UIControlStateNormal];
                [_bt3 setImage:OPTION_IMAGE forState:UIControlStateNormal];
                
                _action1 = FlightDetailCellActionActionSelectImage;
                _action2 = FlightDetailCellActionActionDropDown;
                _action3 = FlightDetailCellActionActionDropDown;
                
               
                NSInteger  countOfImageFiles = [_logSection.countOfImages integerValue];
                
                if (countOfImageFiles == 0 || countOfImageFiles ==1) {
                    _value1TextField.text = [NSString stringWithFormat:@"%ld image",(long)countOfImageFiles];
                }else{
                    _value1TextField.text = [NSString stringWithFormat:@"%ld images",(long)countOfImageFiles];
                }
                
                if (_logSection.passengers) {
                    _value2TextField.text = [NSString stringWithFormat:@"%d",(int)_logSection.passengers.integerValue];
                }
                if (_logSection.eraEmpBy) {
                    _value3TextField.text = _logSection.eraEmpBy.name;
                }
                
            }
                break;
                
            case 3: {
                _title1Label.text = @"T/O W (lbs)";
                _title2Label.text = @"CG";
                _title3Label.text = @"Range";
                
                if (!_logSection.loadSchedule.boolValue) {
                    _value2TextField.placeholder = @"Required";
                }
                _value1TextField.placeholder = @"Required";
                
                _value2TextField.hidden = NO;
                _value3TextField.hidden = YES;
                _rangeFromTextField.hidden = NO;
                _rangeFromTextField.frame = CGRectMake(770.,_rangeFromTextField.frame.origin.y ,_rangeFromTextField.frame.size.width , _rangeFromTextField.frame.size.height );
                
                _rangeToTextField.hidden = NO;
                _rangeToTextField.frame = CGRectMake(881.,_rangeToTextField.frame.origin.y ,_rangeToTextField.frame.size.width , _rangeToTextField.frame.size.height );
                
                _bt1.hidden = NO;
                _bt2.hidden = NO;
                _bt3.hidden = YES;
                
                [_bt1 setImage:EDIT_IMAGE forState:UIControlStateNormal];
                [_bt2 setImage:EDIT_IMAGE forState:UIControlStateNormal];
                
                _action1 = FlightDetailCellActionActionEdit;
                _action2 = FlightDetailCellActionActionEdit;
                
                _btRangeFrom.hidden = NO;
                _btRangeFrom.frame = CGRectMake(760.,_btRangeFrom.frame.origin.y ,_btRangeFrom.frame.size.width , _btRangeFrom.frame.size.height );
                _btRangeTo.hidden = NO;
                _btRangeTo.frame = CGRectMake(890.,_btRangeTo.frame.origin.y ,_btRangeTo.frame.size.width , _btRangeTo.frame.size.height );
                _rangeToLabel.hidden = NO;
                _rangeToLabel.frame = CGRectMake(850.,_rangeToLabel.frame.origin.y ,_rangeToLabel.frame.size.width , _rangeToLabel.frame.size.height );
                
                if (_logSection.tOW) {
                    _value1TextField.text = [_logSection.tOW getNumberString];
                }
                
                if (_logSection.cG.doubleValue >0) {
                    _value2TextField.text = [_logSection.cG getNumberString];
                }
                if (_logSection.rangeFrom) {
                    _rangeFromTextField.text = [_logSection.rangeFrom getNumberString];
                }
                if (_logSection.rangeTo) {
                    _rangeToTextField.text = [_logSection.rangeTo getNumberString];
                }
                
            }
                break;
                
            case 4: {
                _title1Label.text = @"Cargo Weight (lbs)";
                _title2Label.text = @"Fuel Added (gals)";
                _title3Label.text = @"Fuel Owner";
                
                [_value2TextField setDelegate:self];
                [_bt1 setImage:EDIT_IMAGE forState:UIControlStateNormal];
                [_bt2 setImage:EDIT_IMAGE forState:UIControlStateNormal];
                [_bt3 setImage:OPTION_IMAGE forState:UIControlStateNormal];
                _action1 = FlightDetailCellActionActionEdit;
                _action2 = FlightDetailCellActionActionEdit;
                _action3 = FlightDetailCellActionActionDropDown;
                if (_logSection.cargoWeight.doubleValue>0) {
                    _value1TextField.text = [_logSection.cargoWeight getNumberString];
                    
                }
                if (_logSection.fuelAmount){
                    _value2TextField.text = [_logSection.fuelAmount getNumberString];
                    _title3Label.enabled = YES;
                    _bt3.enabled = YES;
                    _value3TextField.placeholder = @"Required";
                    _value3TextField.hidden  = NO;
                }
                else {
                    _title3Label.enabled = NO;
                    _bt3.enabled = NO;
                    _value3TextField.text = @"";
                    _value3TextField.placeholder = @"";
                    _value3TextField.hidden = YES;
                }
                
                if (_logSection.eraFuelOwner) {
                    _value3TextField.text = _logSection.eraFuelOwner.name;
                }
            }
                break;
                
            case 5:{
                _title1Label.text = @"PAX Weight (lbs)";
                _title2Label.text = @"Baggage (lbs)";
                _title3Label.text = @"# of Patients";
                _title3Label.textColor = [UIColor lightGrayColor];
                
                _value2TextField.placeholder = @"";
                _value3TextField.placeholder = @"";
                _value3TextField.enabled = NO;
                _value3TextField.hidden = YES;
                
                [_bt1 setImage:EDIT_IMAGE forState:UIControlStateNormal];
                [_bt2 setImage:EDIT_IMAGE forState:UIControlStateNormal];
                [_bt3 setImage:EDIT_IMAGE forState:UIControlStateNormal];
                
                _action1 = FlightDetailCellActionActionEdit;
                _action2 = FlightDetailCellActionActionEdit;
                _action3 = FlightDetailCellActionActionEdit;
                
                if (_logSection.passengers.integerValue > 0) {
                    _value1TextField.placeholder = @"Required";
                    _value1TextField.enabled     = YES;
                    _bt1.enabled                 = YES;
                    _title1Label.enabled         = YES;
                    _value1TextField.delegate = self;
                    if (_logSection.paxWeight) {
                        _value1TextField.text = [_logSection.paxWeight getNumberString];
                    }

                } else {
                    _value1TextField.placeholder = @"";
                    _value1TextField.enabled     = NO;
                    _bt1.enabled                 = NO;
                    _title1Label.enabled         = NO;
                }
                
                
                if (_logSection.baggage.doubleValue>0) {
                    _value2TextField.text = [_logSection.baggage getNumberString];
                }
                
                if (_logSection.eraSlotPurpose && ([[_logSection.eraSlotPurpose.name uppercaseString] isEqualToString:@"D-SAR"]||[[_logSection.eraSlotPurpose.name uppercaseString] isEqualToString:@"D-MEDICAL"])) {
                    _value3TextField.delegate = self;
                    _value3TextField.enabled =YES;
                    _value3TextField.hidden = NO;
                    _bt3.hidden = NO;
                    _title3Label.textColor = [UIColor blackColor];
                    
                }
                else {
                    _logSection.patients = nil;
                    _value3TextField.enabled = NO;
                    _value3TextField.hidden = YES;
                    _bt3.enabled = NO;
                    _title3Label.textColor = [UIColor lightGrayColor];
                }
                if (_logSection.patients.integerValue >0) {
                    _value3TextField.text = [NSString stringWithFormat:@"%d",(int)_logSection.patients.integerValue];
                }
            }
                break;
                
            default: {
                _title1Label.text = @"Remarks";
                _title2Label.text = @"";
                _title3Label.text = @"";
                
                _line1Label.hidden = YES;
                _line2Label.hidden = YES;
                _value1TextField.hidden = NO;
                _value2TextField.hidden = YES;
                _value3TextField.hidden = YES;
                
                _bt1.hidden = NO;
                _bt2.hidden = YES;
                _bt3.hidden = YES;
                
                _action1 = FlightDetailCellActionActionEdit;
                
                [_bt1 setImage:EDIT_IMAGE forState:UIControlStateNormal];
                
                _value1TextField.frame = CGRectMake(100, 5, 888, 43);
                _bt1.frame = CGRectMake(100, 0, 915, 50);
                _value1TextField.keyboardType = UIKeyboardTypeDefault;
                if (_logSection.remarks) {
                    _value1TextField.text = _logSection.remarks;
                }
                
            }
                break;
        }
    }
    else {
        switch (indexPath.row) {
            case 0: {
                _title1Label.text = @"Off";
                _title2Label.text = @"On";
                _title3Label.text = @"Flight Time";
                _value1TextField.placeholder = @"Required";
                _value2TextField.placeholder = @"Required";
                _value3TextField.userInteractionEnabled = NO;
                _bt3.hidden = YES;
                [_bt1 setImage:OPTION_IMAGE forState:UIControlStateNormal];
                [_bt2 setImage:OPTION_IMAGE forState:UIControlStateNormal];
                _action1 = FlightDetailCellActionActionDropDown;
                _action2 = FlightDetailCellActionActionDropDown;
                
                if (_logSection.off) {
                    _value1TextField.text = [[Singleton sharedTimeFormatter] stringFromDate:_logSection.off];
                }
                if (_logSection.on) {
                    _value2TextField.text = [[Singleton sharedTimeFormatter] stringFromDate:_logSection.on];
                }
                if (_logSection.flightTime) {
                    _value3TextField.text = [NSString stringWithFormat:@"%d",(int)_logSection.flightTime.integerValue];
                }
            }
                break;
                
            case 1: {
                _title1Label.text = @"All Day";
                _title2Label.text = @"Day Time";
                _title3Label.text = @"All VFR";
                _title21Label.hidden = NO;
                _value1TextField.hidden = YES;
                _value2TextField.hidden = YES;
                _value3TextField.hidden = YES;
                _bt2.hidden = YES;
                [_bt1 setImage:UNCHECKED_IMAGE forState:UIControlStateNormal];
                [_bt3 setImage:UNCHECKED_IMAGE forState:UIControlStateNormal];
                _action1 = FlightDetailCellActionActionCheck;
                _action3 = FlightDetailCellActionActionCheck;
                if(_logSection.off && _logSection.on) {
                    _sliderValueLabel2.hidden = NO;
                }
                else {
                    _bt1.enabled = NO;
                    _bt3.enabled = NO;
                }
                _slider2.hidden = NO;
                
                if (_logSection.allDayTime.boolValue) {
                    [_bt1 setImage:CHECKED_IMAGE forState:UIControlStateNormal];
                }
                
                if (_logSection.allVFR.boolValue) {
                    [_bt3 setImage:CHECKED_IMAGE forState:UIControlStateNormal];
                }
                
                if (_logSection.flightTime.integerValue >0) {
                    _slider2.maximumValue = _logSection.flightTime.integerValue;
                }
                else{
                    _slider2.userInteractionEnabled = NO;
                }
                
                if (_logSection.allDayTime.boolValue) {
                    _slider2.userInteractionEnabled = NO;
                }
                
                _slider2.value = _logSection.dayTime.integerValue;
                _sliderValueLabel2.text = [NSString stringWithFormat:@"%d",(int)_logSection.dayTime.integerValue];
                
                float x1 = _slider2.frame.origin.x + _sliderValueLabel2.frame.size.width/2.0;
                float y1 = _slider2.frame.origin.x + _slider2.frame.size.width - _sliderValueLabel2.frame.size.width/2.0;
                pixelForAPercent1 = (y1-x1)/100.;
                _sliderValueLabel2.center = CGPointMake(433+(_slider2.value/_slider2.maximumValue*100)*pixelForAPercent1, 7);
            }
                break;
                
            case 2: {
                _title1Label.text = @"All IFR";
                _title2Label.text = @"Offshore";
                _title3Label.text = @"International";
                _value1TextField.hidden = YES;
                _value2TextField.hidden = YES;
                _value3TextField.hidden = YES;
                [_bt1 setImage:UNCHECKED_IMAGE forState:UIControlStateNormal];
                [_bt2 setImage:UNCHECKED_IMAGE forState:UIControlStateNormal];
                [_bt3 setImage:UNCHECKED_IMAGE forState:UIControlStateNormal];
                _action1 = FlightDetailCellActionActionCheck;
                _action2 = FlightDetailCellActionActionCheck;
                _action3 = FlightDetailCellActionActionCheck;
                
                if(_logSection.on==nil||_logSection.off==nil) {
                    _bt1.enabled = NO;
                }
                if (_logSection.allIFR.boolValue) {
                    [_bt1 setImage:CHECKED_IMAGE forState:UIControlStateNormal];
                }
                if (_logSection.offshoreTime.boolValue) {
                    [_bt2 setImage:CHECKED_IMAGE forState:UIControlStateNormal];
                }
                if (_logSection.internationalTime.boolValue) {
                    [_bt3 setImage:CHECKED_IMAGE forState:UIControlStateNormal];
                }
            }
                break;
                
            case 3: {
                _title1Label.text = @"Mountain";
                _title2Label.text = @"Artic";
                _title3Label.text = @"AirMedical";
                _value1TextField.hidden = YES;
                _value2TextField.hidden = YES;
                _value3TextField.hidden = YES;
                [_bt1 setImage:UNCHECKED_IMAGE forState:UIControlStateNormal];
                [_bt2 setImage:UNCHECKED_IMAGE forState:UIControlStateNormal];
                [_bt3 setImage:UNCHECKED_IMAGE forState:UIControlStateNormal];
                _action1 = FlightDetailCellActionActionCheck;
                _action2 = FlightDetailCellActionActionCheck;
                _action3 = FlightDetailCellActionActionCheck;
                
                if (_logSection.mountainTime.boolValue) {
                    [_bt1 setImage:CHECKED_IMAGE forState:UIControlStateNormal];
                }
                if (_logSection.articTime.boolValue) {
                    [_bt2 setImage:CHECKED_IMAGE forState:UIControlStateNormal];
                }
                if (_logSection.airMedicalTime.boolValue) {
                    [_bt3 setImage:CHECKED_IMAGE forState:UIControlStateNormal];
                }
            }
                break;
                
            default: {
                _title1Label.text = @"Training";
                _title2Label.text = @"FlightSeeing";
                _title3Label.text = @"VFR";
                _title22Label.hidden = NO;
                _value1TextField.hidden = YES;
                _value2TextField.hidden = YES;
                _value3TextField.hidden = YES;
                _bt3.hidden = YES;
                [_bt1 setImage:UNCHECKED_IMAGE forState:UIControlStateNormal];
                [_bt2 setImage:UNCHECKED_IMAGE forState:UIControlStateNormal];
                _action1 = FlightDetailCellActionActionCheck;
                _action2 = FlightDetailCellActionActionCheck;
                if(_logSection.off && _logSection.on) {
                    _sliderValueLabel3.hidden = NO;
                }
                _slider3.hidden = NO;
                
                if (_logSection.trainingTime.boolValue) {
                    [_bt1 setImage:CHECKED_IMAGE forState:UIControlStateNormal];
                    
                }
                if (_logSection.flightseeingTime.boolValue) {
                    [_bt2 setImage:CHECKED_IMAGE forState:UIControlStateNormal];
                    
                }
                if (_logSection.flightTime.integerValue >0) {
                    _slider3.maximumValue = _logSection.flightTime.integerValue;
                }
                else{
                    _slider3.userInteractionEnabled = NO;
                }
                
                if (_logSection.allVFR.boolValue || _logSection.allIFR.boolValue) {
                    _slider3.userInteractionEnabled = NO;
                }
                _slider3.value = _logSection.vFRTimeIFRTime.integerValue;
                _sliderValueLabel3.text = [NSString stringWithFormat:@"%d",(int)_logSection.vFRTimeIFRTime.integerValue];
                
                float x1 = _slider3.frame.origin.x + _sliderValueLabel3.frame.size.width/2.0;
                float y1 = _slider3.frame.origin.x + _slider3.frame.size.width - _sliderValueLabel3.frame.size.width/2.0;
                pixelForAPercent2 = (y1-x1)/100.;
                _sliderValueLabel3.center = CGPointMake(745+(_slider3.value/_slider3.maximumValue*100)*pixelForAPercent2, 7);
            }
                break;
        }
    }
    
    [self didFinishSetData:iscanEdit];
}

- (void)didFinishSetData:(BOOL)isCanEdit {
    if (isCanEdit) {
        return;
    }
    for (UIView *view in self.contentView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            
            UIButton *bt = (UIButton *)view;
            if ([bt.imageView.image isEqual:CHECKED_IMAGE] || [bt.imageView.image isEqual:UNCHECKED_IMAGE]) {
                bt.userInteractionEnabled = NO;
                continue;
            }
            bt.hidden = YES;
        }
        else if ([view isKindOfClass:[UISlider class]]) {
            [(UISlider *)view setUserInteractionEnabled:NO];
        }
        else if([view isKindOfClass:[UITextField class]]){
            [(UITextField *)view setUserInteractionEnabled:NO];
        }
    }
}

#pragma mark - IBActions
- (IBAction)actionButton1:(UIButton *)sender {
    if (_handler) {
        if (_action1 == FlightDetailCellActionActionDropDown) {
            _handler(YES,1,self);
        }
        else if (_action1 == FlightDetailCellActionActionCheck) {
            [self updateCheckValue:sender isFirstButton:YES orSecondButton:NO];
        }
        else if(_action1 == FlightDetailCellActionActionEdit) {
            _value1TextField.enabled = YES;
            _value1TextField.delegate = self;
            [_value1TextField becomeFirstResponder];
            // remark
        }
        else if (_action1 == FlightDetailCellActionActionSelectImage){
            _handler (YES, 4, self);
        }
    }
}

- (IBAction)actionButton2:(UIButton *)sender {
    if (_handler) {
        if (_action2 == FlightDetailCellActionActionDropDown) {
            _handler(YES,2,self);
        }
        else if (_action2 == FlightDetailCellActionActionCheck) {
            [self updateCheckValue:sender isFirstButton:NO orSecondButton:YES];
        }
        else if(_action2 == FlightDetailCellActionActionEdit)  {
            _value2TextField.enabled = YES;
            _value2TextField.delegate = self;
            [_value2TextField becomeFirstResponder];
        }
    }
}

- (IBAction)actionButton3:(UIButton *)sender {
    if (_handler) {
        if (_action3 == FlightDetailCellActionActionDropDown) {
            _handler(YES,3,self);
        }
        else if (_action3 == FlightDetailCellActionActionCheck) {
            [self updateCheckValue:sender isFirstButton:NO orSecondButton:NO];
        }
        else if(_action3 == FlightDetailCellActionActionEdit) {
            _value3TextField.enabled = YES;
            _value3TextField.delegate = self;
            [_value3TextField becomeFirstResponder];
        }
    }
}

- (IBAction)actionRangeFrom:(UIButton *)sender {
    _rangeFromTextField.enabled = YES;
    _rangeFromTextField.delegate = self;
    [_rangeFromTextField becomeFirstResponder];
}

- (IBAction)actionRangeTo:(UIButton *)sender {
    _rangeToTextField.enabled = YES;
    _rangeToTextField.delegate = self;
    [_rangeToTextField becomeFirstResponder];
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    if (_indexPath.section == 1 && _indexPath.row == 4) {
        if ([sender isEqual:_slider3]) {
            _logSection.vFRTimeIFRTime = [NSNumber numberWithInteger:(NSInteger) sender.value];
            _sliderValueLabel3.text = [NSString stringWithFormat:@"%d",(int)sender.value];
            _sliderValueLabel3.center = CGPointMake(745+(_slider3.value/_slider3.maximumValue*100)*pixelForAPercent2, 7);
        }
    }
    if ([sender isEqual:_slider2]) {
        _logSection.dayTime = [NSNumber numberWithInteger:(NSInteger) sender.value];
        _sliderValueLabel2.text = [NSString stringWithFormat:@"%d",(int)sender.value];
        _sliderValueLabel2.center = CGPointMake(433+(_slider2.value/_slider2.maximumValue*100)*pixelForAPercent1, 7);
    }
    
    if (_handler) {
        _handler(NO,0,nil);
    }
}

- (void)updateCheckValue:(UIButton *)sender isFirstButton:(BOOL)isFirstButton orSecondButton:(BOOL) isSecondButton {
    
    if (_indexPath.section == 0 && _indexPath.row ==0 && isFirstButton) {
        if (_logSection.loadSchedule.boolValue == NO) {
            [sender setImage:CHECKED_IMAGE forState:UIControlStateNormal];
            _logSection.loadSchedule = [NSNumber numberWithBool:YES];
        }
        else {
            [sender setImage:UNCHECKED_IMAGE forState:UIControlStateNormal];
            _logSection.loadSchedule = [NSNumber numberWithBool:NO];
        }
    }
    if (_indexPath.section == 0 && _indexPath.row ==0 &&isSecondButton) {
        if (_logSection.acStarted.boolValue == NO) {
            [sender setImage:CHECKED_IMAGE forState:UIControlStateNormal];
            _logSection.acStarted = [NSNumber numberWithBool:YES];
        }
        else {
            [sender setImage:UNCHECKED_IMAGE forState:UIControlStateNormal];
            _logSection.acStarted = [NSNumber numberWithBool:NO];
        }
    }
    
    if (_indexPath.section == 1) {
        if (_indexPath.row == 1) {
            if (isFirstButton) {
                if (_logSection.allDayTime.boolValue) {
                    _logSection.allDayTime = [NSNumber numberWithBool:NO];
                }
                else {
                    _logSection.allDayTime = [NSNumber numberWithBool:YES];
                    _logSection.nVGTimeP = @0;
                    _logSection.nVGTimeC = @0;
                }
            }
            else {
                if (_logSection.allVFR.boolValue) {
                    _logSection.allVFR = [NSNumber numberWithBool:NO];
                }
                else {
                    _logSection.allVFR = [NSNumber numberWithBool:YES];
                }
            }
        }
        
        else if (_indexPath.row == 2) {
            if (isFirstButton) {
                if (_logSection.allIFR.boolValue) {
                    _logSection.allIFR = [NSNumber numberWithBool:NO];
                }
                else {
                    _logSection.allIFR = [NSNumber numberWithBool:YES];
                }
            }
            else if (isSecondButton) {
                if (_logSection.offshoreTime.boolValue) {
                    _logSection.offshoreTime = [NSNumber numberWithBool:NO];
                }
                else {
                    _logSection.offshoreTime = [NSNumber numberWithBool:YES];
                }
            }
            else{
                if (_logSection.internationalTime.boolValue) {
                    _logSection.internationalTime = [NSNumber numberWithBool:NO];
                }
                else {
                    _logSection.internationalTime = [NSNumber numberWithBool:YES];
                }
            }
        }
        
        else if (_indexPath.row == 3) {
            if (isFirstButton) {
                if (_logSection.mountainTime.boolValue) {
                    _logSection.mountainTime = [NSNumber numberWithBool:NO];
                }
                else {
                    _logSection.mountainTime = [NSNumber numberWithBool:YES];
                }
            }
            else if (isSecondButton) {
                if (_logSection.articTime.boolValue) {
                    _logSection.articTime = [NSNumber numberWithBool:NO];
                }
                else {
                    _logSection.articTime = [NSNumber numberWithBool:YES];
                }
            }
            else {
                if (_logSection.airMedicalTime.boolValue) {
                    _logSection.airMedicalTime = [NSNumber numberWithBool:NO];
                }
                else {
                    _logSection.airMedicalTime = [NSNumber numberWithBool:YES];
                }
            }
        }
        else if (_indexPath.row == 4) {
            if (isFirstButton) {
                if (_logSection.trainingTime.boolValue) {
                    _logSection.trainingTime = [NSNumber numberWithBool:NO];
                }
                else {
                    _logSection.trainingTime = [NSNumber numberWithBool:YES];
                }
            }
            else {
                if (_logSection.flightseeingTime.boolValue) {
                    _logSection.flightseeingTime = [NSNumber numberWithBool:NO];
                }
                else {
                    _logSection.flightseeingTime = [NSNumber numberWithBool:YES];
                }
            }
        }
    }
    
    if (_handler) {
        _handler(NO,0,nil);
    }
}

#pragma mark - TextField Delegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(_indexPath.section==0) {
        NSString *resultingString = [textField.text stringByReplacingCharactersInRange: range withString: string];
        if ([resultingString length] == 0 || (_indexPath.row==6 && textField == _value1TextField)) {
            [self textFieldDidChangeEditing:textField text:resultingString];
            return YES;
        }
        if((_indexPath.row==5&&textField==_value3TextField)) {
            NSError *error = nil;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expressionInt options:NSRegularExpressionCaseInsensitive error:&error];
            NSUInteger numberOfMatches = [regex numberOfMatchesInString:resultingString options:0 range:NSMakeRange(0, [resultingString length])];
            if (numberOfMatches == 0)
                return NO;
            if([resultingString doubleValue]>MAX_INTEGER)
                return NO;
            if ([resultingString length] > 9) {
                return NO;
            }
            [self textFieldDidChangeEditing:textField text:resultingString];
            return YES;
        }
        else {
            NSError *error = nil;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
            NSUInteger numberOfMatches = [regex numberOfMatchesInString:resultingString options:0 range:NSMakeRange(0, [resultingString length])];
            if (numberOfMatches == 0)
                return NO;
            if([resultingString doubleValue]>MAX_INTEGER)
                return NO;
            if ([resultingString length] > 9) {
                return NO;
            }
            if((textField==_value1TextField && (_indexPath.row==4||_indexPath.row==5)) || (textField==_value2TextField && _indexPath.row==5)) {
                if([resultingString doubleValue]>=_maxGrossWeight) {
                    return NO;
                }   // T/O W, Cargo Weight
            }
            
            [self textFieldDidChangeEditing:textField text:resultingString];
            return YES;
        }
    }
    return YES;
}

- (void)textFieldDidChangeEditing:(UITextField *)textField text:(NSString *)text {
    switch (_indexPath.row) {
        case 0: {
        }
            break;
            
        case 1: {
            
            if (text.length >0) {
                _logSection.fuel = [NSNumber numberWithDouble:text.doubleValue];
            }
            else{
                _logSection.fuel = nil;
            }
        }
            break;
            
        case 2: {

        }
            break;
            
        case 3: {
            if (textField == _value1TextField) {
                if (text.length >0) {
                    _logSection.tOW = [NSNumber numberWithDouble:text.doubleValue];
                }
                else{
                    _logSection.tOW = nil;
                }
            }
            if (textField == _value2TextField) {
                if (text.length >0) {
                    _logSection.cG = [NSNumber numberWithDouble:text.doubleValue];
                }
                else{
                    _logSection.cG = nil;
                }
            }
            else if (textField == _rangeToTextField) {
                if (text.length >0) {
                    _logSection.rangeTo = [NSNumber numberWithDouble:text.doubleValue];
                }
                else{
                    _logSection.rangeTo = nil;
                }
            }
            else if (textField == _rangeFromTextField) {
                if (text.length >0) {
                    _logSection.rangeFrom = [NSNumber numberWithDouble:text.doubleValue];
                }
                else{
                    _logSection.rangeFrom = nil;
                }
            }
        }
            break;
            
        case 4: {
            if(textField == _value1TextField) {
                if (text.length >0) {
                    _logSection.cargoWeight = [NSNumber numberWithDouble:text.doubleValue];
                }
                else{
                    _logSection.cargoWeight = nil;
                }
            }
            else if (textField == _value2TextField) {
                if (text.length >0) {
                    _logSection.fuelAmount = [NSNumber numberWithDouble:text.doubleValue];
                    
                    // update fuel owner
                    _title3Label.enabled = YES;
                    _bt3.enabled = YES;
                    _value3TextField.placeholder = @"Required";
                    _value3TextField.hidden  = NO;
                    if (_logSection.eraFuelOwner) {
                        _value3TextField.text = _logSection.eraFuelOwner.name;
                    }
                }
                else{
                    _logSection.fuelAmount = nil;
                    //_logSection.eraFuelOwner = nil;
                    
                    // update fuel owner
                    _title3Label.enabled = NO;
                    _bt3.enabled = NO;
                    _value3TextField.text = @"";
                    _value3TextField.placeholder = @"";
                    _value3TextField.hidden = YES;
                }
            }
        }
            break;
            
        case 5: {
            if(textField == _value3TextField) {
                if (text.length >0 && ![text isEqualToString:@"0"]) {
                    _logSection.patients = [NSNumber numberWithInteger:text.integerValue];
                }
                else{
                    _logSection.patients = nil;
                }
            }
            else if (textField == _value2TextField) {
                if (text.length >0 && ![text isEqualToString:@"0"]) {
                    _logSection.baggage = [NSNumber numberWithInteger:text.doubleValue];
                }
                else{
                    _logSection.baggage = nil;
                }
            }
            else{
                if (text.length >0 && ![text isEqualToString:@"0"]) {
                    _logSection.paxWeight = [NSNumber numberWithDouble:text.doubleValue];
                }
                else{
                    _logSection.paxWeight = nil;
                }
            }
            
        }
            break;
            
        case 6: {
            if(textField == _value1TextField) {
                if (text.length != 0) {
                    _logSection.remarks = text;
                }
                else{
                    _logSection.remarks = nil;
                }
            }
        }
            break;
            
        default:
            break;
    }
}

@end
