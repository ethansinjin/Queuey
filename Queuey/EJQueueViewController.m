//
//  EJQueueViewController.m
//  Queuey
//
//  Created by Jaden Geller on 1/25/14.
//  Copyright (c) 2014 EJ Dev. All rights reserved.
//

#import "EJQueueViewController.h"
#import "EJActionViewController.h"
#import "EJConditionViewController.h"

#if TARGET_OS_EMBEDDED
#import <libactivator/libactivator.h>
#endif

// NSDictionary Keys
NSString * const kQueueNameKey = @"name";
NSString * const kQueueActionsKey = @"queue";
NSString * const kQueueUUIDKey = @"identifier";

// Reusable Cell Identifier
NSString * const kActionCellIdentifier = @"actionCell";
NSString * const kDelayCellIdentifier = @"delayCell";

// View Tag
NSInteger const kStepperViewTag = 45;

// Segue Identifier
NSString * const kActionSegueIdentifier = @"actionSegue";
NSString * const kConditionSegueIdentifier = @"conditionSegue";

// Conditional Identifiers
NSString * const kConditionalEndIf = @"com.ejdev.queuey.conditionals.replacements.endif";

@interface EJQueueViewController () <EJActionViewControllerDelegate, EJConditionViewControllerDelegate>

@property (nonatomic, readonly) NSMutableArray *queue;
@property (nonatomic) UIBarButtonItem *editButtonStorage;
@property (nonatomic) UIBarButtonItem *saveButtonStorage;

@end

@implementation EJQueueViewController

@synthesize queueDictionary = _queueDictionary;

-(NSMutableArray*)queue{
    return [self.queueDictionary objectForKey:kQueueActionsKey];
}

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
    
    if (_queueDictionary && [self.queueDictionary[kQueueNameKey] length]){
        self.nameField.text = self.queueDictionary[kQueueNameKey];
    }
    
    self.editButtonStorage = self.navBar.leftBarButtonItem;
    self.saveButtonStorage = self.navBar.rightBarButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.navBar.leftBarButtonItem.target = self;
    self.navBar.leftBarButtonItem.action = @selector(toggleEditing);
    
    self.navBar.rightBarButtonItem.target = self;
    self.navBar.rightBarButtonItem.action = @selector(savePress);
    
    //self.cancelButton.target = self;
    //self.cancelButton.action = @selector(cancelPress);
    
    [self setTextFieldPlaceholder];
    
    [self refreshForCountChange];
    
    

    
}

-(void)setTextFieldPlaceholder{
    self.nameField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:self.nameField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:.9 alpha:.5]}];
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

-(void)savePress{
    if (self.queue.count) {
        // Save
        
        if (self.nameField.text.length) [self.queueDictionary setObject:self.nameField.text forKey:kQueueNameKey];
        [self.delegate queueViewControllerWillDismissWithQueue:self.queueDictionary];
    }
    // Else cancel
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

-(void)cancelPress{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)setQueueDictionary:(NSMutableDictionary *)queueDictionary{
    _queueDictionary = queueDictionary.mutableCopy;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.queue removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self refreshForCountChange];

    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    NSObject *obj = [self.queue objectAtIndex:sourceIndexPath.row];
    [self.queue removeObjectAtIndex:sourceIndexPath.row];
    [self.queue insertObject:obj atIndex:destinationIndexPath.row];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.queue.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    
    
    if ([[self.queue objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:kActionCellIdentifier];

#if TARGET_OS_EMBEDDED

        cell.textLabel.text = [[LAActivator sharedInstance] localizedTitleForListenerName:[self.queue objectAtIndex:indexPath.row]];
        cell.imageView.image = [[LAActivator sharedInstance] smallIconForListenerName:[self.queue objectAtIndex:indexPath.row]];
#else
        cell.textLabel.text = [[self.queue objectAtIndex:indexPath.row]capitalizedString];
#endif
    }
    else if([[self.queue objectAtIndex:indexPath.row] isKindOfClass:[NSNumber class]]){
        cell = [tableView dequeueReusableCellWithIdentifier:kDelayCellIdentifier];
        UIStepper *stepper = (UIStepper*)[cell viewWithTag:kStepperViewTag];
        [stepper addTarget:self action:@selector(stepperValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        NSNumber *num = [self.queue objectAtIndex:indexPath.row];
        
        stepper.value = num.intValue;
        [self stepperValueChanged:stepper];
        
        return cell;
    }
    
    return cell;
}

-(void)stepperValueChanged:(UIStepper*)stepper{
    UITableViewCell *cell = (UITableViewCell*)stepper.superview.superview.superview;
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    NSString *units = (stepper.value > 1) ? @"seconds" : @"second";

    cell.textLabel.text = [NSString stringWithFormat:@"Wait %i %@",(int)stepper.value, units];
    if (path) {
        [self.queue replaceObjectAtIndex:path.row withObject:[NSNumber numberWithInt:(int)stepper.value]];
    }
}

-(void)keyboardWillShow:(NSNotification*)notification{
    [self toggleEditingToState:NO];
    [self animateBottomConstraintWithKeyboard:notification.userInfo keyboardWillShow:YES];
}

-(void)keyboardWillHide:(NSNotification*)notification{
    [self animateBottomConstraintWithKeyboard:notification.userInfo keyboardWillShow:NO];
}

-(void)animateBottomConstraintWithKeyboard:(NSDictionary*)keyboardDictionary keyboardWillShow:(BOOL)show{
    CGRect keyboardFrame = [[keyboardDictionary objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGFloat duration = [[keyboardDictionary objectForKey:UIKeyboardAnimationDurationUserInfoKey]floatValue];
    
    UIViewAnimationCurve curve;
    [[keyboardDictionary valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&curve];
    UIViewAnimationOptions curveOption = curve << 16; // converts to animation option
    
    
    [UIView animateWithDuration:duration delay:0 options:curveOption animations:^{
        self.bottomConstraint.constant = show ? keyboardFrame.size.height : 0;
        [self.view layoutIfNeeded];
    } completion:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    self.tableView.editing = NO;
    
    BOOL actionSegue = [segue.identifier isEqualToString:kActionSegueIdentifier];
    BOOL conditionSegue = [segue.identifier isEqualToString:kConditionSegueIdentifier];
    
    if (actionSegue || conditionSegue) {
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            UITableViewController *controller = (UITableViewController*)[segue.destinationViewController topViewController];
            [controller performSelector:@selector(setDelegate:) withObject:self];
        }
    }
}

-(void)actionViewControllerWillDismissWithAction:(NSString*)action{
    [self.queue addObject:action];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.queue.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self refreshForCountChange];
    
    if (self.queue.count < 1) {
        [self toggleEditingToState:NO];
    }

}

-(void)conditionViewControllerWillDismissWithCondition:(NSString*)condition{
    NSLog(@"ADDED CONDITION %@", condition);
}

-(void)refreshForCountChange{
    if (self.queue.count) {
        self.navBar.leftBarButtonItem = self.editButtonStorage;
        self.navBar.rightBarButtonItem.title = @"Save";
    }
    else{
        self.navBar.leftBarButtonItem = nil;
        self.navBar.rightBarButtonItem.title = @"Cancel";
    }
}

-(void)toggleEditing{
    [self toggleEditingToState:!self.editing];
}

-(void)toggleEditingToState:(BOOL)editing{
    
    UIViewAnimationOptions animationOptions = editing ? UIViewAnimationOptionCurveEaseIn : UIViewAnimationOptionCurveEaseOut;
    [UIView animateWithDuration:.2 delay:0 options:animationOptions animations:^{
        self.bottomConstraint.constant = editing ? -self.toolbar.frame.size.height : 0;
        [self.view layoutIfNeeded];
    } completion:nil];
    
    if (editing) {
        [self.nameField resignFirstResponder];
        self.navBar.rightBarButtonItem = nil;
        self.editButtonStorage.title = @"Done";
        self.editButtonStorage.style = UIBarButtonItemStyleDone;
        [self.tableView setEditing:YES animated:YES];
        
    }
    else{
        [self.navBar setRightBarButtonItem:self.saveButtonStorage animated:YES];
        self.editButtonStorage.title = @"Edit";
        self.editButtonStorage.style = UIBarButtonItemStylePlain;
        [self.tableView setEditing:NO animated:YES];
    }
    self.editing = editing;
    
}

- (IBAction)addDelay:(id)sender {
    [self.queue addObject:[NSNumber numberWithInteger:1]]; //demo code
//    [self.queue addObject:[NSNumber numberWithFloat:NAN]];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.queue.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    
    [self refreshForCountChange];
    
    if (self.queue.count < 1) {
        [self toggleEditingToState:NO];
    }

}

- (IBAction)addConditional:(id)sender {
    // Create conditional entry in array on save
    // by converting if then
    // when it is time to return
    NSString *condition;
    [self.queue addObjectsFromArray:@[condition, kConditionalEndIf]];
}

@end
