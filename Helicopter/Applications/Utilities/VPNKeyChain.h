//
//  VPNKetChain.h
//  Helicopter
//
//  Created by Judge Man on 11/03/15.
//  Copyright (c) 2015 Era Helicopter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPNKeyChain : NSObject {
    NSString * service;
    NSString * group;
}

-(id) initWithService:(NSString *) service_ withGroup:(NSString*)group_;

-(BOOL) insert:(NSString *)key : (NSData *)data;
-(BOOL) update:(NSString*)key :(NSData*) data;
-(BOOL) remove: (NSString*)key;
-(NSData*) find:(NSString*)key;

@end
