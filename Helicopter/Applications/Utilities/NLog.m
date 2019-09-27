//
//  Log.m
//  Helicopter
//
//  Created by Nguyen Chi Dung on 11/18/13.
//
//

#import "NLog.h"

@implementation NLog

@end

void debug(NSString *format,...) {
#ifdef DEBUG
    va_list args;
    va_start(args, format);
    NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
    const char *utf8 = [str UTF8String];
    printf("Helicopter: \t%s\n", utf8);
    va_end(args);
#endif
}
