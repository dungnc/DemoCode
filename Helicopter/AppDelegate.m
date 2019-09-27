//
//  AppDelegate.m
//  Helicopter
//
//  Created by Nguyen Chi Dung on 12/23/13.
//  Copyright (c) 2013 Nguyen Chi Dung. All rights reserved.
//

#import "AppDelegate.h"
#import "ImportDummyData.h"
#import <Crashlytics/Crashlytics.h>
#import "NSString+ERA.h"
#import "WSHelper.h"
#import "ERA_LocationType.h"
#import "ERA_Location.h"
#import "ERA_AC.h"
#import "ERA_Model.h"
#import "ERA_Customer.h"
#import "HUDController.h"
#import "LoginViewController.h"
#import "VPNHelper.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //[Crashlytics startWithAPIKey:@"e515149a3acfa8adc47006e7cbe0c1d939d7e5ef"];
    [Crashlytics startWithAPIKey:@"privateKey"];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UITableView appearance] setSeparatorInset:UIEdgeInsetsZero];
    [[UINavigationBar appearance] setTintColor:AppColor];
    //[ImportDummyData importData];
    //NSLog(@"%@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory  inDomains:NSUserDomainMask] lastObject]);
    //Import data
    //[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(getData) userInfo:nil repeats:NO];
    
    [[HUDController sharedInstance] showHUDInView:self.window.rootViewController withDetailMessage:nil];
    [self performSelector:@selector(prepareLocation) withObject:nil afterDelay:0.1];
    UINavigationController *nav = (UINavigationController*)self.window.rootViewController;
    nav.navigationBar.userInteractionEnabled = NO;
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    [VPNHelper installVPNProfileWithComplete:^(NSError *error) {
//        [[VPNHelper sharedHelper] enableVPNConnectionWithComplete:^(NSError *error2) {
//            
//        }];
    }];
#endif
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 80000
    if (![VPNHelper checkUserInstalledVPNProfile]) {
        [VPNHelper installVPNProfileWithComplete:nil];
    }
#endif
    
}

-(BOOL) application: (UIApplication * ) application openURL: (NSURL * ) url sourceApplication: (NSString * ) sourceApplication annotation: (id) annotation {
    if ([url.scheme isEqualToString: @"helicopter"]) {
        [VPNHelper setUserInstalledVPNProfile:YES];
    }
    return NO;
}


- (void)prepareLocation {
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.razeware.imagegrabber.bgqueue", NULL);
    dispatch_async(backgroundQueue, ^(void) {
        NSLog(@"begin");
        NSMutableArray *locationNames = [[NSMutableArray alloc] init];
        NSMutableArray *baseNames = [[NSMutableArray alloc] init];
        for (ERA_Location *value in [ERA_Location findAllSortedBy:@"name" ascending:YES]) {
            [locationNames addObject:value.name];
            if (value.isBase.boolValue) {
                [baseNames addObject:value.name];
            }
        }
        
        [[UINavigationBar appearance] setTintColor:AppColor];
        [[Singleton sharedManager] setLocationNames:locationNames];
        [[Singleton sharedManager] setBaseNames:baseNames];
        NSLog(@"finished");
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [[HUDController sharedInstance] removeHUD];
            UINavigationController *nav = (UINavigationController*)self.window.rootViewController;
            nav.navigationBar.userInteractionEnabled = YES;
            LoginViewController *loginVC = (LoginViewController*)nav.viewControllers[0];
            [loginVC didFinishPrepareData];
        });
    });
}

- (void)getData {
    NSArray *locations = [ERA_Location findAll];
    NSLog(@"locations count = %d",(int)locations.count);
    if (locations.count == 0) {
        [self getLocations];
    }
}

- (void)getLocations {
    NSLog(@"Start...");
    NSArray *arrLocationTypeNames = @[@"Fuel Station",@"Airport"];
    for (int i=0; i< arrLocationTypeNames.count; i++) {
        ERA_LocationType *obj = [ERA_LocationType createEntity];
        obj.locationTypeID = [NSNumber numberWithInteger:(i+1)];
        obj.name = arrLocationTypeNames[i];
    }
    
    NSArray *arrLocationTypes = [ERA_LocationType findAll];
    
    [[WSHelper sharedManager] getDataForKey:WSKey_Location params:[NSDictionary dictionaryWithObjectsAndKeys:@"0",@"offset",@"40000",@"limit", nil] completionHandler:^(BOOL success, NSInteger key, id objValue) {
        if (success) {
            
            for (ERA_Location *value in (NSArray *)objValue) {
                value.locationType = arrLocationTypes[value.locationID.integerValue%2];
            }
            NSLog(@"Finish...");
            [self performSelectorOnMainThread:@selector(getModels) withObject:nil waitUntilDone:YES];
            
        }
        else{
            NSLog(@"Non success");
        }
    }];
}

- (void)getModels {
    [[WSHelper sharedManager] getDataForKey:WSKey_Model completionHandler:^(BOOL success, NSInteger key, id objValue) {
        if (success){
            NSLog(@"Finish...");
            [self performSelectorOnMainThread:@selector(getEmployees) withObject:nil waitUntilDone:YES];
        }
        else{
            NSLog(@"Non success");
        }
    }];
}

- (void)getACsByModel:(ERA_Model *)model {
    NSLog(@"get AC");
    WSHelper *ws = [[WSHelper alloc] init];
    ws.model = model;
    [ws getDataForKey:WSKey_AC params:[NSDictionary dictionaryWithObjectsAndKeys:[model.modelID stringValue],@"model_id", nil] completionHandler:^(BOOL success, NSInteger key, id objValue) {
        if (success){
            NSLog(@"Finish...Model = %@",model.modelID.stringValue);
        }
        else{
            NSLog(@"Non success");
        }
    }];
}

- (void)getEmployees {
    NSLog(@"Start...");
    [[WSHelper sharedManager] getDataForKey:WSKey_Employee completionHandler:^(BOOL success, NSInteger key, id objValue) {
        if (success){
            NSLog(@"Finish...");
            [self performSelectorOnMainThread:@selector(getCustomer) withObject:nil waitUntilDone:YES];
        }
        else{
            NSLog(@"Non success");
        }
    }];
}

- (void)getCustomer {
    NSLog(@"Start...");
    [[WSHelper sharedManager] getDataForKey:WSKey_Customer completionHandler:^(BOOL success, NSInteger key, id objValue) {
        if (success){
            /*
             for (ERA_Customer *value in (NSArray *)objValue) {
             [self getContratsAndJobnamesByCustomer:value];
             }
             */
            
            NSLog(@"Finish...");
            [self performSelectorOnMainThread:@selector(getFuelOwnners) withObject:nil waitUntilDone:YES];
        }
        else{
            NSLog(@"Non success");
        }
    }];
}

- (void)getFuelOwnners {
    [[WSHelper sharedManager] getDataForKey:WSKey_FuelOwner completionHandler:^(BOOL successfully, NSInteger key, id object) {
        if(successfully) {
            NSLog(@"Finish...");
            [self performSelectorOnMainThread:@selector(getSplotPurposes) withObject:nil waitUntilDone:YES];
        }
        else {
            NSLog(@"Non success");
        }
    }];
}

- (void)getSplotPurposes {
    NSLog(@"Start...");
    [[WSHelper sharedManager] getDataForKey:WSKey_SplotPurpose completionHandler:^(BOOL success, NSInteger key, id objValue) {
        if (success){
            NSLog(@"Finish...");
            [self performSelectorOnMainThread:@selector(saveContext) withObject:nil waitUntilDone:YES];
        }
        else{
            NSLog(@"Non success");
        }
    }];
}

- (void)getLocationTypes {
    NSLog(@"Start...");
    [[WSHelper sharedManager] getDataForKey:WSKey_LocationType completionHandler:^(BOOL success, NSInteger key, id objValue) {
        if (success){
            NSLog(@"Finish...");
        }
        else{
            NSLog(@"Non success");
        }
    }];
}

- (void)getContratsAndJobnamesByCustomer:(ERA_Customer *)customer {
    // NSLog(@"Start...");
    WSHelper *ws = [[WSHelper alloc] init];
    ws.customer = customer;
    [ws getDataForKey:WSKey_ContractChater params:[NSDictionary dictionaryWithObjectsAndKeys:[customer.customerID stringValue],@"customer_id", nil] completionHandler:^(BOOL success, NSInteger key, id objValue) {
        if (success){
            NSLog(@"Finish...Customer = %@",customer.customerID.stringValue);
        }
        else{
            NSLog(@"Non success %@",customer.customerID.stringValue);
        }
    }];
}

- (void)saveContext {
    NSLog(@"saveContext");
    [[CDHelper shareManager] saveContext];
    
    NSArray *models = [ERA_Model findAll];
    for (ERA_Model *value in models) {
        [self getACsByModel:value];
    }
    NSArray *customers = [ERA_Customer findAll];
    for (ERA_Customer *value in customers) {
        [self getContratsAndJobnamesByCustomer:value];
    }
}

@end
