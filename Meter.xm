//
//  Meter.xm
//  Meter
//	Cydia Substrate injections to swap out standard signal images with Meter's, and allow tapping.
//	
//  Created by insanj on 7/12/14.
//  Copyright (c) 2014, Juian Weiss All rights reserved.
//

#import "Meter.h"

static BOOL meter_assetsArePresent() {
	int meterAssetDirectoryCount = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:kMeterAssetDirectoryPath error:nil].count;
	return meterAssetDirectoryCount == kMeterLevelCount * 2;
}

static UIImage * meter_lightContentsImageForValue(BOOL light, int value) {
	NSString *meterImagePath = [NSString stringWithFormat:@"%@%@-%i@2x.png", kMeterAssetDirectoryPath, light ? @"light" : @"dark", value];
	return [UIImage imageWithContentsOfFile:meterImagePath];
}

static int meter_valueFromRSSIString(NSString *rssiString) {
	int rssiValue = [rssiString intValue];
	switch (rssiValue) {
		default:
			return rssiValue >= -70 ? 19 : 0;
		case -71:
		case -72:
			return 18;
		case -73:
		case -74:
			return 17;
		case -75:
		case -76:
			return 16;
		case -77:
		case -78:
		case -79:
			return 15;
		case -80:
		case -81:
		case -82:
			return 14;
		case -83:
		case -84:
		case -85:
			return 13;
		case -86:
		case -87:
		case -88:
			return 12;
		case -89:
		case -90:
			return 11;
		case -91:
		case -92:
			return 10;
		case -93:
		case -94:
			return 9;
		case -95:
		case -96:
			return 8;
		case -97:
		case -98:
			return 7;
		case -99:
		case -100:
			return 6;
		case -101:
		case -102:
			return 5;
		case -103:
		case -104:
		case -105:
			return 4;
		case -106:
		case -107:
		case -108:
		case -109:
			return 3;
		case -110:
		case -111:
		case -112:
		case -113:
			return 2;
		case -114:
		case -115:
		case -116:
		case -117:
		case -118:
		case -119:
		case -120:
			return 1;
	}
}

%hook UIStatusBarSignalStrengthItemView

- (id)initWithItem:(id)arg1 data:(id)arg2 actions:(int)arg3 style:(id)arg4 {
	UIStatusBarSignalStrengthItemView *itemView = %orig();
	[[NSDistributedNotificationCenter defaultCenter] addObserver:itemView selector:@selector(meter_toggleRSSI:) name:@"MRListenerToggleRSSINotification" object:nil];
	return itemView;
}

%new - (void)meter_toggleRSSI:(NSNotification *)notification {
	NSTimeInterval currentTimeInterval = [NSDate timeIntervalSinceReferenceDate];
	NSTimeInterval timeIntervalSinceLastToggle = currentTimeInterval - kMeterLastRSSIToggleTimeInterval;
	kMeterLastRSSIToggleTimeInterval = currentTimeInterval;

	if (timeIntervalSinceLastToggle < 1.5) {
		return;
	}

	NSNumber *savedMeterDisplayType = objc_getAssociatedObject([UIApplication sharedApplication], &kMeterSignalDisplayTypeKey);
	MRSignalDisplayType previousMeterDisplayType = savedMeterDisplayType ? [savedMeterDisplayType integerValue] : MRMeterThemeDisplayType;
	MRSignalDisplayType nextMeterDisplayType = previousMeterDisplayType + 1;
	if (nextMeterDisplayType > MRMeterDefaultDisplayType) {
		nextMeterDisplayType = MRMeterThemeDisplayType;
	}

	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:kMeterStatusBarRefreshNotification object:nil userInfo:@{ @"nextMeterDisplayType" : @(nextMeterDisplayType) }];
}

- (_UILegibilityImageSet *)contentsImage {
	NSNumber *savedMeterDisplayType = objc_getAssociatedObject([UIApplication sharedApplication], &kMeterSignalDisplayTypeKey);
	MRSignalDisplayType currentMeterDisplayType = savedMeterDisplayType ? [savedMeterDisplayType integerValue] : MRMeterThemeDisplayType;
	
	if (currentMeterDisplayType == MRMeterThemeDisplayType && meter_assetsArePresent()) {
		CGFloat w, a;	// Color detection lifted from Circlet (https://github.com/insanj/Circlet)
		[[[self foregroundStyle] textColorForStyle:[self legibilityStyle]] getWhite:&w alpha:&a];
		
		UIImage *meterContentsImage = meter_lightContentsImageForValue(w >= 0.5, meter_valueFromRSSIString([self _stringForRSSI]));
		_UILegibilityImageSet *meterLegibilityImageSet = [%c(_UILegibilityImageSet) imageFromImage:meterContentsImage withShadowImage:meterContentsImage];
		return meterLegibilityImageSet;
	}

	else if (currentMeterDisplayType == MRMeterRSSIDisplayType) {
		return [self imageWithText:[self _stringForRSSI]];
	}

	else {
		return %orig();
	}
}

- (void)dealloc {
	%orig();
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
}

%end

%ctor {
	// When a new app launches, wire the current display type, so they can "remember" the appearance
	[[NSDistributedNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
		NSLog(@"-%@: heard launch, sending state: %@", [UIApplication sharedApplication], objc_getAssociatedObject([UIApplication sharedApplication], &kMeterSignalDisplayTypeKey));
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:kMeterRememberDisplayTypeNotification object:nil userInfo: @{ @"nextMeterDisplayType" : objc_getAssociatedObject([UIApplication sharedApplication], &kMeterSignalDisplayTypeKey) }];
	}];

	// Listener for the above wire exchange-- should be received by launching processes, who can now
	// retain the display type of Meter 
	[[NSDistributedNotificationCenter defaultCenter] addObserverForName:kMeterRememberDisplayTypeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
		NSNumber *meterDisplayType = notification.userInfo[@"nextMeterDisplayType"];
		NSLog(@"-%@: heard state wire, setting state: %@", [UIApplication sharedApplication], meterDisplayType);
		objc_setAssociatedObject([UIApplication sharedApplication], &kMeterSignalDisplayTypeKey, meterDisplayType, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}];

	// Assigns the display type associated obj, regardless of process (all running processes since activating Meter
	// will hold some display type for it), and visually refreshes it using a Circlet-esq technique
	[[NSDistributedNotificationCenter defaultCenter] addObserverForName:kMeterStatusBarRefreshNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
		NSNumber *meterDisplayType = notification.userInfo[@"nextMeterDisplayType"];
		objc_setAssociatedObject([UIApplication sharedApplication], &kMeterSignalDisplayTypeKey, meterDisplayType, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

		UIStatusBar *statusBar = (UIStatusBar *)[[UIApplication sharedApplication] statusBar];
		[statusBar setShowsOnlyCenterItems:YES];
		[statusBar setShowsOnlyCenterItems:NO];
	}];
}
