//
//  TSTabBarViewController.m
//  Tricker
//
//  Created by Mac on 05.11.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "TSTabBarViewController.h"
#import "TSTrickerPrefixHeader.pch"
#import "TSIntroductionViewController.h"

@import FirebaseDatabase;

@interface TSTabBarViewController ()

@end

@implementation TSTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
        vc.title = nil;
    }];    
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self callIntroductionViewController];
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (void)callIntroductionViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ProfileStoryboard"
                                                         bundle:[NSBundle mainBundle]];
    TSIntroductionViewController *controller =
    [storyboard instantiateViewControllerWithIdentifier:@"TSIntroductionViewController"];
    controller.providesPresentationContextTransitionStyle = YES;
    controller.definesPresentationContext = YES;
    [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:controller animated:YES completion:nil];
    self.tabBarController.tabBar.hidden = YES;
}

@end
