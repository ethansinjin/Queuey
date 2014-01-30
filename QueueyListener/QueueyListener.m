//
//  QueueyListener.m
//  QueueyListener
//
//  Created by Ethan Gill on 1/25/14.
//  Copyright (c) 2014 EJ Dev. All rights reserved.
//

// LibActivator by Ryan Petrich
// See https://github.com/rpetrich/libactivator

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <libactivator/libactivator.h>

#define NUMBER_OF_LISTENERS 10

NSString * const kConditionIdentifier = @"com.ejdev.condition.";
NSString * const kGenericIdentifier = @"com.ejdev.Queuey";

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

/*- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
 {
 }
 */

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
    NSString *settingsPath = [NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(), @"com.ejdev.queuey.plist"];
    NSArray *settings = [NSArray arrayWithContentsOfFile:
                         settingsPath];
    NSDictionary *listeners = [settings objectAtIndex:0];
    NSArray *queueList = [settings objectAtIndex:1];
    
    
    NSString *UUIDForAction = [listeners objectForKey:[activator assignedListenerNameForEvent:event]];
    
    NSDictionary * configuredAction;
    for (NSDictionary *temp in queueList) {
        if([[temp valueForKey:@"identifier"] isEqualToString:UUIDForAction] && UUIDForAction){
            configuredAction = temp;
            break;
        }
    }
    
    if(configuredAction ){
        /*
         av = [[UIAlertView alloc] initWithTitle:@"DEBUG: Running Queuey Event" message:[NSString stringWithFormat:@"Event called: %@\n Queue configured for event: %@",[activator assignedListenerNameForEvent:event],[configuredAction valueForKey:@"name"]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [av show];
         [av release];
         */
        
        NSArray *actionArray = [configuredAction objectForKey:@"queue"];
        [self doTasks:actionArray activator:activator event:event];
        
    }else{
        av = [[UIAlertView alloc] initWithTitle:@"No Queue Configured" message:@"You activated a Queuey action, but didn't have a queue set up for it." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[av show];
        [av release];
    }
    
    //regardless, don't do the original action for the event
    
}

-(void)doTasks:(NSArray*)tasks activator:(LAActivator*)activator event:(LAEvent*)event{
    [self doTasksWithSpecification:@[tasks, [NSNumber numberWithInt:0], activator, event]];
}

-(void)doTasksWithTimer:(NSTimer*)timer{
    [self doTasksWithSpecification:timer.userInfo];
}

-(void)doTasksWithSpecification:(NSArray*)specification{
    NSArray *tasks = specification[0];
    int startingPoint = [specification[1] intValue];
    for (int i = startingPoint; i < tasks.count; i++) {
        NSObject *task = tasks[i];
        if ([task isKindOfClass:[NSNumber class]]) {
            // specification 2: activator; specification 3: event
            
            [NSTimer scheduledTimerWithTimeInterval:[(NSNumber*)task floatValue] target:self selector:@selector(doTasksWithTimer:) userInfo:@[tasks, [NSNumber numberWithInt:i+1], specification[2], specification[3]] repeats:NO];
            return;
        }
        else{
            // specification 2: activator; specification 3: event
            [self doTask:task activator:specification[2] event:specification[3]];
        }
    }
    //[tasks release];
    [specification[3] setHandled:YES];//event set handled
}

+(BOOL)responseFromSelector:(SEL)selector{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: [[QueueyOne class] methodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:[QueueyOne class]];
    [invocation invoke];
    
    BOOL returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

-(void)doTask:(NSObject*)task activator:(LAActivator*)activator event:(LAEvent*)event{
    if ([task isKindOfClass:[NSString class]]) {
        [activator sendEvent:event toListenerWithName:(NSString *)task];
    }else if([task isKindOfClass:[NSArray class]]){
        
        NSString *condition = [(NSArray *)task objectAtIndex:0];
        
        NSRange idRange = [condition rangeOfString:kConditionIdentifier];
        if (idRange.location == 0) {
            //do shit because it is a valid condition
            SEL function = NSSelectorFromString([condition substringFromIndex:idRange.length]);
            if ([self respondsToSelector:function]) {
                BOOL response = [QueueyOne responseFromSelector:function];
                // THIS IS THE YES/NO value for the condition
                if(response){
                    for (int i = 1; i<[(NSArray *)task count]; i++) { //start at 1, first action
                        [activator sendEvent:event toListenerWithName:[(NSArray *)task objectAtIndex:i]];
                    }
                }else{
                    NSLog(@"Queuey: Skipping conditionally-restrained actions for condition %@.",condition);
                }
            }
            else{
                NSLog(@"Conditional does not exist, so this is bad.");
            }
        }
        else{
            NSLog(@"Invalid condition identifier.");
        }
    }
    
    
}

/*
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
 
 */
+ (void)load
{
	@autoreleasepool
	{
        for (int i = 1; i <= NUMBER_OF_LISTENERS; i++) {
            [[LAActivator sharedInstance] registerListener:[self new] forName:[NSString stringWithFormat:@"%@%i",kGenericIdentifier,i]];
        }
	}
}

+(BOOL)test{
    return YES;
}

@end
