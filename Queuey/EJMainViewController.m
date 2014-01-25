//
//  EJCollectionViewController.m
//  Queuey
//
//  Created by Ethan Gill on 1/24/14.
//  Copyright (c) 2014 EJ Dev. All rights reserved.
//

#import "EJMainViewController.h"
#import "EJQueueViewController.h"

@interface EJMainViewController () <EJQueueViewControllerDelegate>

@property (nonatomic) NSMutableArray *queueList;
@property (nonatomic) UIBarButtonItem *addButtonStorage;

@end

// Reusable Cell Identifier
NSString * const kQueueCellIdentifier = @"queueCell";

// Segue Identifier
NSString * const kEditSegueIdentifier = @"editSegue";
NSString * const kCreateSegueIdentifier = @"createSegue";

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
    
    self.editButton.target = self;
    self.editButton.action = @selector(toggleEditing);
    
    self.queueList = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Queues" ofType:@"plist"]];
}

-(void)toggleEditing{
    if (self.tableView.editing) {
        [self.navBar setRightBarButtonItem:self.addButtonStorage animated:YES];
        self.addButtonStorage = nil;
        
        self.editButton.title = @"Edit";
        self.editButton.style = UIBarButtonItemStylePlain;
        [self.tableView setEditing:NO animated:YES];
    }
    else{
        self.addButtonStorage = self.navBar.rightBarButtonItem;
        self.navBar.rightBarButtonItem = nil;
        
        self.editButton.title = @"Done";
        self.editButton.style = UIBarButtonItemStyleDone;
        [self.tableView setEditing:YES animated:YES];
    }
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
    return self.queueList.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kQueueCellIdentifier];
    NSDictionary *queueDictionary = [self.queueList objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [queueDictionary objectForKey:kQueueNameKey];

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
                controller.queueDictionary = [self.queueList objectAtIndex:self.tableView.indexPathForSelectedRow.row];
            }
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.queueList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:kEditSegueIdentifier sender:self];
}

-(void)queueViewControllerWillDismissWithQueue:(NSDictionary *)queue{
    for (int i = 0; i < self.queueList.count; i++) {
        
        NSDictionary *aQueue = [self.queueList objectAtIndex:i];
        if ([aQueue[kQueueUUIDKey] isEqualToString: queue[kQueueUUIDKey]]){
            
            // Same queue, replace it
            [self.queueList replaceObjectAtIndex:i withObject:queue];
            return;
        }
    }
    
    // New queue
    [self.queueList addObject:queue];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.queueList.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
}

@end
