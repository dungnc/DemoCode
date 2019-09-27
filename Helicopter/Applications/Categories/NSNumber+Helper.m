//
//  NSNumber+Helper.m
//  TrialNotebook
//
//  Created by Nguyen Chi Dung on 4/28/14.
//
//

#import "NSNumber+Helper.h"

@implementation NSNumber (Helper)

- (NSString*)getNumberString {
    if(self) {
        double resultValue = [self doubleValue];
        NSString *stringResult = [NSString stringWithFormat:@"%f",[self doubleValue]];
        if((int)resultValue==resultValue) {
            stringResult = [NSString stringWithFormat:@"%d",(int)resultValue];
        }
        else {
            while ([stringResult characterAtIndex:([stringResult length]-1)]=='0') {
                stringResult = [stringResult substringToIndex:([stringResult length]-1)];
            }
            if([stringResult characterAtIndex:([stringResult length]-1)]=='.')
                stringResult = [stringResult substringToIndex:([stringResult length]-1)];
        }
        if([stringResult doubleValue]<0.0000000000001 || [stringResult doubleValue]>999999999999999)
            stringResult = [NSString stringWithFormat:@"%g",resultValue];
        
        return stringResult;
    }
    return @"";
}

- (NSString*)getOrderString; {
    if(self) {
        NSInteger value = [self integerValue];
        switch (value) {
            case 1:
                return @"1st";
                break;
                
            case 2:
                return @"2nd";
                break;
                
            case 3:
                return @"3rd";
                break;
                
            default:
                return [NSString stringWithFormat:@"%dth",(int)value];
                break;
        }
    }
    return @"";
}

@end
