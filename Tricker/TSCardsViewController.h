//
//  TSCardsViewController.h
//  Tricker
//
//  Created by Mac on 24.11.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSCardsViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *selectedUsers;

- (void)changeActionAlertView;
- (void)repeatActionAlertView;
- (void)rotationViewToClockwise;

@end
