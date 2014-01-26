//
//  EJConfigurationNavigationController.m
//  Queuey
//
//  Created by Jaden Geller on 1/26/14.
//  Copyright (c) 2014 EJ Dev. All rights reserved.
//

#import "EJConfigurationNavigationController.h"

#if TARGET_OS_EMBEDDED
#import <libactivator/libactivator.h>
#endif

@interface EJConfigurationNavigationController ()

@end

@implementation EJConfigurationNavigationController

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
    
#if TARGET_OS_EMBEDDED
    LAListenerSettingsViewController *listenerController = [[LAListenerSettingsViewController alloc] init];
    listenerController.listenerName = @"com.ejdev.queuey";
    [self pushViewController:listenerController animated:YES];
#endif

    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
