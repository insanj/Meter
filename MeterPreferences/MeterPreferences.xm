#import "MeterPreferences.h"
#define PREFS_PATH @"/var/mobile/Library/Preferences/com.insanj.meter.plist"

void meterReloadPreferences(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	NSLog(@"[Meter] Reloading preferences from %@", [UIApplication sharedApplication]);
	if (meterPreferences) {
		[meterPreferences release];
	}

	meterPreferences = [[NSDictionary alloc] initWithContentsOfFile:kMeterSignalDisplayPreferencesPath];
}

@implementation MRListController

- (id)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"MeterPreferences" target:self] retain];
	}

	return _specifiers;
}

- (void)loadView {
	[super loadView];

	CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), [UIApplication sharedApplication], kMeterReloadPreferencesNotification, nil);
	meterReloadPreferences(NULL, nil, NULL, nil, NULL);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), [UIApplication sharedApplication], &meterReloadPreferences, kMeterReloadPreferencesNotification, nil, 0);

	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareTapped:)] autorelease];
}

- (void)viewWillAppear:(BOOL)animated {
	self.view.tintColor = self.navigationController.navigationBar.tintColor = meterTintColor;
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	self.view.tintColor = self.navigationController.navigationBar.tintColor = nil;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	NSURL __block *themePathURL = [NSURL fileURLWithPath:PREFS_PATH];
	NSDirectoryEnumerator *themesEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:themePathURL includingPropertiesForKeys:nil options:(NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsSubdirectoryDescendants) errorHandler:^BOOL(NSURL *url, NSError *error) {
		NSLog(@"[Meter] Encountered error enumerating through theme directory %@: %@", themePathURL, error);
		return YES;
	}];

	NSString *lastAssignedThemeName = meterPreferences[kMeterThemePreferencesKey];
	NSString *themePathName, *themeName;
	while (themePathName = [themesEnumerator nextObject]) {
		themeName = [themePathName stringByTrimmingCharactersInSet:[NSCharacterSet URLPathAllowedCharacterSet]];
		PSSpecifier *themeSpecifier = [PSSpecifier preferenceSpecifierNamed:themeName target:self set:NULL get:NULL detail:nil cell:PSLinkCell edit:nil];
		[self addSpecifier:themeSpecifier animated:YES];

		if ([themePathName isEqualToString:lastAssignedThemeName]) {
			[self selectRowForSpecifier:themeSpecifier];
		}
	}
}

- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 {
	PSTableCell *cell = [super tableView:arg1 cellForRowAtIndexPath:arg2];
	cell.textLabel.textColor = meterTintColor;
	return cell;
}

- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2 {
	[super tableView:arg1 didSelectRowAtIndexPath:arg2];

	PSSpecifier *themeSpecifier = [self specifierAtIndex:((NSIndexPath *)arg2).row];
	BOOL themeWrote;
	if (meterPreferences && meterPreferences[kMeterSignalDisplayPreferencesKey]) {
		themeWrote = [@{ kMeterThemePreferencesKey : themeSpecifier.name, kMeterSignalDisplayPreferencesKey : meterPreferences[kMeterSignalDisplayPreferencesKey] } writeToFile:kMeterSignalDisplayPreferencesPath atomically:YES];
	}

	else {
		themeWrote = [@{ kMeterThemePreferencesKey : themeSpecifier.name } writeToFile:kMeterSignalDisplayPreferencesPath atomically:YES];
	}

	NSLog(@"[Meter] User selected new theme %@, wrote to file: %@", themeSpecifier, themeWrote ? @"YES" : @"NO");
}

- (void)shareTapped:(UIBarButtonItem *)sender {
	NSString *text = @"an advanced, themable meter that tells the truth about your signal. free from @insanj and @joe012594.";
	NSURL *url = [NSURL URLWithString:@"http://github.com/insanj/meter"];

	if (%c(UIActivityViewController)) {
		UIActivityViewController *viewController = [[[%c(UIActivityViewController) alloc] initWithActivityItems:[NSArray arrayWithObjects:text, url, nil] applicationActivities:nil] autorelease];
		[self.navigationController presentViewController:viewController animated:YES completion:NULL];
	}

	else if (%c(TWTweetComposeViewController) && [TWTweetComposeViewController canSendTweet]) {
		TWTweetComposeViewController *viewController = [[[TWTweetComposeViewController alloc] init] autorelease];
		viewController.initialText = text;
		[viewController addURL:url];
		[self.navigationController presentViewController:viewController animated:YES completion:NULL];
	}

	else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/intent/tweet?text=%@%%20%@", [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [url.absoluteString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
	}
}

- (void)dealloc {
	[super dealloc];

	CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), [UIApplication sharedApplication], kMeterReloadPreferencesNotification, nil);

	[meterPreferences release];
	[meterTintColor release];
}

@end
