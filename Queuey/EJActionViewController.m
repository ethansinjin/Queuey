//
//  EJActionViewController.m
//  Queuey
//
//  Created by Jaden Geller on 1/25/14.
//  Copyright (c) 2014 EJ Dev. All rights reserved.
//

#import "EJActionViewController.h"
#import <libactivator/libactivator.h>

// Reusable Cell Identifier
NSString * const kActionCellIdentifier = @"actionAdderCell";

@interface EJActionViewController ()

@property (nonatomic) NSArray *events;

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
    
    self.events = [[[LAActivator sharedInstance] availableListenerNames] sortedArrayUsingSelector:@selector(compare:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cancelPress{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.delegate actionViewControllerWillDismissWithAction:[self.tableView cellForRowAtIndexPath:indexPath].textLabel.text];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.events.count;
};

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kActionCellIdentifier];
    cell.textLabel.text = [[LAActivator sharedInstance]localizedTitleForListenerName:[self.events objectAtIndex:indexPath.row]];
    return cell;
}

@end
