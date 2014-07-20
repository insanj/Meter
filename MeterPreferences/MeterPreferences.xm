#import "MeterPreferences.h"

void meterReloadPreferences(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	NSLog(@"[Meter] Reloading preferences from %@", [UIApplication sharedApplication]);
	if (meterPreferences) {
		[meterPreferences release];
	}

	meterPreferences = [[NSDictionary alloc] initWithContentsOfFile:kMeterSignalDisplayPreferencesPath];
}

@implementation MRListItemsController

- (id)specifiers {
	if (!_specifiers) {
		NSURL __block *themePathURL = [NSURL fileURLWithPath:kMeterDirectoryPath];
		NSDirectoryEnumerator *themesEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:themePathURL includingPropertiesForKeys:nil options:(NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsSubdirectoryDescendants) errorHandler:^BOOL(NSURL *url, NSError *error) {
			NSLog(@"[Meter] Encountered error enumerating through theme directory %@: %@", themePathURL, error);
			return YES;
		}];

		NSMutableArray *themesSpecifiers = [[NSMutableArray alloc] init];
		// NSString *lastAssignedThemeName = meterPreferences[kMeterThemePreferencesKey];
		while (themePathURL = [themesEnumerator nextObject]) {
			PSSpecifier *themeSpecifier = [PSSpecifier preferenceSpecifierNamed:[themePathURL path] target:self set:NULL get:NULL detail:nil cell:PSLinkCell edit:nil];
			[themesSpecifiers addObject:themeSpecifier];

			// if ([themePathName isEqualToString:lastAssignedThemeName]) {
			// 	[self selectRowForSpecifier:themeSpecifier];
			// }
		}

		_specifiers = [themesSpecifiers retain];
	}

	return _specifiers;
}


- (void)loadView {
	[super loadView];

	meterReloadPreferences(NULL, nil, NULL, nil, NULL);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), [UIApplication sharedApplication], &meterReloadPreferences, kMeterReloadPreferencesNotification, nil, 0);

	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareTapped:)] autorelease];
}

- (void)viewWillAppear:(BOOL)animated {
	self.view.tintColor = meterTintColor;
	self.navigationController.navigationBar.tintColor = meterTintColor;
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	self.view.tintColor = nil;
	self.navigationController.navigationBar.tintColor = nil;
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
}

@end
