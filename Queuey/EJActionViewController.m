//
//  EJActionViewController.m
//  Queuey
//
//  Created by Jaden Geller on 1/25/14.
//  Copyright (c) 2014 EJ Dev. All rights reserved.
//

#import "EJActionViewController.h"

#if TARGET_OS_EMBEDDED
#import <libactivator/libactivator.h>
#endif

// Reusable Cell Identifier
NSString * const kActionAdderCellIdentifier = @"actionAdderCell";

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
    
#if TARGET_OS_EMBEDDED
    self.events = [[[LAActivator sharedInstance] availableListenerNames] sortedArrayUsingSelector:@selector(compare:)];
#else
    self.events = @[@"fake1",@"fake2",@"fake3"];
#endif
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
    [self.delegate actionViewControllerWillDismissWithAction:[self.events objectAtIndex:indexPath.row]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.events.count;
};

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kActionAdderCellIdentifier];
    
#if TARGET_OS_EMBEDDED
    cell.textLabel.text = [[LAActivator sharedInstance]localizedTitleForListenerName:[self.events objectAtIndex:indexPath.row]];
    cell.imageView.image = [[LAActivator sharedInstance] smallIconForListenerName:(NSString *)[self.events objectAtIndex:indexPath.row]];
#else
    cell.textLabel.text = [[self.events objectAtIndex:indexPath.row]uppercaseString];
#endif
    
    return cell;
}

@end
