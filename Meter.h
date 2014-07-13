//
//  Meter.h
//  Meter
//	Consolidated headers for UIKit / CoreTelephony runtime and Meter constants.
//	
//  Created by insanj on 7/12/14.
//  Copyright (c) 2014, Juian Weiss All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/NSDistributedNotificationCenter.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "substrate.h"

#ifdef DEBUG
	#define MLOG(fmt, ...) NSLog((@"[Meter] %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
	#define MLOG(fmt, ...) 
#endif

static char * kMeterRSSIStringEnabledKey;
static NSString * kMeterStatusBarRefreshNotification = @"MRStatusBarRefreshNotification";
static NSString * kMeterAssetDirectoryPath = @"/Library/Application Support/Meter/Assets/";
static int kMeterLevelCount = 20;

// Used to detect light / dark content for tinting or image selection
@interface UIStatusBarForegroundStyleAttributes : NSObject

- (int)legibilityStyle;
- (UIColor *)textColorForStyle:(int)arg1;

@end

// Return value of -contentsImage in status bar item views
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

// Status bar item views, of which the signal is a member
@interface UIStatusBarItemView : UIView

- (_UILegibilityImageSet *)imageWithText:(id)arg1;

- (int)textStyle;
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

// Signal status bar item view, controls all container functionality
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

// Status bar method for "refreshing," taken from Circlet
@interface UIStatusBar : UIView

- (void)setShowsOnlyCenterItems:(BOOL)arg1;

@end

// Private UIApplication method to retrieve pointer to status bar
@interface UIApplication (Private)

- (UIStatusBar *)statusBar;

@end

// Category on signal item view with %new implementation
@interface UIStatusBarSignalStrengthItemView (Meter)

- (void)meter_toggleRSSI:(NSNotification *)notification;

@end
