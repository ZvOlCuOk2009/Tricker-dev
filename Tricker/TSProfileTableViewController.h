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
@import FirebaseStorage;
@import FirebaseDatabase;

@interface TSProfileTableViewController : UITableViewController

@property (strong, nonatomic) NSString *selectCity;
@property (weak, nonatomic) IBOutlet UILabel *reviewsLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;

@end
