//
//  Meter.h
//  Meter
//	Consolidated headers for UIKit / CoreTelephony runtime and Meter constants.
//	
//  Created by insanj on 7/12/14.
//  Copyright (c) 2014, Juian Weiss All rights reserved.
//

#include <CoreFoundation/CoreFoundation.h>
#include <UIKit/UIKit.h>
#include <CoreTelephony/CoreTelephony.h>
#include <objc/runtime.h>
#import "substrate.h"

#ifdef DEBUG
	#define MLOG(fmt, ...) NSLog((@"[Meter] %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
	#define MLOG(fmt, ...) 
#endif

extern "C" NSString * CTSIMSupportGetSIMStatus();
extern "C" int CTGetSignalStrength();

static NSString * kMeterAssetDirectoryPath = @"/Library/Application Support/Meter/Assets/";
static int kMeterLevelCount = 6;

@interface UIStatusBarForegroundStyleAttributes : NSObject

- (int)legibilityStyle;
- (UIColor *)textColorForStyle:(int)arg1;

@end

@interface _UILegibilityImageSet : NSObject

@property(retain) UIImage *image;
@property(retain) UIImage *shadowImage;

+ (id)imageFromImage:(UIImage *)arg1 withShadowImage:(UIImage *)arg2;

- (void)setImage:(UIImage *)arg1;
- (UIImage *)image;
- (id)initWithImage:(UIImage *)arg1 shadowImage:(UIImage *)arg2;
- (void)setShadowImage:(UIImage *)arg1;
- (UIImage *)shadowImage;

@end

@interface UIStatusBarItemView : UIView

- (int)textStyle;
- (id)imageWithText:(id)arg1;
- (CGFloat)maximumOverlap;
- (CGFloat)addContentOverlap:(CGFloat)arg1;
- (CGFloat)resetContentOverlap;
- (CGFloat)extraRightPadding;
- (CGFloat)extraLeftPadding;
- (id)textFont;
- (void)drawText:(id)arg1 forWidth:(CGFloat)arg2 lineBreakMode:(int)arg3 letterSpacing:(CGFloat)arg4 textSize:(CGSize)arg5;
- (CGFloat)setStatusBarData:(id)arg1 actions:(int)arg2;
- (CGFloat)currentRightOverlap;
- (CGFloat)currentLeftOverlap;
- (CGFloat)currentOverlap;
- (void)setCurrentOverlap:(CGFloat)arg1;
- (void)setVisible:(BOOL)arg1 frame:(CGRect)arg2 duration:(double)arg3;
- (CGFloat)shadowPadding;
- (CGFloat)standardPadding;
- (void)setLayerContentsImage:(id)arg1;
- (CGFloat)legibilityStrength;
- (CGFloat)updateContentsAndWidth;
- (void)setAllowsUpdates:(BOOL)arg1;
- (int)legibilityStyle;
- (_UILegibilityImageSet *)contentsImage;

// iOS 6
- (UIImage *)contentsImageForStyle:(int)arg1;

- (BOOL)updateForNewData:(id)arg1 actions:(int)arg2;
- (UIStatusBarForegroundStyleAttributes *)foregroundStyle;
- (void)setVisible:(BOOL)arg1;

@end

@interface UIStatusBarSignalStrengthItemView : UIStatusBarItemView {
    int _signalStrengthRaw;
    int _signalStrengthBars;
    BOOL _enableRSSI;
    BOOL _showRSSI;
}

- (NSString *)_stringForRSSI;
- (CGFloat)extraRightPadding;
- (_UILegibilityImageSet *)contentsImage;
- (BOOL)updateForNewData:(id)arg1 actions:(int)arg2;
- (void)touchesEnded:(id)arg1 withEvent:(id)arg2;

@end
