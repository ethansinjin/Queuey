//
//  EJActionViewController.h
//  Queuey
//
//  Created by Jaden Geller on 1/25/14.
//  Copyright (c) 2014 EJ Dev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EJActionViewControllerDelegate <NSObject>

-(void)actionViewControllerWillDismissWithAction:(NSString*)action;

@end

@interface EJActionViewController : UITableViewController

@property (weak, nonatomic) id<EJActionViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

@end
