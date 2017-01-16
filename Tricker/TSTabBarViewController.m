//
//  TSTabBarViewController.m
//  Tricker
//
//  Created by Mac on 05.11.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "TSTabBarViewController.h"
#import "TSTrickerPrefixHeader.pch"

@import FirebaseDatabase;

@interface TSTabBarViewController ()

@end

@implementation TSTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
        vc.title = nil;
    }];    
    
    FIRDatabaseReference *connectedRef = [[FIRDatabase database] referenceWithPath:@".info/connected"];
    [connectedRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if([snapshot.value boolValue]) {
            NSLog(@"CONNECTED");
//            self.firebaseConnected = YES;
        } else {
            NSLog(@"NOT CONNECTED");
//            self.firebaseConnected = NO;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}



@end
