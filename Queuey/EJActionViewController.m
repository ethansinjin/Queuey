//
//  EJActionViewController.m
//  Queuey
//
//  Created by Jaden Geller on 1/25/14.
//  Copyright (c) 2014 EJ Dev. All rights reserved.
//

#import "EJActionViewController.h"

@interface EJActionViewController ()

@end

@implementation EJActionViewController

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
    
    self.cancelButton.target = self;
    self.cancelButton.action = @selector(cancelPress);
    
    self.addButton.target = self;
    self.addButton.action = @selector(addPress);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cancelPress{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)addPress{
    [self.delegate actionViewControllerWillDismissWithAction:@"Test"];
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
