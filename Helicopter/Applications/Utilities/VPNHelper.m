//
//  VPNHelper.m
//  Helicopter
//
//  Created by Judge Man on 11/03/15.
//  Copyright (c) 2015 Era Helicopter. All rights reserved.
//

#import "VPNHelper.h"
#import <NetworkExtension/NetworkExtension.h>
#import "VPNKeyChain.h"
#import "NSObject+Block.h"
#import "HUDController.h"


typedef void  (^ConnectVPNHandler) (NSError *error);

@interface VPNHelper () {
    ConnectVPNHandler _connectVPNHandler;
}



@end

@implementation VPNHelper

+ (VPNHelper*)sharedHelper {
    static VPNHelper *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[VPNHelper alloc] init];
        
    });
    
    return sharedInstance;
}

+ (void)installVPNProfileWithComplete:(void (^)(NSError *error))completionHandler {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    [[NEVPNManager sharedManager] loadFromPreferencesWithCompletionHandler: ^(NSError *error) {
        if (error) {
            NSLog(@"Load error: %@", error);
            if (completionHandler) {
                completionHandler(error);
            }
        } else {
            if (![NEVPNManager sharedManager].protocol) {
                
                VPNKeyChain * keychain =[[VPNKeyChain alloc] initWithService:@"VPNIPSEC" withGroup:nil];
                
                NSString *key =@"password";
                NSData * value = [@"123456" dataUsingEncoding:NSUTF8StringEncoding];
                
                NSString *key2 =@"psk";
                NSData * value2 = [@"vpn@min" dataUsingEncoding:NSUTF8StringEncoding];
                
                if(![keychain find:@"password"] || ![keychain find:@"psk"]) {
                    if ([keychain insert:key :value]) {
                        NSLog(@"Successfully added data");
                    } else {
                        NSLog(@"Failed to  add data");
                    }
                    
                    if ([keychain insert:key2 :value2]) {
                        NSLog(@"Successfully added data shared key");
                    } else {
                        NSLog(@"Failed to  add data shared key");
                    }
                    
                } else {
                    NSLog(@"No need to  add data");
                }
                
                NEVPNProtocolIPSec *p = [[NEVPNProtocolIPSec alloc] init];
                p.username = @"Nguyen Chi Dung";
                p.serverAddress = @"117.3.70.139";
                p.passwordReference = [keychain find:@"password"];
                p.authenticationMethod = NEVPNIKEAuthenticationMethodSharedSecret;
                p.sharedSecretReference = [keychain find:@"psk"];
                p.localIdentifier = @"vpn5505";
                p.remoteIdentifier = @"117.3.70.139";
                p.useExtendedAuthentication = YES;
                p.disconnectOnSleep = NO;
                
                [[NEVPNManager sharedManager] setProtocol:p];
                [[NEVPNManager sharedManager] setLocalizedDescription:@"VPNMRV"];
                [[NEVPNManager sharedManager] setEnabled:YES];
                
                [[NEVPNManager sharedManager] saveToPreferencesWithCompletionHandler: ^(NSError *error) {
                    NSLog(@"Save VPN to preference complete");
                    if (error) {
                        NSLog(@"Save to preference error: %@", error);
                        if (completionHandler) {
                            completionHandler(error);
                        }
                    } else {
                        if (completionHandler) {
                            completionHandler(nil);
                        }
                    }
                }];
                
            } else {
                if (completionHandler) {
                    completionHandler(nil);
                }
            }
            
        }
    }];

#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 80000
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://installvpnmrh.16mb.com/installVPN.html"]];
#endif

}

- (void)enableVPNConnectionWithComplete:(void (^)(NSError *error))completionHandler {
    if (![NEVPNManager sharedManager].protocol) {
        [[HUDController sharedInstance] removeHUD];
        [VPNHelper installVPNProfileWithComplete:nil];
        return;
    }
    NSError *startError;
    [[NEVPNManager sharedManager].connection startVPNTunnelAndReturnError:&startError];
    if(startError) {
        NSLog(@"Start error: %@", startError.localizedDescription);
        if (completionHandler) {
            NSError *error = [NSError errorWithDomain:@"com.private"
                                                 code:999
                                             userInfo:@{NSLocalizedDescriptionKey:@"Connect to VPN Error."}];
            completionHandler(error);
        }
    } else {
        _connectVPNHandler = completionHandler;
        [self performBlock:^{
            [self connectingWithVPN];
        } afterDelay:0.5];
        
        
    }
}

- (void)connectingWithVPN {
    if ([NEVPNManager sharedManager].connection.status == NEVPNStatusConnected) {
        _connectVPNHandler(nil);
    } else if([NEVPNManager sharedManager].connection.status == NEVPNStatusConnecting) {
        [self performSelector:@selector(connectingWithVPN) withObject:nil afterDelay:0.25];
    } else {
        NSError *error = [NSError errorWithDomain:@"com.private"
                                             code:999
                                         userInfo:@{NSLocalizedDescriptionKey:@"Connect to VPN Error."}];
        _connectVPNHandler(error);
    }
}


+ (void)disableVPNConnection {
    [[NEVPNManager sharedManager].connection stopVPNTunnel];
}

+ (BOOL)vpnIsEnable {
    if ([NEVPNManager sharedManager].connection.status == NEVPNStatusConnected) {
        return YES;
    }
    return NO;
}

+ (void)setUserInstalledVPNProfile:(BOOL)isInstalled {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isInstalled] forKey:@"UserInstalledVPNProfile"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)checkUserInstalledVPNProfile {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInstalledVPNProfile"] boolValue];
}

@end
