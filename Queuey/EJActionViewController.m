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
@property (nonatomic) NSArray *searchResults;

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

#pragma mark UITableView methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.delegate actionViewControllerWillDismissWithAction:[self.events objectAtIndex:indexPath.row]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchResults count];
    } else {
        return self.events.count;
    }
    
};

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kActionAdderCellIdentifier];
    
    //assertion safety for Search View
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kActionAdderCellIdentifier];
    }
    
#if TARGET_OS_EMBEDDED
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [[LAActivator sharedInstance]localizedTitleForListenerName:[self.searchResults objectAtIndex:indexPath.row]];
        cell.imageView.image = [[LAActivator sharedInstance] smallIconForListenerName:[self.searchResults objectAtIndex:indexPath.row]];
    } else {
        cell.textLabel.text = [[LAActivator sharedInstance]localizedTitleForListenerName:[self.events objectAtIndex:indexPath.row]];
        cell.imageView.image = [[LAActivator sharedInstance] smallIconForListenerName:[self.events objectAtIndex:indexPath.row]];
    }
    
#else
    cell.textLabel.text = [[self.events objectAtIndex:indexPath.row]uppercaseString];
#endif
    
    return cell;
}

#pragma mark search methods

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"SELF contains[cd] %@",
                                    searchText];
    
    self.searchResults = [self.events filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}


@end
