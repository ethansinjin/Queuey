//
//  EJQueueViewController.h
//  Queuey
//
//  Created by Jaden Geller on 1/25/14.
//  Copyright (c) 2014 EJ Dev. All rights reserved.
//

#import <UIKit/UIKit.h>

// NSDictionary Keys
extern NSString * const kQueueNameKey;
extern NSString * const kQueueActionsKey;
extern NSString * const kQueueUUIDKey;

@protocol EJQueueViewControllerDelegate <NSObject>

-(void)queueViewControllerWillDismissWithQueue:(NSDictionary*)queue;

@end

@interface EJQueueViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

@property (weak, nonatomic) id<EJQueueViewControllerDelegate> delegate;

@property (nonatomic) NSMutableDictionary *queueDictionary;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end
