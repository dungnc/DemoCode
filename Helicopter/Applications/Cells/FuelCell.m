//
//  FuelCell.m
//  Helicopter
//
//  Created by Nguyen Chi Dung on 9/26/14.
//  Copyright (c) 2014 Era Helicopter. All rights reserved.
//

#import "FuelCell.h"
#import "ERA_LogLocation.h"
#import "ERA_Location.h"
#import "ERA_LogSection.h"
#import "ERA_FuelOwner.h"
#import "LogLocationData.h"
#import "NSObject+Block.h"

@interface FuelCell()<UITextFieldDelegate> {
    LogLocationData *_logLocation;
    NSArray *_listLogsection;
}

@end

@implementation FuelCell

- (void)setLogLocation:(LogLocationData *)logLocation logSections:(NSArray *)logSections canEdit:(BOOL)isCanEdit withIndexPath:(NSIndexPath *)indexPath completionHandler:(VNTableViewCellBlock)handler {
    _logLocation = logLocation;
    _listLogsection = logSections;
    _handler = handler;
    _indexPath = indexPath;
    
    _ownerTextField.keyboardType = UIKeyboardTypeDefault;
    _amountTextField.keyboardType = UIKeyboardTypeDefault;
    _ownerTextField.userInteractionEnabled = NO;
    _gallonsTextField.userInteractionEnabled = NO;
    
    if (indexPath.row == 0) {
        _btAmount.hidden = YES;
        _ownerTextField.frame = CGRectMake(512, 0, 412, 25);
        _amountTextField.frame = CGRectMake(923, 0, 101, 25);
        _gallonsTextField.font = [UIFont boldSystemFontOfSize:13];
        _ownerTextField.font = [UIFont boldSystemFontOfSize:13];
        _amountTextField.font = [UIFont boldSystemFontOfSize:13];
        _locationLabel.font = [UIFont boldSystemFontOfSize:13];
        
        _amountTextField.userInteractionEnabled = NO;
        _locationLabel.text = @"LOCATION";
        _gallonsTextField.text = @"GALLONS";
        _ownerTextField.text = @"OWNER";
        _amountTextField.text = @"AMOUNT";
    }
    else {
        _btAmount.hidden = NO;
        _ownerTextField.frame = CGRectMake(517, 0, 402, 43);
        _amountTextField.frame = CGRectMake(928, 0, 72, 43);
        _gallonsTextField.font = [UIFont systemFontOfSize:13];
        _ownerTextField.font = [UIFont systemFontOfSize:13];
        _amountTextField.font = [UIFont systemFontOfSize:13];
        _locationLabel.font = [UIFont systemFontOfSize:13];
        _amountTextField.userInteractionEnabled = YES;
        
        _locationLabel.text = logLocation.location;
        double gallons = 0;
        NSString *fuelOwner = @"";
        for (ERA_LogSection *logSection in logSections) {
            if ([logSection.toLocation.name isEqualToString:_logLocation.location]) {
                gallons+= logSection.fuelAmount.doubleValue;
                if(logSection.fuelOwner && logSection.fuelOwner.name.length>0) {
                    fuelOwner = logSection.fuelOwner.name;
                }
            }
        }
        _gallonsTextField.text = [@(gallons) getNumberString];
        
        if (_logLocation.amount.length >0) {
            _amountTextField.text = _logLocation.amount;
        }
        else {
            _amountTextField.text = @"";
        }
        _ownerTextField.text = fuelOwner;
    }
    [self didFinishSetData:isCanEdit];
}

- (IBAction)actionOwner:(UIButton *)sender {
    _ownerTextField.enabled = YES;
    _ownerTextField.delegate =self;
    [_ownerTextField becomeFirstResponder];
}

- (IBAction)actionAmount:(UIButton *)sender {
    _amountTextField.enabled = YES;
    _amountTextField.delegate = self;
    [_amountTextField becomeFirstResponder];
}

#pragma mark - TextField Delegate Methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *resultingString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    
    // Textfield empty
    if (![self validateSpecialCharactor:resultingString]) {
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (_logLocation) {
        _logLocation.amount = textField.text;
    }
    if (_handler) {
        _handler(NO,0,_indexPath);
    }
}


@end
