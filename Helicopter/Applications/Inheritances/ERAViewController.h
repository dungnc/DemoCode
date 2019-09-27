//
//  ERAViewController.h
//  Helicopter
//
//  Created by Nguyen Chi Dung on 4/18/14.
//  Copyright (c) 2014 Nguyen Chi Dung. All rights reserved.
//

@class ERATableView;


typedef void (^ERAViewControllerBlock) (BOOL, NSInteger, id);

@interface ERAViewController : UIViewController {
    BOOL _isLandscape;
}

@property (nonatomic, strong) ERAViewControllerBlock completionHandler;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

- (void)hideKeyboard;
- (void)keyboardWillShow:(NSNotification *)note;
- (void)keyboardWillSplit:(NSNotification *)note;
- (void)keyboardWillHide:(NSNotification *)notification;
@end
