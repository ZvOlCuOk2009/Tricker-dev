//
//  TSProfileTableViewController.h
//  Tricker
//
//  Created by Mac on 09.11.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSFireUser.h"
#import "TSFireBase.h"

@import Firebase;
@import FirebaseAuth;
@import FirebaseDatabase;

@interface TSProfileTableViewController : UITableViewController

@property (strong, nonatomic) NSString *selectCity;
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (strong, nonatomic) UIBarButtonItem *doneButton;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) TSFireUser *fireUser;
@property (strong, nonatomic) TSFireBase *fireBase;

- (void)doneAction:(id)sender;

@end
