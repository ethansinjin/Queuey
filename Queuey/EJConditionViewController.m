//
//  EJActionViewController.m
//  Queuey
//
//  Created by Jaden Geller on 1/25/14.
//  Copyright (c) 2014 EJ Dev. All rights reserved.
//

#import "EJConditionViewController.h"

// Reusable Cell Identifier
NSString * const kConditionAdderCellIdentifier = @"conditionAdderCell";

@interface EJConditionViewController ()

@property (nonatomic) NSDictionary *conditions;
@property (nonatomic) NSArray *searchResults;

@property (nonatomic) NSArray *conditionIdentifiers;

@end

@implementation EJConditionViewController

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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSDictionary*)conditions{
    if (!_conditions) {
        _conditions = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource: @"Conditions" ofType: @"plist"]];
    }
    return _conditions;
}

-(NSArray*)conditionIdentifiers{
    if (!_conditionIdentifiers) {
        _conditionIdentifiers = [self.conditions.allKeys sortedArrayUsingSelector:@selector(compare:)];
    }
    return _conditionIdentifiers;
}

-(void)cancelPress{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UITableViewDelegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.delegate conditionViewControllerWillDismissWithCondition:[self.conditionIdentifiers objectAtIndex:indexPath.row]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchResults count];
        
    } else {
        return self.conditions.count;
        
    }
};

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kConditionAdderCellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kConditionAdderCellIdentifier];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        NSString *key = self.conditionIdentifiers[indexPath.row];
        cell.textLabel.text = self.conditions[key];
    }
    
    return cell;
    
    
    
}

#pragma mark Search Methods

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"SELF contains[cd] %@",
                                    searchText];
    
    self.searchResults = [self.conditionIdentifiers filteredArrayUsingPredicate:resultPredicate];
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
