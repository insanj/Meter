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

static CGFloat meter_averageSignalStrengthForCycles(int cycles) {
	NSString *currentSIMStatus = CTSIMSupportGetSIMStatus(); 
	CGFloat currentSignalStrength = CTGetSignalStrength();
	CGFloat currentSIMBasedSignalStrength = [currentSIMStatus isEqualToString:@"kCTSIMSupportSIMStatusReady"] ? currentSignalStrength : 0.0;

	// Pull up the saved records array from the path
	NSError *recordsArrayError;
	NSData *recordsArrayData = [NSData dataWithContentsOfFile:kMeterRecordsFilePath options:0 error:&recordsArrayError];

	if (recordsArrayError) {
		NSLog(@"[Meter] %@ -> %@", recordsArrayError, kMeterRecordsFilePath);
	}

	NSArray *recordsArray = [NSKeyedUnarchiver unarchiveObjectWithData:recordsArrayData];
	NSMutableArray *runningRecordsArray = recordsArray ? [[NSMutableArray alloc] initWithArray:recordsArray] : [[NSMutableArray alloc] init];

	if (runningRecordsArray.count > kMeterTotalRecordsCount) {
		[runningRecordsArray removeLastObject];
	}

	[runningRecordsArray insertObject:@(currentSIMBasedSignalStrength) atIndex:0];
	CGFloat averagedSignalStrength = 0.0;
	for (NSNumber *strength in runningRecordsArray) {
		averagedSignalStrength += [strength floatValue];
	}

	averagedSignalStrength /= runningRecordsArray.count;

	NSData *runningArrayData = [NSKeyedArchiver archivedDataWithRootObject:runningRecordsArray];
	NSError *runningArrayWriteError;
	BOOL runningArrayWasOfProperFormat = [runningArrayData writeToFile:kMeterRecordsFilePath options:0 error:&runningArrayWriteError];

	if (runningArrayWriteError || !runningArrayWasOfProperFormat) {
		NSLog(@"[Meter] %@ (%@ == %@ -> %@)", runningArrayWriteError, runningRecordsArray, runningArrayData, kMeterRecordsFilePath);
	}

	MLOG(@"cycles: %i, currentSIMStatus: %@, currentSignalStrength: %f, currentSIMBasedSignalStrength: %f, recordsArrayError: %@, recordsArrayData: %@, recordsArray: %@, runningRecordsArray: %@, averagedSignalStrength: %f, runningArrayData: %@, runningArrayWriteError: %@, runningArrayWasOfProperFormat : %@", cycles, currentSIMStatus, currentSignalStrength, currentSIMBasedSignalStrength, recordsArrayError, recordsArrayData, recordsArray, runningRecordsArray, averagedSignalStrength, runningArrayData, runningArrayWriteError, runningArrayWasOfProperFormat ? @"YES" : @"NO");
	[runningRecordsArray release];

	return /*cycles ? meter_averageSignalStrengthForCycles(cycles - 1) :*/ averagedSignalStrength;
}

// Take 10+ measurements http://stackoverflow.com/questions/15427507/how-to-find-out-carrier-signal-strength-programatically
static CGFloat meter_currentSignalStrength() {
	return meter_averageSignalStrengthForCycles(kMeterTotalRecordsCount);
}

/*
	Using the following rules:
	-70dBm and above  =   20/20 bars
	-71dBm   to -72dBm =   19/20 bars
	-73dBm   to -74dBm =   18/20 bars
	-75dBm   to -76dBm =   17/20 bars
	-77dBm   to -79dBm =   16/20 bars
	-80dBm   to -82dBm =   15/20 bars
	-83dBm   to -85dBm =   14/20 bars
	-86dBm   to -88dBm =   13/20 bars
	-89dBm   to -90dBm =   12/20 bars
	-91dBm   to -92dBm =   11/20 bars
	-93dBm   to -94dBm =   10/20 bars
	-95-dBm  to -96dBm =    9/20 bars
	-97dBm   to -98dBm =    8/20 bars
	-99dBm   to -100dBm =  7/20 bars
	-101dBm to -102dBm =   6/20 bars
	-103dBm to -105dBm =   5/20 bars
	-106dBm to -109dBm =   4/20 bars
	-110dBm to -113dBm =   3/20 bars
	-114dBm to -120dBm =   2/20 bars
	-121dbm and below =      1/20 bars
*/

static int meter_valueFromSignalStrength(CGFloat signalStrength) {
	CGFloat signalStrengthMinimum = 10.0, signalStrengthMaximum = 90.0;

	if (signalStrength > signalStrengthMaximum) {
		return 0;
	}

	else if (signalStrength < signalStrengthMinimum) {
		return kMeterLevelCount - 1;
	}
	
	int meterDisplayLevelMinimum = 0, meterDisplayLevelMaximum = kMeterLevelCount - 1;
		
	int valueFromSignalStrength = meterDisplayLevelMaximum - ceilf(meterDisplayLevelMinimum + ((signalStrength - signalStrengthMinimum) * ((meterDisplayLevelMaximum - meterDisplayLevelMinimum)/(signalStrengthMaximum - signalStrengthMinimum))));

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
