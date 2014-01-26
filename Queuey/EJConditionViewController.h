//
//  EJActionViewController.h
//  Queuey
//
//  Created by Jaden Geller on 1/25/14.
//  Copyright (c) 2014 EJ Dev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EJConditionViewControllerDelegate <NSObject>

-(void)conditionViewControllerWillDismissWithCondition:(NSString*)condition;

@end

@interface EJConditionViewController : UITableViewController

@property (weak, nonatomic) id<EJConditionViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

@end
