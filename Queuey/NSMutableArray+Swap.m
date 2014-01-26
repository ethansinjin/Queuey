//
//  NSMutableArray+Swap.m
//  Queuey
//
//  Created by Jaden Geller on 1/26/14.
//  Copyright (c) 2014 EJ Dev. All rights reserved.
//

#import "NSMutableArray+Swap.h"

@implementation NSMutableArray (Swap)

-(void)moveObjectAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex{
    NSObject *object = [self objectAtIndex:fromIndex];
    [self removeObjectAtIndex:fromIndex];
    [self insertObject:object atIndex:toIndex];
}

@end
