//
//  LogViewController.h
//  Helicopter
//
//  Created by Nguyen Chi Dung on 9/26/14.
//  Copyright (c) 2014 Era Helicopter. All rights reserved.
//

#import "ERATableViewController.h"

typedef NS_ENUM(NSInteger, LogViewType) {
    LogViewTypeAdd,
    LogViewTypeEdit
};

@class ERA_Log;

@interface LogViewController : ERATableViewController

@property (nonatomic, assign) LogViewType viewType;
@property (nonatomic, retain) ERA_Log *aLogToEdit;
//@property (nonatomic, assign) NSInteger logId;
//@property (nonatomic, assign) NSInteger itemOfSubmitListOrPendingList;

@end
