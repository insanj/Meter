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
	#define MRLOG(fmt, ...) NSLog((@"[Meter] %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
	#define MRLOG(fmt, ...) 
#endif

typedef NS_ENUM(NSUInteger, MRSignalDisplayType) {
	MRMeterThemeDisplayType,
    MRMeterRSSIDisplayType,
	MRMeterAppleDisplayType,
};

static NSString * kMeterSignalDisplayPreferencesPath = @"/var/mobile/Library/Preferences/com.insanj.meter.plist";
static NSString * kMeterSignalDisplayPreferencesKey = @"meterSignalDisplay", * kMeterThemePreferencesKey = @"meterTheme";
static NSDictionary * meterPreferences = [NSDictionary dictionaryWithContentsOfFile:kMeterSignalDisplayPreferencesPath];

static NSString * kMeterDirectoryPath = @"/Library/Application Support/Meter/";
static int kMeterLevelCount = 20;

static CFStringRef kMeterReloadPreferencesNotification = CFSTR("com.insanj.meter/Reload");
static NSString * kMeterListenerToggleRSSINotification = @"MRListenerToggleRSSINotification";
static NSString * kMeterStatusBarRefreshNotification = @"MRStatusBarRefreshNotification";
static NSString * kMeterRememberDisplayTypeNotification = @"MRRememberDisplayTypeNotification";

static NSTimeInterval kMeterLastRSSIToggleTimeInterval = 0.0;
static UIColor * meterTintColor = [UIColor colorWithRed:81.0/255.0 green:178.0/255.0 blue:183.0/255.0 alpha:1.0];

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
- (id)initWithImage:(UIImage *)arg1 shadowImage:(UIImage *)arg2;

@end

// Status bar item views, of which the signal is a member
@interface UIStatusBarItemView : UIView

- (id)textFont;
- (int)legibilityStyle;
- (void)setVisible:(BOOL)arg1;
- (_UILegibilityImageSet *)imageWithText:(id)arg1;
- (BOOL)updateForNewData:(id)arg1 actions:(int)arg2;
- (CGFloat)setStatusBarData:(id)arg1 actions:(int)arg2;
- (UIStatusBarForegroundStyleAttributes *)foregroundStyle;

// iOS 7+
- (_UILegibilityImageSet *)contentsImage;

// iOS 6
- (UIImage *)contentsImageForStyle:(int)arg1;

@end

// Signal status bar item view, controls all container functionality
@interface UIStatusBarSignalStrengthItemView : UIStatusBarItemView {
    int _signalStrengthRaw;
    int _signalStrengthBars;
    BOOL _enableRSSI;
    BOOL _showRSSI;
}

- (NSString *)_stringForRSSI;
- (_UILegibilityImageSet *)contentsImage;
- (BOOL)updateForNewData:(id)arg1 actions:(int)arg2;
- (void)touchesEnded:(id)arg1 withEvent:(id)arg2;

@end

// Status bar method for "refreshing," noted from bensge's blog post:
// http://www.bensge.com/blog/blog/2014/06/22/uistatusbar-research/
@interface SBStatusBarStateAggregator

+ (SBStatusBarStateAggregator *)sharedInstance;
- (BOOL)_setItem:(int)item enabled:(BOOL)enabled;

@end

// Category on signal item view with %new implementation
@interface UIStatusBarSignalStrengthItemView (Meter)

- (void)meter_toggleRSSI:(NSNotification *)notification;

@end
