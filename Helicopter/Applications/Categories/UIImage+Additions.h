//
//  UIImage+Additions.h
//  My Menu
//
//  Created by nvnguyen on 12/25/13.
//  Copyright (c) 2013 My Menu, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Additions)
- (UIImage *)applyLightEffect;
- (UIImage *)applySemiLightEffect;
- (UIImage *)applyExtraLightEffect;
- (UIImage *)applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;
- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;
- (UIImage *)renderAtSize:(const CGSize) size;
- (UIImage *)maskWithImage:(const UIImage *) maskImage;
- (UIImage *)maskWithColor:(UIColor *) color;
- (UIImage *)renderAtSizeCoverAndAvatar:(const CGSize) size;
+ (UIImage *)compressImage:(UIImage *)image;
+ (UIImage *) imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width;
@end
