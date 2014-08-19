//
//  Meter.xm
//  Meter
//	Cydia Substrate injections to swap out standard signal images with Meter's, and allow tapping.
//	
//  Created by insanj on 7/12/14.
//  Copyright (c) 2014, Juian Weiss All rights reserved.
//

#import "Meter.h"

static NSDictionary * meterPreferences = [NSDictionary dictionaryWithContentsOfFile:kMeterSignalDisplayPreferencesPath];

void meterReloadPreferences() {
	NSLog(@"[Meter] Reloading preferences from %@", [UIApplication sharedApplication]);
	if (meterPreferences) {
		[meterPreferences release];
	}

	meterPreferences = [[NSDictionary alloc] initWithContentsOfFile:kMeterSignalDisplayPreferencesPath];
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:kMeterStatusBarRefreshNotification object:nil];
}

// Returns "saved display type," as per the farther saveDisplayType function.
static MRSignalDisplayType meter_savedDisplayType() {
	if (!meterPreferences || !meterPreferences[kMeterSignalDisplayPreferencesKey]) {
		return MRMeterThemeDisplayType;
	}

	NSNumber *savedDisplayType = meterPreferences[kMeterSignalDisplayPreferencesKey];
	return savedDisplayType ? [savedDisplayType integerValue] : MRMeterThemeDisplayType;
}

// Saves the given display type at the constant preferences plist location.
static BOOL meter_saveDisplayType(MRSignalDisplayType type) {
	NSDictionary *meterPreferencesToSave;
	if (meterPreferences && meterPreferences[kMeterThemePreferencesKey]) {
		meterPreferencesToSave = @{ kMeterSignalDisplayPreferencesKey : @(type), kMeterThemePreferencesKey : meterPreferences[kMeterThemePreferencesKey] };
	}

	else {
		meterPreferencesToSave =  @{ kMeterSignalDisplayPreferencesKey : @(type) };
	}

	BOOL meterPreferencesSaved = [meterPreferencesToSave writeToFile:kMeterSignalDisplayPreferencesPath atomically:YES];

	[meterPreferences release];
	meterPreferences = [meterPreferencesToSave retain];

	return meterPreferencesSaved;
}

static NSString * meter_savedAssetPath() {
	if (!meterPreferences || !meterPreferences[kMeterThemePreferencesKey]) {
		return [kMeterDirectoryPath stringByAppendingString:@"Default/"];
	}

	return [NSString stringWithFormat:@"%@%@/", kMeterDirectoryPath, meterPreferences[kMeterThemePreferencesKey]];
}


// Returns if the needed Meter assets are recognized in the proper directory.
static BOOL meter_assetsArePresentAtPath(NSString *path) {
	int meterAssetDirectoryCount = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil].count;
	return meterAssetDirectoryCount == kMeterLevelCount * 2;
}

// Returns the proper image extracted from the assets directory, as per the 
// given light  and numerical value.
static UIImage * meter_lightContentsImageForValueAtPath(BOOL light, int value, NSString *path) {
	NSString *meterImagePath = [NSString stringWithFormat:@"%@%@-%i@2x.png", path, light ? @"light" : @"dark", value];
	return [UIImage imageWithContentsOfFile:meterImagePath];
}

// Returns a fine-grain 1/20 value using Joe's algorithm on the given RSSI string.
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

%hook SBStatusBarStateAggregator

- (id)init {
	SBStatusBarStateAggregator *stateAggregator = %orig();
	[[NSDistributedNotificationCenter defaultCenter] addObserver:stateAggregator selector:@selector(meter_refreshSignal:) name:kMeterStatusBarRefreshNotification object:nil];
	return stateAggregator;
}

%new - (void)meter_refreshSignal:(NSNotification *)notification {
	[self _setItem:3 enabled:NO];

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self _setItem:3 enabled:YES];
	});
}

- (void)dealloc {
	%orig();
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
}

%end

%hook UIStatusBarSignalStrengthItemView

- (BOOL)updateForNewData:(id)arg1 actions:(int)arg2 {
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(meter_toggleRSSI:) name:kMeterListenerToggleRSSINotification object:nil];
	return %orig();
}

%new - (void)meter_toggleRSSI:(NSNotification *)notification {
	NSTimeInterval currentTimeInterval = [NSDate timeIntervalSinceReferenceDate];
	NSTimeInterval timeIntervalSinceLastToggle = currentTimeInterval - kMeterLastRSSIToggleTimeInterval;

	if (timeIntervalSinceLastToggle < 1.0) {
		return;
	}

	kMeterLastRSSIToggleTimeInterval = currentTimeInterval;

	MRSignalDisplayType previousMeterDisplayType = meter_savedDisplayType();
	MRSignalDisplayType nextMeterDisplayType = previousMeterDisplayType + 1;
	if (nextMeterDisplayType > MRMeterAppleDisplayType) {
		nextMeterDisplayType = MRMeterThemeDisplayType;
	}

	BOOL savedDisplayTypeProperly = meter_saveDisplayType(nextMeterDisplayType);
	if (!savedDisplayTypeProperly) {
		NSLog(@"[Meter] Wasn't able to properly save display type (%i) to preferences path.", (int)nextMeterDisplayType);
	}

	else {
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:kMeterStatusBarRefreshNotification object:nil];
	}
}

- (_UILegibilityImageSet *)contentsImage {
	MRSignalDisplayType currentDisplayType = meter_savedDisplayType();
	NSString *savedAssetPath = meter_savedAssetPath();

	if (currentDisplayType == MRMeterThemeDisplayType && meter_assetsArePresentAtPath(savedAssetPath)) {
		CGFloat w, a;	// Color detection lifted from Circlet (https://github.com/insanj/Circlet)
		[[[self foregroundStyle] textColorForStyle:[self legibilityStyle]] getWhite:&w alpha:&a];
		
		UIImage *meterContentsImage = meter_lightContentsImageForValueAtPath(w >= 0.5, meter_valueFromRSSIString([self _stringForRSSI]), savedAssetPath);
		_UILegibilityImageSet *meterLegibilityImageSet = [%c(_UILegibilityImageSet) imageFromImage:meterContentsImage withShadowImage:meterContentsImage];
		return meterLegibilityImageSet;
	}

	else if (currentDisplayType == MRMeterRSSIDisplayType) {
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
	[[NSDistributedNotificationCenter defaultCenter] addObserverForName:kMeterReloadPreferencesNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
		meterReloadPreferences();
	}];
    meterReloadPreferences();
}
