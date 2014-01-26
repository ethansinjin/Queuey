//
//  EJRootManager.m
//  Queuey
//
//  Created by Jaden Geller on 1/25/14.
//  Copyright (c) 2014 EJ Dev. All rights reserved.
//

#import "EJRootManager.h"

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

-(NSMutableArray*)listeners{
    if (!_listeners) {
        _listeners = self.root[kRootListenersIdentifier];
        if (!_listeners) {
            _listeners = [NSMutableArray array];
        }
    }
    return _listeners;
}

-(NSMutableArray*)queues{
    if (!_queues) {
        _queues = self.root[kRootQueuesIdentifier];
        if (!_queues) {
            _queues = [NSMutableArray array];
        }
    }
    return _queues;
}

-(void)save{
    [@[self.listeners, self.queues] writeToFile:self.path atomically:YES];
}

@end
