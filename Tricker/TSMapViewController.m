//
//  TSMapViewController.m
//  Tricker
//
//  Created by Mac on 24.11.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "TSMapViewController.h"
#import "TSSocialNetworkLoginViewController.h"
#import "TSFacebookManager.h"

@import Firebase;
@import FirebaseAuth;
@import FirebaseDatabase;

@interface TSMapViewController ()

@end

@implementation TSMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)logOutAtionButton:(id)sender
{
    
    NSError *error;
    [[FIRAuth auth] signOut:&error];
    
    if (!error) {
    
        NSLog(@"Log out");
    }
    
    [[TSFacebookManager sharedManager] logOutUser];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"token"];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    TSSocialNetworkLoginViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"TSSocialNetworkLoginViewController"];
    
    [self presentViewController:controller animated:YES completion:nil];
    
}


@end
