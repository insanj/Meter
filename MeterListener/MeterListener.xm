//
//  MeterListener.xm
//  Meter
//	Activator listener for Meter's RSSI swap action.
//	
//  Created by insanj on 7/12/14.
//  Copyright (c) 2014, Juian Weiss All rights reserved.
//

#import "MeterListener.h"

@implementation MeterListener

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"MRListenerToggleRSSINotification" object:nil];
	[event setHandled:YES];
}

+ (void)load {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[[LAActivator sharedInstance] registerListener:[self new] forName:@"com.insanj.MeterListener"];
	[pool release];
}

@end
