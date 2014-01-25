//
//  EJCollectionViewController.m
//  Queuey
//
//  Created by Ethan Gill on 1/24/14.
//  Copyright (c) 2014 EJ Dev. All rights reserved.
//

#import "EJMainViewController.h"

@interface EJMainViewController ()

@property NSMutableArray *queueList;

@end

//Reusable Cell Identifier
NSString * const kQueueCellIdentifier = @"queueCell";

//UIView Tags
NSInteger const kQueueTitleTag = 110;

//NSDictionary Keys
NSString * const kQueueNameKey = @"name";

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
    self.queueList = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Queues" ofType:@"plist"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.queueList.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kQueueCellIdentifier forIndexPath:indexPath];
    NSDictionary *queueDictionary = [self.queueList objectAtIndex:indexPath.row];
    
    UILabel *title = (UILabel*)[cell viewWithTag:kQueueTitleTag];
    title.text = [queueDictionary objectForKey:kQueueNameKey];
    
    return cell;
}

@end
