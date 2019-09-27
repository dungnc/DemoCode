//
//  FlightDetailCell.h
//  Helicopter
//
//  Created by Nguyen Chi Dung on 9/26/14.
//  Copyright (c) 2014 Era Helicopter. All rights reserved.
//

#import "ERATableViewCell.h"

typedef NS_ENUM(NSInteger, FlightDetailCellAction) {
    FlightDetailCellActionActionCheck =1,
    FlightDetailCellActionActionEdit =2,
    FlightDetailCellActionActionDropDown =3,
    FlightDetailCellActionActionSelectImage =4,
    FlightDetailCellActionActionNone =0
};

@interface FlightDetailCell : ERATableViewCell
@property (weak, nonatomic) IBOutlet UILabel *line1Label;
@property (weak, nonatomic) IBOutlet UILabel *line2Label;
@property (nonatomic, weak) IBOutlet UILabel *title1Label, *title2Label, *title3Label;
@property (weak, nonatomic) IBOutlet UILabel *title21Label;
@property (weak, nonatomic) IBOutlet UILabel *title22Label;
@property (nonatomic, weak) IBOutlet UILabel *rangeToLabel;
@property (nonatomic, weak) IBOutlet UITextField *value1TextField, *value2TextField,*value3TextField;
@property (nonatomic, weak) IBOutlet UITextField *rangeFromTextField, *rangeToTextField;
@property (nonatomic, weak) IBOutlet UIButton *bt1, *bt2, *bt3;
@property (nonatomic, weak) IBOutlet UIButton *btRangeFrom, *btRangeTo;
@property (nonatomic, weak) IBOutlet UISlider *slider2,*slider3;
@property (nonatomic, weak) IBOutlet UILabel *sliderValueLabel2,* sliderValueLabel3;
@property (nonatomic, strong) NSString *flightLogId;
@property (nonatomic, strong) NSIndexPath *indexPath;
@end
