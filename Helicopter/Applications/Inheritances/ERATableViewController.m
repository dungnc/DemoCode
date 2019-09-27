//
//  ERATableViewController.m
//  Helicopter
//
//  Created by Nguyen Chi Dung on 4/18/14.
//  Copyright (c) 2014 Nguyen Chi Dung. All rights reserved.
//

#import "ERATableViewController.h"

@interface ERATableViewController ()

@end

@implementation ERATableViewController

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if(IS_IOS_8) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIInterfaceOrientation orient = [[UIApplication sharedApplication] statusBarOrientation];
    switch (orient) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown: {
            _isLandscape = NO;
        }
            break;
            
        default: {
            _isLandscape = YES;
        }
            break;
    }
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    switch (toInterfaceOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown: {
            _isLandscape = NO;
        }
            break;
            
        default: {
            _isLandscape = YES;
        }
            break;
    }
    [self.tableView reloadData];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
}

@end
