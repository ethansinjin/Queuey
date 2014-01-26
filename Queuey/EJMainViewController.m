//
//  EJCollectionViewController.m
//  Queuey
//
//  Created by Ethan Gill on 1/24/14.
//  Copyright (c) 2014 EJ Dev. All rights reserved.
//

#import "EJMainViewController.h"
#import "EJQueueViewController.h"
#import "EJRootManager.h"
#import "NSMutableArray+Swap.h"

#define NUMBER_OF_LISTENERS 5

// Reusable Cell Identifier
NSString * const kQueueCellIdentifier = @"queueCell";

// Segue Identifier
NSString * const kEditSegueIdentifier = @"editSegue";
NSString * const kCreateSegueIdentifier = @"createSegue";

@interface EJMainViewController () <EJQueueViewControllerDelegate>

// Data
@property (nonatomic) EJRootManager *root;

// Interface
@property (nonatomic) UIBarButtonItem *addButtonStorage;
@property (nonatomic) UIBarButtonItem *editButtonStorage;

@end

@implementation EJMainViewController

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
    
    self.navBar.leftBarButtonItem.target = self;
    self.navBar.leftBarButtonItem.action = @selector(toggleEditing);
    
    self.addButtonStorage = self.navBar.rightBarButtonItem;
    self.editButtonStorage = self.navBar.leftBarButtonItem;
    
    _root = [[EJRootManager alloc]init];
    
    [self refreshEditButtonVisibility];
	   
}

-(void)toggleEditing{
    [self toggleEditingToState:!self.editing];
}

-(void)toggleEditingToState:(BOOL)editing{
    if (editing) {
        
        self.navBar.rightBarButtonItem = nil;
        
        self.editButtonStorage.title = @"Done";
        self.editButtonStorage.style = UIBarButtonItemStyleDone;
        [self.tableView setEditing:YES animated:YES];
    
    }
    else{
        [self.navBar setRightBarButtonItem:self.addButtonStorage animated:YES];
        
        self.editButtonStorage.title = @"Edit";
        self.editButtonStorage.style = UIBarButtonItemStylePlain;
        [self.tableView setEditing:NO animated:YES];
    }
    self.editing = editing;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.root.queues.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kQueueCellIdentifier];
    NSDictionary *queueForRow = [self.root.queues objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [queueForRow objectForKey:kQueueNameKey];

    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.tableView.editing = NO;
    
    BOOL editSegue = [segue.identifier isEqualToString:kEditSegueIdentifier];
    BOOL createSegue = [segue.identifier isEqualToString:kCreateSegueIdentifier];
    
    if (editSegue || createSegue) {
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            
            EJQueueViewController *controller = (EJQueueViewController*)[segue.destinationViewController topViewController];
            controller.delegate = self;
            
            if (editSegue) {
                controller.queueDictionary = self.root.queues[self.tableView.indexPathForSelectedRow.row];
            }
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.root.queues removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self refreshEditButtonVisibility];
        if (self.root.queues.count < 1) {
            [self toggleEditingToState:NO];
        }
        
        //added (writes the deletion)
        [self.root save];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    [self.root.queues moveObjectAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
    [self.root save];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:kEditSegueIdentifier sender:self];
}

-(void)queueViewControllerWillDismissWithQueue:(NSDictionary *)queue{
    
    // Check if queue exists and replace it
    for (int i = 0; i < self.root.queues.count; i++) {
        
        NSDictionary *aQueue = [self.root.queues objectAtIndex:i];
        if ([aQueue[kQueueUUIDKey] isEqualToString: queue[kQueueUUIDKey]]){
            
            // Same queue, replace it
            [self.root.queues replaceObjectAtIndex:i withObject:queue];
            [self.root save];

            [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]].textLabel.text = queue[kQueueNameKey];
            return;
        }
    }
    
    // Queue doesn't exist; add this new queue
    [self.root.queues addObject:queue];
    [self.root save];
    
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.root.queues.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    
    [self refreshEditButtonVisibility];
}

-(void)refreshEditButtonVisibility{
    if (self.root.queues.count) {
        self.navBar.leftBarButtonItem = self.editButtonStorage;
    }
    else{
        self.navBar.leftBarButtonItem = nil;
    }
}

@end
