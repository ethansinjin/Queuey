//
//  EJRootManager.m
//  Queuey
//
//  Created by Jaden Geller on 1/25/14.
//  Copyright (c) 2014 EJ Dev. All rights reserved.
//

#import "EJRootManager.h"

#if TARGET_OS_EMBEDDED
#import <libactivator/libactivator.h>
#endif

#define NUMBER_OF_LISTENERS 10
#define LISTENER_IDENTIFIER_PREFIX @"com.ejdev.Queuey"

// Root Identifiers
NSInteger const kRootListenersIdentifier = 0;
NSInteger const kRootQueuesIdentifier = 1;

@interface EJRootManager ()

@property (nonatomic) NSString *path;
@property (nonatomic, readonly) NSArray *root;

@end

@implementation EJRootManager

-(id)init{
    if (self = [super init]) {
        _path = [NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(), @"com.ejdev.queuey.plist"];
    }
    return self;
}

-(NSArray*)root{
    return [NSArray arrayWithContentsOfFile:self.path];
}

-(NSMutableDictionary*)listeners{
    if (!_listeners) {
        _listeners = [self.root[kRootListenersIdentifier] mutableCopy];
        if (!_listeners) {
            _listeners = [NSMutableDictionary dictionary];
        }
    }
    return _listeners;
}

-(NSMutableArray*)queues{
    if (!_queues) {
        _queues = [self.root[kRootQueuesIdentifier] mutableCopy];
        if (!_queues) {
            _queues = [NSMutableArray array];
        }
    }
    return _queues;
}

-(void)save{
    [@[self.listeners, self.queues] writeToFile:self.path atomically:YES];
}

-(BOOL)identifierHasListener:(NSString*)UUID{
    return ([self listenerKeyFromUUID:UUID] != nil);
}

-(NSInteger)numberOfAvailibleListeners{
    return NUMBER_OF_LISTENERS - self.listeners.count;
}

-(BOOL)listenerKeyInUse:(NSString*)listenerKey{
    return (self.listeners[listenerKey] != nil);
}

-(NSString*)keyOfAvailibleListener{
    for (NSString *key in self.possibleListeners) {
        if (![self listenerKeyInUse:key]) {
            return key;
        }
    }
    return nil;
}

-(NSArray*)possibleListeners{
    NSMutableArray *listenerPossibilities = [NSMutableArray array];
    for (int i = 1; i <= NUMBER_OF_LISTENERS; i++) {
        [listenerPossibilities addObject:[NSString stringWithFormat:@"%@%i",LISTENER_IDENTIFIER_PREFIX,i]];
    }
    return listenerPossibilities.copy;
}

-(BOOL)attachIdentifierToListener:(NSString*)UUID{
    if (![self identifierHasListener:UUID]) {
        if (self.numberOfAvailibleListeners > 0) {
            self.listeners[self.keyOfAvailibleListener] = UUID;
            [self save];
            return YES;
        }
        else{
            return NO; // no listeners availible
        }
    }
    else{
        return YES; // already has listener
    }
}

-(NSString*)listenerKeyFromUUID:(NSString*)UUID{
    for (NSString *key in self.listeners) {
        if ([self.listeners[key] isEqualToString:UUID]) {
            return key;
        }
    }
    return nil;
}

-(void)removeIdentifierFromListener:(NSString*)UUID{
    NSString *key = [self listenerKeyFromUUID:UUID];
    if ([self.listeners objectForKey:key]) {
        [self.listeners removeObjectForKey:key];
    }
    [self unassignAllEventsForListener:key];
}


-(void)unassignAllEventsForListener:(NSString*)listener{
#if TARGET_OS_EMBEDDED
    
    NSArray *events = [[LAActivator sharedInstance] eventsAssignedToListenerWithName:listener];
    for (LAEvent *event in events){
        [[LAActivator sharedInstance] unassignEvent:event];
    }
#endif
    
}

@end
