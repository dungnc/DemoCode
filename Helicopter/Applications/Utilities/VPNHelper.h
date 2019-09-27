//
//  VPNHelper.h
//  Helicopter
//
//  Created by Judge Man on 11/03/15.
//  Copyright (c) 2015 Era Helicopter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPNHelper : NSObject

+ (VPNHelper*)sharedHelper;
+ (void)setUserInstalledVPNProfile:(BOOL)isInstalled;
+ (BOOL)checkUserInstalledVPNProfile;
+ (void)installVPNProfileWithComplete:(void (^)(NSError *error))completionHandler;
- (void)enableVPNConnectionWithComplete:(void (^)(NSError *error))completionHandler;
+ (void)disableVPNConnection;
+ (BOOL)vpnIsEnable;

@end
