//
//  MeterListener.h
//  Meter
//	Activator listener for Meter's RSSI swap action.
//	
//  Created by insanj on 7/12/14.
//  Copyright (c) 2014, Juian Weiss All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/NSDistributedNotificationCenter.h>
#import <libactivator/libactivator.h>

static NSString * kMeterListenerToggleRSSINotification = @"MRListenerToggleRSSINotification";

@interface MeterListener : NSObject <LAListener>

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event;
+ (void)load;

@end
