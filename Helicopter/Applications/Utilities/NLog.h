//
//  Log.h
//  Helicopter
//
//  Created by Nguyen Chi Dung on 11/18/13.
//
//

#import <Foundation/Foundation.h>

//#define NSLog(...) debug(__VA_ARGS__);

#ifdef DEBUG
#define NSLog(format, ...) \
NSLog(@"<%s:%d> %s : " format, \
strrchr("/" __FILE__, '/') + 1, __LINE__, __PRETTY_FUNCTION__, ## __VA_ARGS__)
#else
#define NSLog(format, ...)
#endif


@interface NLog : NSObject

@end
void debug(NSString *format,...);
