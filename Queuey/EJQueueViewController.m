//
//  EJQueueViewController.m
//  Queuey
//
//  Created by Jaden Geller on 1/25/14.
//  Copyright (c) 2014 EJ Dev. All rights reserved.
//

#import "EJQueueViewController.h"
#import "EJActionViewController.h"

// NSDictionary Keys
NSString * const kQueueNameKey = @"name";
NSString * const kQueueActionsKey = @"queue";
NSString * const kQueueUUIDKey = @"identifier";

// Reusable Cell Identifier
NSString * const kActionCellIdentifier = @"actionCell";

// Segue Identifier
NSString * const kActionSegueIdentifier = @"actionSegue";

@interface EJQueueViewController () <EJActionViewControllerDelegate>

@property (nonatomic, readonly) NSMutableArray *queue;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.doneButton.target = self;
    self.doneButton.action = @selector(donePress);
    
    self.cancelButton.target = self;
    self.cancelButton.action = @selector(cancelPress);
    
    [self setTextFieldPlaceholder];
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

-(void)donePress{
    if (self.nameField.text && ![self.nameField.text isEqualToString:@""]) [self.queueDictionary setObject:self.nameField.text forKey:kQueueNameKey];
    [self.delegate queueViewControllerWillDismissWithQueue:self.queueDictionary];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kActionCellIdentifier];
    
    if ([[self.queue objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
        cell.textLabel.text = (NSString*)[self.queue objectAtIndex:indexPath.row];
    }
    
    return cell;
}

-(void)keyboardWillShow:(NSNotification*)notification{
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
    
    if (actionSegue) {
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            EJActionViewController *controller = (EJActionViewController*)[segue.destinationViewController topViewController];
            controller.delegate = self;
        }
    }
}

-(void)actionViewControllerWillDismissWithAction:(NSString*)action{
    [self.queue addObject:action];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.queue.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
