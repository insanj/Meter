//
//  Meter.xm
//  Meter
//	Cydia Substrate injections to swap out standard signal images with Meter's, and allow tapping.
//	
//  Created by insanj on 7/12/14.
//  Copyright (c) 2014, Juian Weiss All rights reserved.
//

#import "Meter.h"

/*
static UIImage * meter_tintedImageWithColor(UIImage *image, UIColor *color) {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGRect frame = (CGRect){CGPointZero, image.size};
	
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, frame, image.CGImage);
	
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    [color setFill];
    CGContextFillRect(context, frame);
	
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tintedImage;
}
*/

static BOOL meter_assetsArePresent() {
	int meterAssetDirectoryCount = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:kMeterAssetDirectoryPath error:nil].count;

	MLOG(@"meterAssetDirectoryCount: %i", meterAssetDirectoryCount);
	return meterAssetDirectoryCount == kMeterLevelCount * 2;
}

static UIImage * meter_lightContentsImageForValue(BOOL light, int value) {
	NSString *meterImagePath = [NSString stringWithFormat:@"%@%@-%i@2x.png", kMeterAssetDirectoryPath, light ? @"light" : @"dark", value];
	UIImage *meterContentsImage = [UIImage imageWithContentsOfFile:meterImagePath];

	MLOG(@"meterImagePath: %@, image: %@", meterImagePath, meterContentsImage);
	return meterContentsImage;
}

static CGFloat meter_currentSignalStrength() {
	NSString *currentSIMStatus = CTSIMSupportGetSIMStatus(); 
	CGFloat currentSignalStrength = CTGetSignalStrength();
	CGFloat currentSIMBasedSignalStrength = [currentSIMStatus isEqualToString:@"kCTSIMSupportSIMStatusReady"] ? currentSignalStrength : 0.0;

	MLOG(@"currentSIMStatus: %@, currentSignalStrength: %f, currentSIMBasedSignalStrength: %f", currentSIMStatus, currentSignalStrength, currentSIMBasedSignalStrength);
	return currentSIMBasedSignalStrength;
}

/*
	Using the following rules:
	-105 to -100 = Bad/drop call
	-99 to -90 = Getting bad/signal may break up
	-89 to -80 = OK/shouldn't have problems, but maybe
	-79 to -65 = Good
	Over -65 = Excellent
*/

static int meter_valueFromSignalStrength(CGFloat signalStrength) {
	if (signalStrength < -121.0) {
		return 0;
	}

	else if (signalStrength > -90.0) {
		return kMeterLevelCount - 1;
	}

	CGFloat oldMinimum = -105.0, oldMaximum = -90.0;
	int newMinimum = 0, newMaximum = kMeterLevelCount - 1;
		
	int valueFromSignalStrength = ceilf(newMinimum + ((signalStrength - oldMinimum) * ((newMaximum - newMinimum)/(oldMaximum - oldMinimum))));

	MLOG(@"signalStrength: %f, valueFromSignalStrength: %i", signalStrength, valueFromSignalStrength);
	return valueFromSignalStrength;

}

%hook UIStatusBarSignalStrengthItemView

- (_UILegibilityImageSet *)contentsImage {
	if (meter_assetsArePresent()) {
		CGFloat w, a;	// Color detection lifted from Circlet (https://github.com/insanj/Circlet)
		[[[self foregroundStyle] textColorForStyle:[self legibilityStyle]] getWhite:&w alpha:&a];
		
		UIImage *meterContentsImage = meter_lightContentsImageForValue(w >= 0.5, meter_valueFromSignalStrength(meter_currentSignalStrength()));
		_UILegibilityImageSet *meterLegibilityImageSet = [%c(_UILegibilityImageSet) imageFromImage:meterContentsImage withShadowImage:meterContentsImage];

		MLOG(@"meterContentsImage: %@, meterLegibilityImageSet: %@", meterContentsImage, meterLegibilityImageSet);
		return meterLegibilityImageSet;
	}

	return %orig();
}

%end
