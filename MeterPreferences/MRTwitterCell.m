#import "MRTwitterCell.h"

@implementation MRTwitterCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		user = [specifier.properties[@"user"] copy];

		self.detailTextLabel.text = [@"@" stringByAppendingString:specifier.properties[@"user"]];
		self.detailTextLabel.textColor = [UIColor colorWithWhite:0.56 alpha:1.0];
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
	}

	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	if (!selected) {
		[super setSelected:selected animated:animated];
		return;
	}

	NSURL *twitterClientURL;
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"aphelion:"]]) {
		twitterClientURL = [NSURL URLWithString:[@"aphelion://profile/" stringByAppendingString:user]];
	}

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]]) {
		twitterClientURL = [NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:user]];
	}

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]]) {
		twitterClientURL = [NSURL URLWithString:[@"twitterrific:///profile?screen_name=" stringByAppendingString:user]];
	}

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]]) {
		twitterClientURL = [NSURL URLWithString:[@"tweetings:///user?screen_name=" stringByAppendingString:user]];
	}

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
		twitterClientURL = [NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:user]];
	}

	else {
		twitterClientURL = [NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:user]];
	}

	[[UIApplication sharedApplication] openURL:twitterClientURL];
}

- (void)dealloc {
	[user release];
	[super dealloc];
}

@end
