//
//  Constants.h
//  Helicopter
//
//  Created by Nguyen Chi Dung on 12/23/13.
//  Copyright (c) 2013 Nguyen Chi Dung. All rights reserved.
//

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define AppColor UIColorFromRGB(0xC2192B)

// check device orientation
#define dDeviceOrientation [[UIDevice currentDevice] orientation]
#define isPortrait  UIDeviceOrientationIsPortrait(dDeviceOrientation)
#define isLandscape UIDeviceOrientationIsLandscape(dDeviceOrientation)
#define isFaceUp    dDeviceOrientation == UIDeviceOrientationFaceUp   ? YES : NO
#define isFaceDown  dDeviceOrientation == UIDeviceOrientationFaceDown ? YES : NO
#define IS_IOS_8 ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)

static int const  MAX_INTEGER  = 999999999;
static int const  MAX_INTEGER_HOBB  = 99999999;
static NSString * const expression                  = @"^([0-9]+)?(\\.([0-9]{1,2})?)?$";
static NSString * const expressionHobb              = @"^([0-9]+)?(\\.([0-9]{1})?)?$";
static NSString * const expressionInt               = @"^([0-9]+)?$";
static NSString * const expressionAlphabetAndNumber = @"^[a-zA-Z0-9 ]*$";
