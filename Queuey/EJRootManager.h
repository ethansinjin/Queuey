//
//  EJRootManager.h
//  Queuey
//
//  Created by Jaden Geller on 1/25/14.
//  Copyright (c) 2014 EJ Dev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EJRootManager : NSObject

@property (nonatomic) NSMutableDictionary *listeners;
@property (nonatomic) NSMutableArray *queues;

-(void)save;

@end
