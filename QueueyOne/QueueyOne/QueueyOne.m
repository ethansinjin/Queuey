//
//  QueueyOne.m
//  QueueyOne
//
//  Created by Ethan Gill on 1/25/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

// LibActivator by Ryan Petrich
// See https://github.com/rpetrich/libactivator

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <libactivator/libactivator.h>

@interface QueueyOne : NSObject<LAListener, UIAlertViewDelegate> {
@private
	UIAlertView *av;
}
@end

@implementation QueueyOne

- (BOOL)dismiss
{
	if (av)
	{
		[av dismissWithClickedButtonIndex:[av cancelButtonIndex] animated:YES];
		return YES;
	}
	return NO;
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
	if (![self dismiss])
	{
		av = [[UIAlertView alloc] initWithTitle:@"QueueyOne" message:[event name] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[av show];
		[event setHandled:YES];
	}
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event
{
	// Called when event is escalated to higher event
	[self dismiss];
}

- (void)activator:(LAActivator *)activator otherListenerDidHandleEvent:(LAEvent *)event
{
	// Called when other listener receives an event
	[self dismiss];
}

- (void)activator:(LAActivator *)activator receiveDeactivateEvent:(LAEvent *)event
{
	// Called when the home button is pressed.
	// If showing UI, then dismiss it and call setHandled:.
	if ([self dismiss])
		[event setHandled:YES];
}


+ (void)load
{
	@autoreleasepool
	{
		[[LAActivator sharedInstance] registerListener:[self new] forName:@"com.ejdev.QueueyOne"];
        [[LAActivator sharedInstance] registerListener:[self new] forName:@"com.ejdev.QueueyTwo"];
        [[LAActivator sharedInstance] registerListener:[self new] forName:@"com.ejdev.QueueyThree"];
        [[LAActivator sharedInstance] registerListener:[self new] forName:@"com.ejdev.QueueyFour"];
        [[LAActivator sharedInstance] registerListener:[self new] forName:@"com.ejdev.QueueyFive"];
	}
}

@end
