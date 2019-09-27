//
//  LogViewController.m
//  Helicopter
//
//  Created by Nguyen Chi Dung on 9/26/14.
//  Copyright (c) 2014 Era Helicopter. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "Singleton.h"
#import "UIAlertView+Block.h"
#import "CDHelper.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import "NSObject+Block.h"
#import <FCFileManager.h>
#import "UIColor+CreateImage.h"
#import "NSString+Keychain.h"
#import "API.h"
#import "zipzap.h"
#import <FCFileManager.h>
#import <KVNProgress/KVNProgress.h>
#import "VPNHelper.h"

// Import views, viewcontrollers
#import "LogViewController.h"
#import "DatePickerViewController.h"
#import "SelectionViewController.h"
#import "FlightLogTableViewController.h"
#import "AddLogCell.h"
#import "FlightLogCell.h"
#import "FuelCell.h"
#import "PilotCell.h"
#import "AddLogCell_Portrait.h"
#import "FlightLogCell_Portrait.h"
#import "FuelCell_Portrait.h"
#import "PilotCell_Portrait.h"

// Import models
#import "ERA_Log.h"
#import "ERA_Employee.h"
#import "ERA_Customer.h"
#import "ERA_Model.h"
#import "ERA_AC.h"
#import "ERA_JobName.h"
#import "ERA_SlotPurpose.h"
#import "ERA_LocationType.h"
#import "ERA_Location.h"
#import "ERA_ContractCharter.h"
#import "ERA_LogSection.h"
#import "ERA_LogLocation.h"
#import "ERA_FuelOwner.h"
#import "NSDate+Helper.h"
#import "LogData.h"
#import "LogLocationData.h"
#import "FlightLogObject.h"
#import "LogSectionData.h"
#import "LogLocationData.h"


@interface LogViewController () <SWTableViewCellDelegate,UITextFieldDelegate, MFMailComposeViewControllerDelegate, UIPopoverControllerDelegate, UIGestureRecognizerDelegate> {
    BOOL _canEdit;
    BOOL _isGenerated;
    UITapGestureRecognizer *_singleTap;
    UIPopoverController *_popoverViewController;
    NSMutableArray    *_listLogSections;
    NSMutableArray    *_listLogLocations;
    NSMutableArray    *_listAmountOfFuelOwner;
    
    ERA_Log              *_log;
    LogData *_logData, *_originLog;
}
@end

@implementation LogViewController
@synthesize viewType = _viewType;
@synthesize aLogToEdit = _aLogToEdit;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setBackgroundImage:[AppColor imageWithSize:CGSizeMake(1024, 64)] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    
    [self resetViewAfterSubmitSuccessOrDidLoadVC:_viewType];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Orientation Methods
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark - API methods

- (void)actionGenerateFL:(UIBarButtonItem *)sender {
    [[HUDController sharedInstance] showHUDInView:self withDetailMessage:nil];
    [[VPNHelper sharedHelper] enableVPNConnectionWithComplete:^(NSError *error) {
        if (!error) {
            [API generateFLWithBlock:^(FlightLogObject *flightLog, NSError *error) {
                [[HUDController sharedInstance] removeHUD];
                [VPNHelper disableVPNConnection];
                if (error) {
                    [UIAlertView showWithTitle:@"Notice"
                                       message:error.localizedDescription
                             cancelButtonTitle:@"Ok"
                             otherButtonTitles:nil
                                      tapBlock:nil];
                } else {
                    // save lognumber after generate
                    self.title  = [NSString stringWithFormat:@"Add Flight Log: %06ld",(long)flightLog.logNumber];
                    _log.logNumber = [NSString stringWithFormat:@"%ld",(long)flightLog.logNumber];
                    _logData.logNumber = [NSString stringWithFormat:@"%ld",(long)flightLog.logNumber];
                    [[CDHelper shareManager] saveContext];
                    _isGenerated = YES;
                    
                    UIBarButtonItem *submitBBI = [self.navigationItem.rightBarButtonItems firstObject];
                    [submitBBI setTitle:@"Submit"];
                    [submitBBI setAction:@selector(actionSubmit:)];
                    UIBarButtonItem *saveBBI = [self.navigationItem.rightBarButtonItems lastObject];
                    saveBBI.enabled = YES;
                    self.tableView.dataSource = self;
                    [self.tableView reloadData];
                }
            }];

        } else {
            [[HUDController sharedInstance] removeHUD];
            [UIAlertView showWithTitle:@"Notice"
                               message:error.localizedDescription
                     cancelButtonTitle:@"Ok"
                     otherButtonTitles:nil
                              tapBlock:nil];
        }
    }];
}

- (void)actionSubmit:(UIBarButtonItem *)sender {
    [self resignAllTextfields];
    
    NSString *invalidedField = [_logData validateData:YES withIsHobbsFieldRequired:YES];
    if (invalidedField != nil) {
        
        if ([invalidedField isEqualToString:@"No Flight Reason"]) {
            invalidedField = NSLocalizedString(@"The actual flight log doesn't have any flight legs. Please check the No Flight checkbox and select a reason", nil);
        }
        else{
            invalidedField = [invalidedField stringByAppendingString:@" is required."];
        }
        
        [UIAlertView showWithTitle:@"Notice"
                           message:invalidedField
                 cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        return;
    }
    
    [UIAlertView showWithTitle:@"Would you like to submit flight log?" message:@"" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"OK"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex){
        if (buttonIndex == 0) {
            NSLog(@"Cancel");
        }
        else {
            NSMutableArray *_lstSectionData = [[NSMutableArray alloc] init];
            for (ERA_LogSection *logSection in _listLogSections) {
                LogSectionData *eralogSection = [[LogSectionData alloc] initWithERA_LogSection:logSection];
                [_lstSectionData addObject:eralogSection];
            }
            _logData.isSubmitted = [NSNumber numberWithBool:YES];
            
            //[KVNProgress setConfiguration:[self customKVNProgressUIConfiguration]];
            [KVNProgressConfiguration defaultConfiguration].backgroundType = KVNProgressBackgroundTypeSolid;
            [KVNProgress showWithStatus:@"Processing..."
                                 onView:self.navigationController.view];
            dispatch_queue_t private_queue = dispatch_queue_create("com.mag.ios.processdata", 0);
            dispatch_async(private_queue, ^(void) {
                NSString *zipPath = [self createZipFile];
                NSDictionary *dicLogData = [_logData toNSDictionary:_listLogLocations withListLogSection:_lstSectionData];
                NSString *str = [self createJsonParamsFromDictionary:dicLogData];
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [KVNProgress updateStatus:@"Uploading Data..."];
                    [API submitFlightLogData:str WithZipFile:zipPath andBlock:^(NSString *result, NSError *error) {
                        if (error) {
                            [KVNProgress showErrorWithStatus:@"Flight Log already exists. You need generate another Flight Log number"
                                                      onView:self.navigationController.view];
                            /*if (error.code == 409) {
                                
                                UIBarButtonItem *submitBBI = [self.navigationItem.rightBarButtonItems firstObject];
                                [submitBBI setTitle:@"Generate a #FL"];
                                [submitBBI setAction:@selector(actionGenerateFL:)];
                                
                            }*/
                        }else{
                            [KVNProgress showSuccessWithStatus:@"Success"
                                                        onView:self.navigationController.view];
                            [FCFileManager removeItemAtPath:zipPath];
                            [FCFileManager removeItemAtPath:[FCFileManager pathForCachesDirectoryWithPath:[NSString stringWithFormat:@"/log%@.zip",_log.logNumber]]];
                            [_log deleteEntity];
                            [[CDHelper shareManager] saveContext];
                            _isGenerated = NO;
                            [self resetViewAfterSubmitSuccessOrDidLoadVC:LogViewTypeAdd];
                        }
                    }];
                });
                
            });
            
        }
    }];
}


#pragma mark - Action methods
- (IBAction)onLogout:(id)sender{
    [self resignAllTextfields];
    
    [_logData addLogLocations:_listLogLocations];
    [_logData addLogSections:_listLogSections];
    BOOL isAdd = _viewType==LogViewTypeAdd?YES:NO;
    if ([_originLog compare:_logData isAddLog:isAdd]) {
        [UIAlertView showWithTitle:NSLocalizedString(@"Logout_Alert_Title", @"Notice")
                           message:NSLocalizedString(@"Logout_Alert_Msg", @"The employee number or password you entered is incorrect")
                 cancelButtonTitle:@"Cancel"
                 otherButtonTitles:@[@"OK"]
                          tapBlock:^(UIAlertView *alert, NSInteger index){
                              if (index!=alert.cancelButtonIndex) {
                                  if (_viewType == LogViewTypeAdd) {
                                      [[[CDHelper shareManager] managedObjectContext] rollback];
                                  }
                                  [NSString deleteKeychainValueForKey:kUsersUsername];
                                  [NSString deleteKeychainValueForKey:kUsersPassword];
                                  self.navigationController.navigationBarHidden = YES;
                                  [self.navigationController popToRootViewControllerAnimated:YES];
                              }
                          }];
        return;
    }
    
    [UIAlertView showWithTitle:NSLocalizedString(@"Back_Alert_Title", @"Notice")
                       message:NSLocalizedString(@"Back_Alert_Msg", @"Unsaved data will be lost. Do you want to save the changes before continuing?")
             cancelButtonTitle:@"No"
             otherButtonTitles:@[@"Yes"]
                      tapBlock:^(UIAlertView *alert, NSInteger index){
                          if (index==alert.cancelButtonIndex) {
                              if (_viewType == LogViewTypeAdd) {
                                  [_log deleteEntity];
                                  [[CDHelper shareManager] saveContext];
                                  
                              }
                              else {
                                  [[[CDHelper shareManager] managedObjectContext] rollback];
                              }
                              [UIAlertView showWithTitle:NSLocalizedString(@"Logout_Alert_Title", @"Notice")
                                                 message:NSLocalizedString(@"Logout_Alert_Msg", @"The employee number or password you entered is incorrect")
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:@[@"OK"]
                                                tapBlock:^(UIAlertView *alert, NSInteger index){
                                                    if (index!=alert.cancelButtonIndex) {
                                                        [NSString deleteKeychainValueForKey:kUsersUsername];
                                                        [NSString deleteKeychainValueForKey:kUsersPassword];
                                                        self.navigationController.navigationBarHidden = YES;
                                                        [self.navigationController popToRootViewControllerAnimated:YES];
                                                    }
                                                }];
                          }
                          else {
                              [self saveButtonTap];
                          }
                      }];
    
}
- (void)saveButtonTap {
    [self resignAllTextfields];
    [UIAlertView showWithTitle:@"Would you like to save as pending flight log?" message:@"" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Save"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex){
        if (buttonIndex == 0) {
            NSLog(@"Cancel");
        }
        else {
            // Add values for properties _log object
            _log = [_logData eRA_Log:_log];
            
            // Delete old ERA_LogLocation
            for (ERA_LogLocation *logLocation in _log.logLocations) {
                [logLocation deleteEntity];
            }
            // Add new ERA_LogLocation
            
            for (LogLocationData *logLocation in _listLogLocations) {
                ERA_LogLocation *eralogLocation = [ERA_LogLocation createEntity];
                eralogLocation = [logLocation eRA_LogLocation:eralogLocation];
                eralogLocation.log = _log;
            }
            
            for (ERA_LogSection *logSection in _listLogSections) {
                logSection.log = _log;
            }
            
            _log.isSubmitted = [NSNumber numberWithBool:NO];
            [[CDHelper shareManager] saveContext];
            
            
        }
    }];
}

- (void)showSelectionViewDateFromCGrect:(CGRect) rect inTableViewCell:(UITableViewCell *)cell withTextField:(UITextField *)textField {
    DatePickerViewController *pickerDate = [self.storyboard instantiateViewControllerWithIdentifier:@"DatePickerViewController"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:pickerDate];
    _popoverViewController = nil;
    _popoverViewController = [[UIPopoverController alloc] initWithContentViewController:navController];
    
    _popoverViewController.delegate = self;
    [_popoverViewController setPopoverContentSize:CGSizeMake(320, 252) animated:YES];
    
    [_popoverViewController presentPopoverFromRect:rect inView:cell.contentView  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    [pickerDate setCancelSelect:^{
        [_popoverViewController dismissPopoverAnimated:YES];
    }];
    [pickerDate setSaveSelect:^(NSDate *selectDate) {
        _logData.logDate = selectDate;
        [_popoverViewController dismissPopoverAnimated:YES];
        [self resignAllTextfields];
    }];
}

- (void)showSelectionViewFromCGrect:(CGRect)point atIndexpath:(NSIndexPath*)indexPath withTextField:(UITextField *)textField andIndex:(NSInteger )index {
    [self resignAllTextfields];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    SelectionViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectionViewController"];
    
    if (textField.text.length >0) {
        controller.valuePreviousSelected = textField.text;
    }
    
    SelectionType type = Log_Customer;
    
    if (_isLandscape) {
        switch (indexPath.section) {
            case 0: {
                switch (indexPath.row) {
                    case 0: {
                    }
                        break;
                        
                    case 1: {
                        if (index ==1) {
                            type = Log_Customer;
                        }
                        else if (index ==2) {
                            type = Log_ContractCharter;
                        }
                        else if (index ==3) {
                            type = Log_JobName;
                        }
                    }
                        break;
                        
                    default:
                        break;
                }
            }
                break;
                
            case 1: {
                switch (indexPath.row) {
                    case 0: {
                        if (index==1) {
                            type = Log_Base;
                        }
                        else if (index ==2) {
                            type = Log_AC;
                        }
                        else if (index ==3){
                            
                        }
                    }
                        break;
                    case 3:{
                        type = Log_NoFlightReason;
                    }
                    case 2: {
                        if (index==1) {
                            type = Log_CoPilot;
                            controller.picEmployee = _logData.eraPicEmployee;
                        }
                    }
                        break;
                        
                    default:
                        break;
                }
            }
                break;
                
            default:
                break;
        }
    }
    else {
        switch (indexPath.section) {
            case 0: {
                switch (indexPath.row) {
                    case 0: {
                        if (index ==2) {
                            type = Log_Customer;
                        }
                    }
                        break;
                        
                    case 1: {
                        if (index ==1) {
                            type = Log_ContractCharter;
                        }
                        else if (index ==2) {
                            type = Log_JobName;
                        }
                    }
                        break;
                        
                    default:
                        break;
                }
            }
                break;
                
            case 1: {
                switch (indexPath.row) {
                    case 0: {
                        if (index==1) {
                            type = Log_Base;
                        }
                        else if (index ==2) {
                            type = Log_AC;
                        }
                    }
                        break;
                        
                    case 5: {
                        type = Log_NoFlightReason;
                    }
                        break;
                        
                    case 3: {
                        if (index==1) {
                            type = Log_CoPilot;
                            controller.picEmployee = _logData.eraPicEmployee;
                        }
                    }
                        break;
                    default:
                        break;
                }
            }
                break;
                
            default:
                break;
        }
    }
    
    if(type==Log_Customer) {
        if(_logData.eraContractCharter) {
            [[Singleton sharedManager] setContractCharterUsing:_logData.eraContractCharter.contractCharterID.intValue];
        }
        else {
            [[Singleton sharedManager] setContractCharterUsing:0];
        }
        if(_logData.eraJobName) {
            [[Singleton sharedManager] setJobNameUsing:_logData.eraJobName.jobNameID.intValue];
        }
        else {
            [[Singleton sharedManager] setJobNameUsing:0];
        }
        if(_logData.eraCustomer) {
            [[Singleton sharedManager] setCustomerUsing:_logData.eraCustomer.customerID.intValue];
        }
        else {
            [[Singleton sharedManager] setCustomerUsing:0];
        }
    }
    else if(type==Log_ContractCharter || type==Log_JobName) {
        if(_logData.eraCustomer) {
            [[Singleton sharedManager] setCustomerUsing:_logData.eraCustomer.customerID.intValue];
        }
        else {
            [[Singleton sharedManager] setCustomerUsing:0];
        }
    }
    controller.selectionType = type;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    _popoverViewController = nil;
    _popoverViewController = [[UIPopoverController alloc] initWithContentViewController:navController];
    
    _popoverViewController.delegate = self;
    [_popoverViewController setPopoverContentSize:CGSizeMake(320, 400) animated:YES];
    [_popoverViewController presentPopoverFromRect:point inView:cell.contentView  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    [controller setCancelSelect:^{
        [_popoverViewController dismissPopoverAnimated:YES];
    }];
    
    [controller setSaveSelect:^(NSInteger selectedIndex,  NSString *selectedValue, NSObject *selectedObject) {
        switch (type) {
            case Log_Customer: {
                //               if (selectedIndex != 0) {
                if(_logData.eraCustomer.customerID.integerValue!=[(ERA_Customer *)selectedObject customerID].integerValue) {
                    _logData.eraContractCharter = nil;
                    _logData.eraJobName = nil;
                }
                _logData.eraCustomer = (ERA_Customer *)selectedObject;
            }
                break;
                
            case Log_ContractCharter: {
                if (selectedIndex != 0) {
                    _logData.eraContractCharter = (ERA_ContractCharter *)selectedObject;
                }
                else {
                    _logData.eraContractCharter = nil;
                }
            }
                break;
                
            case Log_JobName: {
                if (selectedIndex != 0) {
                    _logData.eraJobName = (ERA_JobName *)selectedObject;
                    _logData.eraContractCharter = ((ERA_JobName *)selectedObject).contractCharter;
                }
                else{
                    _logData.eraJobName = nil;
                    _logData.eraContractCharter = nil;
                }
            }
                break;
                
            case Log_NoFlightReason: {
                
                _logData.noFlightReason = (ERA_NoFlightReason *)selectedObject;
                
            }
                break;
                
            case Log_AC:{
                ERA_AC *newAC = (ERA_AC *)selectedObject;
                if(![newAC.model.name isEqualToString:_logData.eraAC.model.name] && _listLogSections.count>0) {
                    [UIAlertView showWithTitle:@"Notice"
                                       message:@"You can only change to A/C# belongs to the same Model. Otherwise, Please save current flight log and add a new one OR delete all flight leg(s) before changing A/C#."
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil
                                      tapBlock:nil];
                }
                else {
                    _logData.eraAC = (ERA_AC *)selectedObject;
                }
            }
                break;
                
            case Log_Base: {
                ERA_Location *obj = [ERA_Location findFirstByAttribute:@"name" withValue:selectedValue];
                if (obj) {
                    if(_listLogSections.count>0) {
                        _logData.eraBase = obj;
                    }
                    else {
                        _logData.eraBase = obj;
                    }
                }
            }
                break;
                
            case Log_CoPilot: {
                if (selectedIndex != 0) {
                    _logData.eraSicEmployee = (ERA_Employee *)selectedObject;
                    
                    for (ERA_LogSection *value in _listLogSections) {
                        value.nVGTimeC = 0;
                    }
                }
                else {
                    _logData.eraSicEmployee = nil;
                }
            }
                break;
                
            default:
                break;
        }
        [_popoverViewController dismissPopoverAnimated:YES];
        [self resignAllTextfields];
    }];
    
    [controller setUpdateContractName:^{
        _logData.eraContractCharter = [ERA_ContractCharter findFirstByAttribute:@"contractCharterID" withValue:[NSString stringWithFormat:@"%d",[[Singleton sharedManager] getContractCharterUsing]]];
        [self.tableView reloadData];
    }];
    [controller setUpdateJobName:^{
        _logData.eraJobName = [ERA_JobName findFirstByAttribute:@"jobNameID" withValue:[NSString stringWithFormat:@"%d",[[Singleton sharedManager] getJobNameUsing]]];
        [self.tableView reloadData];
    }];
    [controller setUpdateCustomer:^(NSString *newName) {
        _logData.customer = newName;
        [self.tableView reloadData];
    }];
}

#pragma mark - Privates
- (void)resetViewAfterSubmitSuccessOrDidLoadVC:(LogViewType)_type {
    //Init values, objects, array
    _listLogSections = [[NSMutableArray alloc] init];
    _listLogLocations = [[NSMutableArray alloc] init];
    _listAmountOfFuelOwner = [[NSMutableArray alloc] init];
    
    _canEdit = YES;
    
    if (_type == LogViewTypeEdit) {
        _log = _aLogToEdit;
        self.title  = [NSString stringWithFormat:@"Add Flight Log: %06ld",(long)[_log.logNumber integerValue]];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderID" ascending:YES];
        _listLogSections =  [[_log.logSections allObjects] mutableCopy];
        _listLogSections = [[_listLogSections sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
        
        for (ERA_LogLocation *logLocation in [[_log.logLocations sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"location.name" ascending:YES]]] mutableCopy]) {
            [_listLogLocations addObject:[[LogLocationData alloc] initWithERA_LogLocation:logLocation]];
        }
        
    }
    else if (_type == LogViewTypeAdd) {
        _log = [ERA_Log createEntity];
        self.title  = [NSString stringWithFormat:@"Add Flight Log"];
        _log.logNumber = @"";
        _log.hobbsOut = nil;
        _log.hobbsIn = nil;
        if (_isGenerated) {
            self.tableView.dataSource = self;
        } else {
            self.tableView.dataSource = nil;
        }
        
    }
    
    // Setup items on Navigation bar
    UIBarButtonItem *saveBBI = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonTap)];
    UIBarButtonItem *submitBBI = [[UIBarButtonItem alloc] initWithTitle:(_viewType == LogViewTypeAdd)?@"Generate a #FL":@"Submit" style:UIBarButtonItemStyleDone target:self action:(_viewType == LogViewTypeAdd)?@selector(actionGenerateFL:):@selector(actionSubmit:)];
    self.navigationItem.rightBarButtonItems = @[submitBBI,saveBBI];
    
    if (_viewType == LogViewTypeAdd) {
        _log.picEmployee = [[Singleton sharedManager] getEmployeeLogin];
        saveBBI.enabled = NO;
    }
    
    // Add logout button on navigation bar
    UIBarButtonItem *logOut = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStyleDone target:self action:@selector(onLogout:)];
    self.navigationItem.leftBarButtonItem = logOut;
    
    _logData = [[LogData alloc] initWithERA_Log:_log];
    _originLog = [[LogData alloc] initWithERA_Log:_log];
    int times = 0;
    for (ERA_LogSection *section in _listLogSections) {
        if (section.aCStarted.boolValue) {
            times+=1;
        }
    }
    _logData.timesStarted = [NSNumber numberWithInt:times];
    
    for (LogLocationData * locationData in _listLogLocations) {
        if (_listAmountOfFuelOwner.count == 0) {
            [_listAmountOfFuelOwner addObject:@{@"location": locationData.location, @"amount":(locationData.amount?locationData.amount:@"")}];
        }
        else{
            BOOL isFind = NO;
            for (NSDictionary *locationObj in _listAmountOfFuelOwner) {
                if ([[locationObj objectForKey:@"location"] isEqualToString:locationData.location]) {
                    [_listAmountOfFuelOwner replaceObjectAtIndex:[_listAmountOfFuelOwner indexOfObject:locationObj] withObject:@{@"location": locationData.location, @"amount":locationData.amount}];
                    isFind = YES;
                    break;
                }
            }
            if (!isFind) {
                [_listAmountOfFuelOwner addObject:@{@"location": locationData.location, @"amount":(locationData.amount?locationData.amount:@"")}];
            }
        }
    }
    // Add gesture to dissmis keyboard
    _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    _singleTap.delegate = self;
    [self.view addGestureRecognizer:_singleTap];
}
- (KVNProgressConfiguration *)customKVNProgressUIConfiguration
{
    KVNProgressConfiguration *configuration = [[KVNProgressConfiguration alloc] init];
    
    // See the documentation of KVNProgressConfiguration
    configuration.statusColor = [UIColor whiteColor];
    configuration.statusFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:15.0f];
    configuration.circleStrokeForegroundColor = [UIColor whiteColor];
    configuration.circleStrokeBackgroundColor = [UIColor colorWithWhite:1.0f alpha:0.3f];
    configuration.circleFillBackgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
    configuration.backgroundFillColor = [UIColor colorWithRed:0.173f green:0.263f blue:0.856f alpha:0.9f];
    configuration.backgroundTintColor = [UIColor colorWithRed:0.173f green:0.263f blue:0.856f alpha:0.4f];
    configuration.successColor = [UIColor whiteColor];
    configuration.errorColor = [UIColor whiteColor];
    configuration.circleSize = 110.0f;
    configuration.lineWidth = 1.0f;
    
    return configuration;
}
- (NSString *)createZipFile{
    
    if ([FCFileManager isDirectoryItemAtPath:[FCFileManager pathForCachesDirectoryWithPath:[NSString stringWithFormat:@"/log%@",_log.logNumber]]]) {
        NSString *path = [FCFileManager pathForCachesDirectory];
        
        ZZArchive* newArchive = [[ZZArchive alloc] initWithURL:[NSURL fileURLWithPath:
                          [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/log%@.zip",_log.logNumber]]]
                                                       options: @{ZZOpenOptionsCreateIfMissingKey: @YES}
                                                         error:nil];
        
        [newArchive updateEntries:@[[ZZArchiveEntry archiveEntryWithDirectoryName:[NSString stringWithFormat:@"/log%@",_log.logNumber]]]
                            error:nil];
        
        NSArray *arrImgFiles = [FCFileManager listFilesInDirectoryAtPath:[FCFileManager pathForCachesDirectoryWithPath:[NSString stringWithFormat:@"/log%@",_log.logNumber]] withExtension:@"jpeg"];
        NSMutableArray *imgsData = [[NSMutableArray alloc] init];
        for (NSString *strPath in arrImgFiles) {
            
            NSString *fileName = [[strPath componentsSeparatedByString:@"/"] lastObject];
            
            ZZArchiveEntry *entry = [ZZArchiveEntry archiveEntryWithFileName:[NSString stringWithFormat:@"/log%@/%@",_log.logNumber,fileName]
                                                                    compress:YES
                                                                   dataBlock:^(NSError** error)
                                             {
                                                 return  [FCFileManager readFileAtPathAsData:strPath];
                                             }];
            
            [imgsData addObject:entry];
        }
        NSError *error;
        if ([newArchive updateEntries:imgsData error:&error]) {
            return [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/log%@.zip",_log.logNumber]];
        }
    }
    return @"";
}
- (NSString*) createJsonParamsFromDictionary:(NSDictionary*)dict{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization
                        dataWithJSONObject:dict
                        options:NSJSONWritingPrettyPrinted
                        error:&error];
    if ([jsonData length] > 0 && error == nil){
        NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                     encoding:NSUTF8StringEncoding];
        NSLog(@"JSON String = %@", jsonString);
        return jsonString;
    }
    else if ([jsonData length] == 0 && error == nil){
        NSLog(@"No data was returned after serialization.");
        
    }
    else if (error != nil){
        NSLog(@"An error happened = %@", error);
        
    }
    return @"";
}
- (void)insertAFlightLeg:(NSIndexPath*)index{
    [self resignAllTextfields];
    NSString *invalidedField = [_logData validateData:NO withIsHobbsFieldRequired:NO];
    if (invalidedField) {
        invalidedField = [invalidedField stringByAppendingString:@" is required."];
        [UIAlertView showWithTitle:@"Notice"
                           message:invalidedField
                 cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
    }
    
    else if (_listLogSections.count ==11) {
        [UIAlertView showWithTitle:@"Notice"
                           message:@"You only can add up to a maximum of 11 Flight Legs."
                 cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
    }
    else {
        
        FlightLogTableViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FlightLogTableViewController"];
        controller.model = _logData.eraModel;
        controller.viewType = FlightLegViewTypeInsert;
        controller.operationWeight = _logData.operationalWeight;
        controller.maxGrossWeight = _logData.maxGrossWeight;
        controller.listLogSections = _listLogSections;
        controller.flightLogNumber = _logData.logNumber;
        controller.eraSicEmployee = _logData.eraSicEmployee;
        if (index.row == 1) {
            ERA_LogSection *nextLogLeg = [_listLogSections objectAtIndex:0];
            
            if ([[[Singleton sharedTimeFormatter] stringFromDate:nextLogLeg.off] isEqualToString:@"00:00"]) {
                [UIAlertView showWithTitle:@"Notice"
                                   message:@"Operation denied. Please verify the On and Off times of the existing flight legs and then try again."
                         cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
                return;
            }
            
            ERA_Location *from = _logData.eraBase;
            controller.nextToLocation = nil;
            controller.fromLocation = from;
            controller.previousOnTime = [nextLogLeg.off removeDateAndSecond];
            controller.nextOffTime = [[[Singleton sharedTimeFormatter] dateFromString:@"00:00"] removeDateAndSecond];
            controller.orderID = 0;
            [controller setSaveAddEdit:^(ERA_LogSection *logSection, FlightLogTableViewController *vc) {
                [vc.navigationController popViewControllerAnimated:YES];
                nextLogLeg.fromLocation = logSection.toLocation;
                nextLogLeg.orderID = [NSNumber numberWithInteger:2];
                logSection.log = _log;
                logSection.orderID = [NSNumber numberWithInteger:1];
                if (logSection.aCStarted.boolValue) {
                    _logData.timesStarted = [NSNumber numberWithInt:_logData.timesStarted.intValue+1];
                }
                
                for (ERA_LogSection *lSection in _listLogSections) {
                    lSection.slotPurpose = logSection.slotPurpose;
                }
                [_listLogSections insertObject:logSection atIndex:0];
                
                [self reOrderWithEachLogSectionInList];
                NSArray *insertIndexPaths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:(1) inSection:2],nil];
                
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationRight];
                [self.tableView endUpdates];
                
                BOOL stop = NO;
                for (LogLocationData *zObject in _listLogLocations) {
                    if ([logSection.toLocation.name isEqualToString:zObject.location]) {
                        stop = YES;
                        break;
                    }
                }
                if ([logSection.fuelAmount doubleValue] == 0) {
                    stop = YES;
                }
                if (!stop) {
                    LogLocationData * newObject = [[LogLocationData alloc] init];
                    newObject.location = logSection.toLocation.name;
                    [_listLogLocations addObject:newObject];
                }
                
                for(int index = 0; index < _listLogSections.count; index++) {
                    ERA_LogSection *obj = _listLogSections[index];
                    if (obj == logSection) {
                        [_listLogSections replaceObjectAtIndex:index withObject:logSection];
                    }
                    else {
                        if (logSection.fuelAmount.doubleValue >0) {
                            if(  [obj.toLocation.locationID isEqual:logSection.toLocation.locationID]) {
                                obj.fuelOwner = logSection.fuelOwner;
                            }
                        }
                    }
                }
                _logData.logSections = _listLogSections;
                [_listLogLocations sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"location" ascending:YES] ]];
                
                [self.tableView reloadData];
                // Show toast message
                [[ToastController sharedInstance] showToastInView:self withTitle:@"Success" withDetailMessage:@"Flight Leg is inserted successfully" timeout:4];
            }];
        }else{
            ERA_LogSection *touchFlightLeg = [_listLogSections objectAtIndex:index.row - 1];
            ERA_LogSection *previousTouchFlightLeg = [_listLogSections objectAtIndex:index.row - 2];
            
            if ([[[Singleton sharedTimeFormatter] stringFromDate:touchFlightLeg.off] isEqualToString:[[Singleton sharedTimeFormatter] stringFromDate:previousTouchFlightLeg.on]]) {
                [UIAlertView showWithTitle:@"Notice"
                                   message:@"Operation denied. Please verify the On and Off times of the existing flight legs and then try again."
                         cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
                return;
            }else{
                
                controller.previousOnTime = [touchFlightLeg.off removeDateAndSecond];
                controller.nextOffTime = [previousTouchFlightLeg.on removeDateAndSecond];
                controller.nextToLocation = nil;
                controller.fromLocation = previousTouchFlightLeg.toLocation;
                controller.orderID = index.row-1;
                
                [controller setSaveAddEdit:^(ERA_LogSection *logSection, FlightLogTableViewController *vc) {
                    [vc.navigationController popViewControllerAnimated:YES];
                    touchFlightLeg.fromLocation = logSection.toLocation;
                    logSection.log = _log;
                    logSection.orderID = [NSNumber numberWithInteger:index.row-1];
                    if (logSection.aCStarted.boolValue) {
                        _logData.timesStarted = [NSNumber numberWithInt:_logData.timesStarted.intValue+1];
                    }
                    
                    //[_listLogSections addObject:logSection];
                    [_listLogSections insertObject:logSection atIndex:index.row-1];
                    [self reOrderWithEachLogSectionInList];
                    NSArray *insertIndexPaths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:(index.row ) inSection:2],nil];
                    
                    [self.tableView beginUpdates];
                    [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationRight];
                    [self.tableView endUpdates];
                    
                    BOOL stop = NO;
                    for (LogLocationData *zObject in _listLogLocations) {
                        if ([logSection.toLocation.name isEqualToString:zObject.location] ) {
                            stop = YES;
                            break;
                        }
                    }
                    if ([logSection.fuelAmount doubleValue] == 0) {
                        stop = YES;
                    }
                    if (!stop) {
                        LogLocationData * newObject = [[LogLocationData alloc] init];
                        newObject.location = logSection.toLocation.name;
                        [_listLogLocations addObject:newObject];
                    }
                    
                    for(int index = 0; index < _listLogSections.count; index++) {
                        ERA_LogSection *obj = _listLogSections[index];
                        if (obj == logSection) {
                            [_listLogSections replaceObjectAtIndex:index withObject:logSection];
                        }
                        else {
                            if (logSection.fuelAmount.doubleValue >0) {
                                if(  [obj.toLocation.locationID isEqual:logSection.toLocation.locationID]) {
                                    obj.fuelOwner = logSection.fuelOwner;
                                }
                            }
                        }
                    }
                    _logData.logSections = _listLogSections;
                    [_listLogLocations sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"location" ascending:YES] ]];
                    
                    [self.tableView reloadData];
                    // Show toast message
                    [[ToastController sharedInstance] showToastInView:self withTitle:@"Success" withDetailMessage:@"Flight Leg is added successfully" timeout:4];
                }];
            }
        }
        
        [self.navigationController pushViewController:controller animated:YES];
        
        
    }
}

- (IBAction)addFightLogSectionTap:(id)sender {
    [self resignAllTextfields];
    NSString *invalidedField = [_logData validateData:NO withIsHobbsFieldRequired:NO];
    if (invalidedField) {
        invalidedField = [invalidedField stringByAppendingString:@" is required."];
        [UIAlertView showWithTitle:@"Notice"
                           message:invalidedField
                 cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
    }
    
    else if (_listLogSections.count ==11) {
        [UIAlertView showWithTitle:@"Notice"
                           message:@"You only can add up to a maximum of 11 Flight Legs."
                 cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
    }
    else {
        FlightLogTableViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FlightLogTableViewController"];
        controller.model = _logData.eraModel;
        controller.viewType = FlightLegViewTypeAdd;
        controller.orderID = _listLogSections.count + 1;
        controller.eraSicEmployee = _logData.eraSicEmployee;
        
        if(_listLogSections.count==0) {
            controller.previousOnTime = [[[Singleton sharedTimeFormatter] dateFromString:@"00:00"] removeDateAndSecond];
            controller.nextOffTime = [[[Singleton sharedTimeFormatter] dateFromString:@"23:59"] removeDateAndSecond];
        }
        else {
            ERA_LogSection *previousLogLeg = [_listLogSections lastObject];
            controller.previousOnTime = [previousLogLeg.on removeDateAndSecond];
            controller.nextOffTime = [[[Singleton sharedTimeFormatter] dateFromString:@"23:59"] removeDateAndSecond];
        }
        
        
        ERA_Location *from = _logData.eraBase;
        controller.nextToLocation = nil;
        if (_listLogSections.count >0) {
            from = [(ERA_LogSection *) [_listLogSections lastObject] toLocation];
        }
        controller.fromLocation = from;
        controller.operationWeight = _logData.operationalWeight;
        controller.maxGrossWeight = _logData.maxGrossWeight;
        controller.listLogSections = _listLogSections;
        controller.flightLogNumber = _logData.logNumber;
        [self.navigationController pushViewController:controller animated:YES];
        
        [controller setSaveAddEdit:^(ERA_LogSection *logSection, FlightLogTableViewController *vc) {
            [vc.navigationController popViewControllerAnimated:YES];
            //Process flight leg object return back
            
            logSection.log = _log;
            logSection.orderID = [NSNumber numberWithInteger:_listLogSections.count+1];
            if (logSection.aCStarted.boolValue) {
                _logData.timesStarted = [NSNumber numberWithInt:_logData.timesStarted.intValue+1];
            }
            
            [_listLogSections addObject:logSection];
            [self reOrderWithEachLogSectionInList];
            NSArray *insertIndexPaths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:(_listLogSections.count) inSection:2],nil];
            
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationRight];
            [self.tableView endUpdates];
            
            BOOL stop = NO;
            for (LogLocationData *zObject in _listLogLocations) {
                if ([logSection.toLocation.name isEqualToString:zObject.location] ) {
                    stop = YES;
                    break;
                }
            }
            if ([logSection.fuelAmount doubleValue] == 0) {
                stop = YES;
            }
            if (!stop) {
                LogLocationData * newObject = [[LogLocationData alloc] init];
                newObject.location = logSection.toLocation.name;
                [_listLogLocations addObject:newObject];
            }
            
            for(int index = 0; index < _listLogSections.count; index++) {
                ERA_LogSection *obj = _listLogSections[index];
                if (obj == logSection) {
                    [_listLogSections replaceObjectAtIndex:index withObject:logSection];
                }
                else {
                    if (logSection.fuelAmount.doubleValue >0) {
                        if(  [obj.toLocation.locationID isEqual:logSection.toLocation.locationID]) {
                            obj.fuelOwner = logSection.fuelOwner;
                        }
                    }
                }
            }
            _logData.logSections = _listLogSections;
            [_listLogLocations sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"location" ascending:YES] ]];
            
            [self.tableView reloadData];
            // Show toast message
            [[ToastController sharedInstance] showToastInView:self withTitle:@"Success" withDetailMessage:@"Flight Leg is added successfully" timeout:4];
        }];
    }
}

- (NSArray*)createGroupedLogLocation {
    NSMutableArray* groupedData = [[NSMutableArray alloc] init];
    // create some people
    NSArray* logSections = [_listLogSections mutableCopy];
    
    // create a set of letters - based on the first letter of the surname
    NSMutableSet* groups = [[NSMutableSet alloc] init];
    for(ERA_LogSection * logSection in logSections) {
        [groups addObject:[[logSection  toLocation] name]];
    }
    
    // create the groups
    for(NSString* name in groups) {
        LogLocationData * group = [[LogLocationData alloc] init];
        group.location = name;
        [groupedData addObject:group];
    }
    
    // sort the groups
    NSArray *sortedGroupedData;
    sortedGroupedData = [groupedData sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [(LogLocationData*)a  location];
        NSString *second = [(LogLocationData*)b location];
        return [first compare:second];
    }];
    return sortedGroupedData;
}

- (void)editFlightLog:(NSIndexPath *)indexPath {
    if(indexPath.row !=0 && indexPath.row != (_listLogSections.count+1)) {
        FlightLogTableViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FlightLogTableViewController"];
        
        controller.viewType = FlightLegViewTypeEdit;
        controller.orderID = indexPath.row;
        controller.model = _logData.eraModel;
        controller.logSectionEdit = [_listLogSections objectAtIndex:indexPath.row-1];
        controller.logSectionId = ((ERA_LogSection*)[_listLogSections objectAtIndex:indexPath.row-1]).logSectionID;
        controller.eraSicEmployee = _logData.eraSicEmployee;
        controller.flightLogNumber = _logData.logNumber;
        
        if(indexPath.row==1) {
            controller.previousOnTime = [[[Singleton sharedTimeFormatter] dateFromString:@"00:00"] removeDateAndSecond];
            if(_listLogSections.count==1) {
                controller.nextOffTime = [[[Singleton sharedTimeFormatter] dateFromString:@"23:59"] removeDateAndSecond];
            }
            else {
                ERA_LogSection *nextLogLeg = _listLogSections[indexPath.row];
                controller.nextOffTime = nextLogLeg.off;
            }
        }       // first leg
        else if(indexPath.row==_listLogSections.count) {
            if(_listLogSections.count==1) {
                controller.previousOnTime = [[[Singleton sharedTimeFormatter] dateFromString:@"00:00"] removeDateAndSecond];
            }
            else {
                ERA_LogSection *previousLogLeg = _listLogSections[indexPath.row-2];
                controller.previousOnTime = previousLogLeg.on;
            }
            controller.nextOffTime = [[[Singleton sharedTimeFormatter] dateFromString:@"23:59"] removeDateAndSecond];
        }       // last leg
        else {
            ERA_LogSection *nextLogLeg = _listLogSections[indexPath.row];
            controller.nextOffTime = nextLogLeg.off;
            ERA_LogSection *previousLogLeg = _listLogSections[indexPath.row-2];
            controller.previousOnTime = previousLogLeg.on;
        }
        
        controller.listLogSections = _listLogSections;
        ERA_Location *from = _logData.eraBase;
        
        if (indexPath.row == 1) {
            from = [(ERA_LogSection *) [_listLogSections objectAtIndex:(indexPath.row - 1)] fromLocation];
        }
        
        if(indexPath.row >=2) {
            from = [(ERA_LogSection *) [_listLogSections objectAtIndex:(indexPath.row-2)] toLocation];
        }
        
        if(indexPath.row<_listLogSections.count) {
            controller.nextToLocation = [_listLogSections[indexPath.row] toLocation];
        }
        else {
            controller.nextToLocation = nil;
        }
        
        controller.fromLocation = from;
        controller.maxGrossWeight = _logData.maxGrossWeight;
        controller.operationWeight = _logData.operationalWeight;
        [self.navigationController pushViewController:controller animated:YES];
        [controller setSaveAddEdit:^(ERA_LogSection *logSection, FlightLogTableViewController *vc) {
            [vc.navigationController popViewControllerAnimated:YES];
            
            for (ERA_LogSection *lSection in _listLogSections) {
                lSection.slotPurpose = logSection.slotPurpose;
            }
            [_listLogSections replaceObjectAtIndex:(indexPath.row-1) withObject:logSection];
            
            // Update From of the next Flight Leg
            if(_listLogSections.count>indexPath.row) {
                ERA_LogSection *nextObj = _listLogSections[indexPath.row];
                nextObj.fromLocation = logSection.toLocation;
            }
            
            for(int index = 0; index < _listLogSections.count; index++) {
                ERA_LogSection *obj = _listLogSections[index];
                if (logSection.fuelAmount.doubleValue >0) {
                    if([obj.toLocation.locationID isEqual:logSection.toLocation.locationID]) {
                        obj.fuelOwner = logSection.fuelOwner;
                    }
                }
            }
            
            //Recount A/C Start
            int times = 0;
            for (ERA_LogSection *section in _listLogSections) {
                if (section.aCStarted.boolValue) {
                    times+=1;
                }
            }
            _logData.timesStarted = [NSNumber numberWithInt:times];
            
            if (vc.toLocationHasChange) {
                BOOL stop = NO;
                for (ERA_LogSection *zObject in _listLogSections) {
                    if ([zObject.toLocation.name isEqualToString:vc.toLocationHasChange]) {
                        stop = YES; // TO Location still exist
                        break;
                    }
                }
                
                if (!stop) { // If no exits, find and remove
                    NSInteger removeIndex = -1;
                    for (LogLocationData *zObject in _listLogLocations) {
                        if ([zObject.location isEqualToString:vc.toLocationHasChange]) {
                            removeIndex = [_listLogLocations indexOfObject:zObject];
                        }
                    }
                    
                    if (removeIndex != -1) {
                        [_listLogLocations removeObjectAtIndex:removeIndex];
                    }
                }
                
                // Check new To Location exist in _listLogLocations
                BOOL stopFind = NO;
                for (LogLocationData *zObject in _listLogLocations) {
                    if ([zObject.location isEqualToString:logSection.toLocation.name]) {
                        stopFind = YES; // new To Location Has exist
                        break;
                    }
                }
                
                if ([logSection.fuelAmount doubleValue] == 0) {
                    stopFind = YES;
                }
                
                if (!stopFind) {
                    LogLocationData *zObject = [[LogLocationData alloc] init];
                    zObject.location = logSection.toLocation.name;
                    [_listLogLocations addObject:zObject];
                }
                [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            }
            else{
                //If Fuel amount has changed
                
                if (_listLogLocations.count > 0) { // _listLocation count is 0 so we add new one
                    
                    // Delete all old locations
                    [_listLogLocations removeAllObjects];
                    
                    // Add all location have amount larger than 0
                    
                    for (ERA_LogSection *logsct in _listLogSections) {
                        
                        BOOL stopFind = NO;
                        for (LogLocationData *zObject in _listLogLocations) {
                            if ([zObject.location isEqualToString:logsct.toLocation.name]) {
                                stopFind = YES; //To Location Has exist
                                break;
                            }
                        }
                        
                        
                        if ([logsct.fuelAmount doubleValue] > 0 && !stopFind) {
                            LogLocationData * newObject = [[LogLocationData alloc] init];
                            newObject.location = logsct.toLocation.name;
                            [_listLogLocations addObject:newObject];
                        }
                    }
                    
                }else{
                    if ([logSection.fuelAmount doubleValue] > 0) {
                        LogLocationData * newObject = [[LogLocationData alloc] init];
                        newObject.location = logSection.toLocation.name;
                        [_listLogLocations addObject:newObject];
                    }
                }
                
                for (LogLocationData *locationData in _listLogLocations) {
                    for (NSDictionary *dict in _listAmountOfFuelOwner) {
                        if ([[dict objectForKey:@"location"] isEqualToString:locationData.location]) {
                            locationData.amount = [NSString stringWithFormat:@"%@",[dict objectForKey:@"amount"]];
                            break;
                        }
                    }
                }
            }
            
        }];
    }
}

- (void)reloadData {
    [self.tableView reloadData];
}

#pragma mark - Mail delegate methods
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if(result == MFMailComposeResultSent) {
        [[ToastController sharedInstance] showToastInView:self withTitle:@"Notice" withDetailMessage:@"The email is sent successfully." timeout:3];
    }
    if(error){
        [[ToastController sharedInstance] showToastInView:self withTitle:@"Notice" withDetailMessage:@"The email is not sent." timeout:3];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableView methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return NSLocalizedString(@"Add_Log_Header_Section_0", @"Daily Flight Log");
            break;
            
        case 1:
            return NSLocalizedString(@"Add_Log_Header_Section_1", @"Aircraft");
            break;
            
        case 2:
            return NSLocalizedString(@"Add_Log_Header_Section_2", @"Flight Log");
            break;
            
        case 3:
            return NSLocalizedString(@"Add_Log_Header_Section_3", @"Fuel Expenses or Usage");
            break;
            
        default:
            return NSLocalizedString(@"Add_Log_Header_Section_4", @"Pilot");
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(section==2){
        return 55;
    }
    else {
        return 20;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if(section==2) {
        
        UIView *footerView = [UIView new];
        footerView.backgroundColor = [UIColor clearColor];
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (_isLandscape) {
            addButton.frame = CGRectMake(975, 10, 35, 35);
        }
        else{
            addButton.frame = CGRectMake(725, 10, 35, 35);
        }
        [addButton setImage:[UIImage imageNamed:@"bt_plus"] forState:UIControlStateNormal];
        [addButton setImage:[UIImage imageNamed:@"bt_plus_selected"] forState:UIControlStateHighlighted];
        if (_logData.isNotFlight) {
            addButton.enabled = !_logData.isNotFlight.boolValue;
        }
        [footerView addSubview:addButton];
        switch (section) {
            case 2:
                [addButton addTarget:self action:@selector(addFightLogSectionTap:) forControlEvents:UIControlEventTouchUpInside];
                break;
        }
        UILabel *lbGuideEdit = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 200, 21)];
        lbGuideEdit.textColor = [UIColor lightGrayColor];
        lbGuideEdit.text = NSLocalizedString(@"Add_Log_Flight_Log_Guide_Edit", @"");
        lbGuideEdit.font = [UIFont systemFontOfSize:13.0];
        
        UILabel *lbGuideDelete = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 200, 21)];
        lbGuideDelete.textColor = [UIColor lightGrayColor];
        lbGuideDelete.text = NSLocalizedString(@"Add_Log_Flight_Log_Guide_Delete", @"");
        lbGuideDelete.font = [UIFont systemFontOfSize:13.0];
        
        [footerView addSubview:lbGuideEdit];
        [footerView addSubview:lbGuideDelete];
        
        return footerView;
        
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isLandscape) {
        switch (section) {
            case 0:
                return 2;
                break;
                
            case 1:
                return 5;
                break;
                
            case 2:
                return (2 + _listLogSections.count);
                break;
                
            case 3:
                return (1 + _listLogLocations.count);
                break;
                
            default:
                return  3;
                break;
        }
    }
    else{
        switch (section) {
            case 0:
                return 3;
                break;
                
            case 1:
                return 8;
                break;
                
            case 2:
                return (2 + _listLogSections.count);
                break;
                
            case 3:
                return (1 + _listLogLocations.count);
                break;
                
            default:
                return 3;
                break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if((indexPath.section==2&&indexPath.row==0) || (indexPath.section==3&&indexPath.row==0) || (indexPath.section==4&&indexPath.row==0)){
        return 25;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isLandscape) {
        switch (indexPath.section) {
            case 0:{
                AddLogCell *cell = (AddLogCell*)[tableView dequeueReusableCellWithIdentifier:@"AddLogCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell setValue:_logData
                       canEdit:_canEdit
                 withIndexPath:indexPath
             completionHandler:^(BOOL booleanValue, NSInteger intValue, id objectValue){
                 if (!booleanValue) {
                     [tableView reloadData];
                 }
                 else {
                     AddLogCell *aCell = (AddLogCell *)objectValue;
                     CGRect aRect = CGRectMake(aCell.bounds.origin.x, aCell.bounds.origin.y, aCell.bounds.size.width/3, aCell.bounds.size.height);
                     if (intValue == 1) {
                         if (indexPath.row ==0) {
                             [self showSelectionViewDateFromCGrect:aRect inTableViewCell:aCell withTextField:aCell.value1TextField];
                         }
                         else {
                             [self showSelectionViewFromCGrect:aRect atIndexpath:indexPath withTextField:aCell.value1TextField andIndex:1];
                         }
                     }
                     else if (intValue ==2) {
                         aRect.origin.x = aRect.size.width;
                         [self showSelectionViewFromCGrect:aRect atIndexpath:indexPath withTextField:aCell.value2TextField andIndex:2];
                     }
                     else if (intValue ==3) {
                         aRect.origin.x = 2*aRect.size.width;
                         [self showSelectionViewFromCGrect:aRect atIndexpath:indexPath withTextField:aCell.value3TextField andIndex:3];
                     }
                 }
             }];
                return cell;
            }
                break;
                
            case 1:{
                AddLogCell *cell = (AddLogCell*)[tableView dequeueReusableCellWithIdentifier:@"AddLogCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell setValue:_logData canEdit:_canEdit withIndexPath:indexPath completionHandler:^(BOOL booleanValue, NSInteger intValue, id objectValue){
                    if (!booleanValue) {
                        [tableView reloadData];
                    }
                    else{
                        AddLogCell *aCell = (AddLogCell *)objectValue;
                        CGRect aRect = CGRectMake(aCell.bounds.origin.x, aCell.bounds.origin.y, aCell.bounds.size.width/3, aCell.bounds.size.height);
                        if (intValue == 1) {
                            [self showSelectionViewFromCGrect:aRect atIndexpath:indexPath withTextField:aCell.value1TextField andIndex:1];
                        }
                        else if (intValue ==2) {
                            aRect.origin.x = aRect.size.width;
                            [self showSelectionViewFromCGrect:aRect atIndexpath:indexPath withTextField:aCell.value2TextField andIndex:2];
                        }
                        else if (intValue ==3) {
                            aRect.origin.x = 2*aRect.size.width;
                            [self showSelectionViewFromCGrect:aRect atIndexpath:indexPath withTextField:aCell.value3TextField andIndex:3];
                        }
                    }
                }];
                return cell;
            }
                break;
                
            case 2:{
                FlightLogCell *cell = (FlightLogCell*)[tableView dequeueReusableCellWithIdentifier:@"FlightLogCell"];
                if (indexPath.row >=2) {
                    ERA_Location *base = [[_listLogSections objectAtIndex:indexPath.row-2] toLocation];
                    cell.baseName = base.name;
                }
                [cell setValue:_listLogSections canEdit:_canEdit withIndexPath:indexPath];
                cell.delegate = self;
                if(indexPath.row!=0&&indexPath.row!=(_listLogSections.count+1)) {
                    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                    [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:58.0f];
                }
                else {
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    [cell setRightUtilityButtons:nil];
                }
                return cell;
            }
                break;
                
            case 3:{
                FuelCell *cell = (FuelCell*)[tableView dequeueReusableCellWithIdentifier:@"FuelCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                if (indexPath.row ==0) {
                    [cell setLogLocation:nil
                             logSections:_listLogSections
                                 canEdit:_canEdit
                           withIndexPath:indexPath
                       completionHandler:^(BOOL booleanValue, NSInteger intValue, id objectValue){
                       }];
                }
                else {
                    [cell setLogLocation:[_listLogLocations objectAtIndex:indexPath.row-1]
                             logSections:_listLogSections
                                 canEdit:_canEdit
                           withIndexPath:indexPath
                       completionHandler:^(BOOL booleanValue, NSInteger intValue, id objectValue){
                           LogLocationData *locationData = ((LogLocationData*)[_listLogLocations objectAtIndex:indexPath.row-1]);
                           if (_listAmountOfFuelOwner.count == 0) {
                               [_listAmountOfFuelOwner addObject:@{@"location": locationData.location, @"amount":locationData.amount}];
                           }else{
                               BOOL isFind = NO;
                               for (NSDictionary *locationObj in _listAmountOfFuelOwner) {
                                   if ([[locationObj objectForKey:@"location"] isEqualToString:locationData.location]) {
                                       [_listAmountOfFuelOwner replaceObjectAtIndex:[_listAmountOfFuelOwner indexOfObject:locationObj] withObject:@{@"location": locationData.location, @"amount":locationData.amount}];
                                       isFind = YES;
                                       break;
                                   }
                               }
                               if (!isFind) {
                                   [_listAmountOfFuelOwner addObject:@{@"location": locationData.location, @"amount":locationData.amount}];
                               }
                           }
                           
                       }];
                }
                return cell;
            }
                break;
                
            default:{
                PilotCell *cell = (PilotCell*)[tableView dequeueReusableCellWithIdentifier:@"PilotCell"];
                cell.crewCount = _logData.crewCount;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                if (indexPath.row ==1) {
                    [cell setPilot:_logData.eraPicEmployee
                     copilotWeight:@0
                       logSections:_listLogSections
                         isCoPilot:NO
                     withIndexPath:indexPath
                 completionHandler:^(BOOL booleanValue, NSInteger intValue, id objectValue){
                 }];
                }
                else if (indexPath.row ==2) {
                    [cell setPilot:_logData.eraSicEmployee
                     copilotWeight:_logData.coPilotWeight
                       logSections:_listLogSections
                         isCoPilot:YES
                     withIndexPath:indexPath
                 completionHandler:^(BOOL booleanValue, NSInteger intValue, id objectValue){
                 }];
                }
                else {
                    [cell setPilot:nil
                     copilotWeight:@0
                       logSections:nil
                         isCoPilot:YES
                     withIndexPath:indexPath
                 completionHandler:^(BOOL booleanValue, NSInteger intValue, id objectValue){
                 }];
                }
                return cell;
            }
                break;
        }
    }
    else {
        switch (indexPath.section) {
            case 0: {
                AddLogCell_Portrait *cell = (AddLogCell_Portrait*)[tableView dequeueReusableCellWithIdentifier:@"AddLogCell_Portrait"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell setValue:_logData
                       canEdit:_canEdit
                 withIndexPath:indexPath
             completionHandler:^(BOOL booleanValue, NSInteger intValue, id objectValue){
                 if (!booleanValue) {
                     [tableView reloadData];
                 }
                 else{
                     AddLogCell_Portrait *aCell = (AddLogCell_Portrait *)objectValue;
                     CGRect aRect = CGRectMake(aCell.bounds.origin.x, aCell.bounds.origin.y, aCell.bounds.size.width/2, aCell.bounds.size.height);
                     if (intValue == 1) {
                         if (indexPath.row ==0) {
                             [self showSelectionViewDateFromCGrect:aRect inTableViewCell:aCell withTextField:aCell.value1TextField];
                         }
                         else {
                             [self showSelectionViewFromCGrect:aRect atIndexpath:indexPath withTextField:aCell.value1TextField andIndex:1];
                         }
                     }
                     else if (intValue ==2) {
                         aRect.origin.x = aRect.size.width;
                         [self showSelectionViewFromCGrect:aRect atIndexpath:indexPath withTextField:aCell.value2TextField andIndex:2];
                     }
                 }
             }];
                return cell;
            }
                break;
                
            case 1:{
                AddLogCell_Portrait *cell = (AddLogCell_Portrait*)[tableView dequeueReusableCellWithIdentifier:@"AddLogCell_Portrait"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell setValue:_logData
                       canEdit:_canEdit
                 withIndexPath:indexPath
             completionHandler:^(BOOL booleanValue, NSInteger intValue, id objectValue){
                 if (!booleanValue) {
                     [tableView reloadData];
                 }
                 else {
                     AddLogCell_Portrait *aCell = (AddLogCell_Portrait *)objectValue;
                     CGRect aRect = CGRectMake(aCell.bounds.origin.x, aCell.bounds.origin.y, aCell.bounds.size.width/2, aCell.bounds.size.height);
                     if (intValue == 1) {
                         [self showSelectionViewFromCGrect:aRect atIndexpath:indexPath withTextField:aCell.value1TextField andIndex:1];
                     }
                     else if (intValue ==2) {
                         aRect.origin.x = aRect.size.width;
                         [self showSelectionViewFromCGrect:aRect atIndexpath:indexPath withTextField:aCell.value2TextField andIndex:2];
                     }
                 }
             }];
                return cell;
            }
                break;
                
            case 2: {
                FlightLogCell_Portrait *cell = (FlightLogCell_Portrait*)[tableView dequeueReusableCellWithIdentifier:@"FlightLogCell_Portrait"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                if (indexPath.row >=2) {
                    ERA_Location *base = [[_listLogSections objectAtIndex:indexPath.row-2] toLocation];
                    cell.baseName = base.name;
                }
                
                [cell setValue:_listLogSections canEdit:_canEdit withIndexPath:indexPath];
                
                cell.delegate = self;
                
                if(indexPath.row!=0&&indexPath.row!=(_listLogSections.count+1)) {
                    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                    [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:58.0f];
                    
                }
                else {
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    [cell setRightUtilityButtons:nil];
                }
                return cell;
            }
                
                break;
            case 3:{
                FuelCell_Portrait *cell = (FuelCell_Portrait*)[tableView dequeueReusableCellWithIdentifier:@"FuelCell_Portrait"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                if (indexPath.row ==0) {
                    [cell setLogLocation:nil
                             logSections:_listLogSections
                                 canEdit:_canEdit
                           withIndexPath:indexPath
                       completionHandler:^(BOOL booleanValue, NSInteger intValue, id objectValue){
                       }];
                }
                else {
                    [cell setLogLocation:[_listLogLocations objectAtIndex:indexPath.row-1]
                             logSections:_listLogSections
                                 canEdit:_canEdit
                           withIndexPath:indexPath
                       completionHandler:^(BOOL booleanValue, NSInteger intValue, id objectValue){
                           
                           LogLocationData *locationData = ((LogLocationData*)[_listLogLocations objectAtIndex:indexPath.row-1]);
                           if (_listAmountOfFuelOwner.count == 0) {
                               [_listAmountOfFuelOwner addObject:@{@"location": locationData.location, @"amount":locationData.amount}];
                           }else{
                               BOOL isFind = NO;
                               for (NSDictionary *locationObj in _listAmountOfFuelOwner) {
                                   if ([[locationObj objectForKey:@"location"] isEqualToString:locationData.location]) {
                                       [_listAmountOfFuelOwner replaceObjectAtIndex:[_listAmountOfFuelOwner indexOfObject:locationObj] withObject:@{@"location": locationData.location, @"amount":locationData.amount}];
                                       isFind = YES;
                                       break;
                                   }
                               }
                               if (!isFind) {
                                   [_listAmountOfFuelOwner addObject:@{@"location": locationData.location, @"amount":locationData.amount}];
                               }
                           }
                       }];
                }
                return cell;
            }
                break;
                
            case 4:{
                PilotCell_Portrait *cell = (PilotCell_Portrait*)[tableView dequeueReusableCellWithIdentifier:@"PilotCell_Portrait"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.crewCount = _logData.crewCount;
                if (indexPath.row ==1) {
                    [cell setPilot:_logData.eraPicEmployee
                     copilotWeight:@0
                       logSections:_listLogSections
                         isCoPilot:NO
                     withIndexPath:indexPath
                 completionHandler:^(BOOL booleanValue, NSInteger intValue, id objectValue){
                 }];
                }
                else if (indexPath.row ==2) {
                    [cell setPilot:_logData.eraSicEmployee
                     copilotWeight:_logData.coPilotWeight
                       logSections:_listLogSections
                         isCoPilot:YES
                     withIndexPath:indexPath
                 completionHandler:^(BOOL booleanValue, NSInteger intValue, id objectValue){
                 }];
                }
                else {
                    [cell setPilot:nil
                     copilotWeight:@0
                       logSections:nil
                         isCoPilot:YES
                     withIndexPath:indexPath
                 completionHandler:^(BOOL booleanValue, NSInteger intValue, id objectValue){
                 }];
                }
                return cell;
            }
                break;
                
            default:
                break;
        }
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!(indexPath.section ==2 && (indexPath.row !=0 && indexPath.row != _listLogSections.count+1))) {
        return NO;
    }
    else {
        return YES;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if(cell.isEditing) {
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section==2 && indexPath.row>0 && indexPath.row<(_listLogSections.count+1)) {
        [self editFlightLog:indexPath];
    }
    if (!tableView.isEditing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)updateListLocationAfterDeleteFlightLeg {
    for(LogLocationData *locationData in _listLogLocations) {
        BOOL isExited = NO;
        for (ERA_LogSection *logSection in _listLogSections) {
            if([locationData.location isEqualToString:logSection.toLocation.name]) {
                isExited = YES;
                break;
            }
        }
        if(!isExited) {
            [_listLogLocations removeObject:locationData];
            break;
        }
    }
    
    int times = 0;
    for (ERA_LogSection *section in _listLogSections) {
        if (section.aCStarted.boolValue) {
            times+=1;
        }
    }
    _logData.timesStarted = [NSNumber numberWithInt:times];
}
- (void)reOrderWithEachLogSectionInList{
    NSInteger order = 1;
    for (ERA_LogSection *logsection in _listLogSections) {
        logsection.orderID = [NSNumber numberWithInteger:order];
        order++;
    }
}
#pragma mark - Textfield methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if(IS_IOS_8) {
        if([[touch.view superview] isKindOfClass:[UITableViewCell class]]) {
            UITableViewCell *cell = (UITableViewCell*)[touch.view superview];
            NSIndexPath *index = [self.tableView indexPathForCell:cell];
            if(index.section==2 && index.row>0 && index.row<(_listLogSections.count+1))
                return NO;
        }
    }
    else {
        if([[[touch.view superview] superview] isKindOfClass:[UITableViewCell class]]) {
            UITableViewCell *cell = (UITableViewCell*)[[touch.view superview] superview];
            NSIndexPath *index = [self.tableView indexPathForCell:cell];
            if(index.section==2 && index.row>0 && index.row<(_listLogSections.count+1))
                return NO;
        }
    }
    return YES;
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture {
    [self resignAllTextfields];
}

- (void)resignAllTextfields {
    [self.view endEditing:YES];
    [self.tableView reloadData];
}

#pragma mark - UIPopoverControllerDelegate
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    return NO;
}

- (void)popoverController:(UIPopoverController *)popoverController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView **)view NS_AVAILABLE_IOS(7_0) {
}

#pragma mark - Custom Action Flight Leg Cell Methods -
- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                title:@"Insert"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Delete"];
    
    return rightUtilityButtons;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    switch (state) {
        case 0:
            NSLog(@"utility buttons closed");
            break;
        case 1:
            NSLog(@"left utility buttons open");
            break;
        case 2:
            NSLog(@"right utility buttons open");
            break;
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            
            [self insertAFlightLeg:indexPath];
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        case 1:
        {
            // Delete button was pressed
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            
            ERA_LogSection *objDelete = _listLogSections[indexPath.row-1];
            [UIAlertView showWithTitle:NSLocalizedString(@"Delete_LogSection_Alert_Title", @"Notice")
                               message:NSLocalizedString(@"Delete_LogSection_Alert_Msg", @"Are you sure to delete this record?" )
                     cancelButtonTitle:@"No"
                     otherButtonTitles:@[@"Yes"]
                              tapBlock:^(UIAlertView *alert, NSInteger index){
                                  if (index != alert.cancelButtonIndex) {
                                      
                                      NSArray *arrImages = [[FCFileManager listFilesInDirectoryAtPath:[FCFileManager pathForCachesDirectoryWithPath:[NSString stringWithFormat:@"/log%@",_logData.logNumber]]] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF like %@", [NSString stringWithFormat:@"*%@*",objDelete.imageFolderName]]];
                                      for (NSString *str in arrImages) {
                                          [FCFileManager removeItemAtPath:str];
                                      }
                                      
                                      if(indexPath.row==_listLogSections.count) {
                                          [objDelete deleteEntity];
                                          [_listLogSections removeObjectAtIndex:(indexPath.row-1)];
                                          _logData.logSections = _listLogSections;
                                          [self reOrderWithEachLogSectionInList];
                                          [self updateListLocationAfterDeleteFlightLeg];
                                          [self.tableView reloadData];
                                      } // last flight leg
                                      else if(indexPath.row==1) {
                                          ERA_LogSection *nextObj = _listLogSections[indexPath.row];
                                          if([_logData.eraBase.locationID integerValue]==[nextObj.toLocation.locationID integerValue]) {
                                              [UIAlertView showWithTitle:NSLocalizedString(@"Delete_LogSection_Alert_Title", @"Notice")
                                                                 message:[NSString stringWithFormat:@"Please update Location To of %@ flight leg first.",[@2 getOrderString]]
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil
                                                                tapBlock:nil];
                                          }
                                          else {
                                              [objDelete deleteEntity];
                                              [_listLogSections removeObjectAtIndex:(indexPath.row-1)];
                                              
                                              if ([_listLogSections count]>0) {
                                                  ((ERA_LogSection*)[_listLogSections objectAtIndex:0]).fromLocation = _logData.eraBase;
                                              }
                                              [self reOrderWithEachLogSectionInList];
                                              _logData.logSections = _listLogSections;
                                              [self updateListLocationAfterDeleteFlightLeg];
                                              [self.tableView reloadData];
                                          }
                                      }                 // first flight leg
                                      else {
                                          ERA_LogSection *preObj = _listLogSections[indexPath.row-2];
                                          ERA_LogSection *nextObj = _listLogSections[indexPath.row];
                                          if([preObj.toLocation.locationID integerValue]==[nextObj.toLocation.locationID integerValue]) {
                                              [UIAlertView showWithTitle:NSLocalizedString(@"Delete_LogSection_Alert_Title", @"Notice")
                                                                 message:[NSString stringWithFormat:@"Please update Location To of %@ flight leg first.",[@(indexPath.row+1) getOrderString]]
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil
                                                                tapBlock:nil];
                                          }
                                          else {
                                              [objDelete deleteEntity];
                                              [_listLogSections removeObjectAtIndex:(indexPath.row-1)];
                                              if ([_listLogSections count] >=2) {
                                                  nextObj.fromLocation = preObj.toLocation;
                                              }
                                              [self reOrderWithEachLogSectionInList];
                                              _logData.logSections = _listLogSections;
                                              [self updateListLocationAfterDeleteFlightLeg];
                                              [self.tableView reloadData];
                                          }
                                      }
                                  }
                                  else {
                                      [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                  }
                              }];
            
            break;
        }
        default:
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    
    switch (state) {
        case 1:
            // set to NO to disable all left utility buttons appearing
            return NO;
            break;
        case 2:
            // set to NO to disable all right utility buttons appearing
            return YES;
            break;
        default:
            break;
    }
    
    return YES;
}

@end
