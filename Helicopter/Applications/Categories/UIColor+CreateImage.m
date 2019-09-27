//
//  UIColor+CreateImage.m
//  Helicopter
//
//  Created by Nguyen Chi Dung on 12/23/13.
//  Copyright (c) 2013 Nguyen Chi Dung. All rights reserved.
//

#import "UIColor+CreateImage.h"

@implementation UIColor (CreateImage)

- (UIImage *)imageWithSize:(CGSize)size {
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [self CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
