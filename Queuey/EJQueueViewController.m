//
//  EJQueueViewController.m
//  Queuey
//
//  Created by Jaden Geller on 1/25/14.
//  Copyright (c) 2014 EJ Dev. All rights reserved.
//

#import "EJQueueViewController.h"

// NSDictionary Keys
NSString * const kQueueNameKey = @"name";
NSString * const kQueueActionsKey = @"queue";
NSString * const kQueueUUIDKey = @"identifier";

@interface EJQueueViewController ()

@end

@implementation EJQueueViewController

@synthesize queueDictionary = _queueDictionary;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.doneButton.target = self;
    self.doneButton.action = @selector(donePress);
    
    self.cancelButton.target = self;
    self.cancelButton.action = @selector(cancelPress);
}

-(NSMutableDictionary*)queueDictionary{
    if (!_queueDictionary) {
        _queueDictionary = [NSMutableDictionary dictionary];
        [_queueDictionary setObject:@"New Queue" forKey:kQueueNameKey];
        [_queueDictionary setObject:[NSMutableArray array] forKey:kQueueActionsKey];
        [_queueDictionary setObject:[[NSUUID UUID] UUIDString] forKey:kQueueUUIDKey];
    }
    return _queueDictionary;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)donePress{
    [self.delegate queueViewControllerWillDismissWithQueue:self.queueDictionary];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)cancelPress{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)setQueueDictionary:(NSMutableDictionary *)queueDictionary{
    _queueDictionary = queueDictionary.mutableCopy;
}

@end
