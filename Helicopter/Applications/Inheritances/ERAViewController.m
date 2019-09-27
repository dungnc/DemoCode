//
//  ERAViewController.m
//  Helicopter
//
//  Created by Nguyen Chi Dung on 4/18/14.
//  Copyright (c) 2014 Nguyen Chi Dung. All rights reserved.
//

#import "ERAViewController.h"

@implementation ERAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
}

//static NSInteger currentKeyboardState = 0;
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillSplit:) name:@"SplitKeyBoard" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:@"ShowKeyBoard" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:@"HideKeyBoard" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
    
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
    
    if (_tableView) {
        [_tableView reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ShowKeyBoard" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SplitKeyBoard" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HideKeyBoard" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
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
    if (_tableView) {
        [_tableView reloadData];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
}

#pragma mark - Keyboard Show/Hide methods
- (void)keyboardDidChange:(NSNotification *)notification {
    CGRect keyboardEndFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (CGRectIntersectsRect(keyboardEndFrame, screenRect)) {
        if(keyboardEndFrame.size.width<(216+20) || keyboardEndFrame.size.height<(216+20)) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SplitKeyBoard" object:nil];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowKeyBoard" object:nil];
        }
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HideKeyBoard" object:nil];
    }
}

- (void)keyboardWillShow:(NSNotification *)note {
}

- (void)keyboardWillSplit:(NSNotification *)note {
}

- (void)keyboardWillHide:(NSNotification *)notification {
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

@end
