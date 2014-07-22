#import "MeterPreferences.h"

static NSString * kMeterPreferencesDirectoryPath = @"/Library/Application Support/Meter/";
static NSString * kMeterReloadPreferencesNotification = @"MRReloadPreferencesNotification";

@implementation MRListController

- (id)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"MeterPreferences" target:self] retain];
	}

	return _specifiers;
}

- (void)loadView {
	[super loadView];

	themes = [[NSMutableArray alloc] init];
	NSDirectoryEnumerator *themeEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL fileURLWithPath:kMeterPreferencesDirectoryPath] includingPropertiesForKeys:nil options:(NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsHiddenFiles) errorHandler:^BOOL(NSURL *url, NSError *error) {
		NSLog(@"[Meter] Encountered error enumerating through theme directory %@:", error);
		return YES;
	}];

	NSURL *themeAbsolutePath;
	while (themeAbsolutePath = [themeEnumerator nextObject]) {
		[themes addObject:[themeAbsolutePath lastPathComponent]];
	}

	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareTapped:)] autorelease];
}

- (void)viewWillAppear:(BOOL)animated {
	self.view.tintColor = [UIColor colorWithRed:81.0/255.0 green:178.0/255.0 blue:183.0/255.0 alpha:1.0];
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:81.0/255.0 green:178.0/255.0 blue:183.0/255.0 alpha:1.0];
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	self.view.tintColor = nil;
	self.navigationController.navigationBar.tintColor = nil;
}

- (NSArray *)themeTitles:(id)target {
	return themes;
}

- (NSArray *)themeValues:(id)target {
	return themes;
}

- (void)shareTapped:(UIBarButtonItem *)sender {
	NSString *text = @"An advanced, themable meter that tells the truth about your signal. Free from @insanj and @joe012594.";
	NSURL *url = [NSURL URLWithString:@"http://insanj.github.io/Meter/"];

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
	[themes release];
	[super dealloc];
}

@end

@implementation MRListItemsController

- (void)viewWillAppear:(BOOL)animated {
	self.view.tintColor = [UIColor colorWithRed:81.0/255.0 green:178.0/255.0 blue:183.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:81.0/255.0 green:178.0/255.0 blue:183.0/255.0 alpha:1.0];

    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
	self.view.tintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
}

- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 {
	PSTableCell *cell = [super tableView:arg1 cellForRowAtIndexPath:arg2];
	cell.textLabel.textColor = [UIColor colorWithRed:81.0/255.0 green:178.0/255.0 blue:183.0/255.0 alpha:1.0];
	return cell;
}

- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2 {
	[super tableView:arg1 didSelectRowAtIndexPath:arg2];
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:kMeterReloadPreferencesNotification object:nil];
}

@end
