//
//  TSTabBarViewController.m
//  Tricker
//
//  Created by Mac on 05.11.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "TSTabBarViewController.h"
#import "TSIntroductionViewController.h"
#import "TSFireUser.h"
#import "TSTrickerPrefixHeader.pch"

@import FirebaseDatabase;

@interface TSTabBarViewController ()

@property (strong, nonatomic) FIRDatabaseReference *refCountMessage;
@property (strong, nonatomic) TSFireUser *fireUser;

@end

@implementation TSTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.refCountMessage = [[FIRDatabase database] reference];
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
        vc.title = nil;
    }];    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *firstInput = [userDefaults objectForKey:@"firstInput"];
//    if (!firstInput) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self callIntroductionViewController];
            NSString *firstInput = @"firstInput";
            [userDefaults setObject:firstInput forKey:@"firstInput"];
            [userDefaults synchronize];
        });
//    }
    
//    [self.refCountMessage observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
//        self.fireUser = [TSFireUser initWithSnapshot:snapshot];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            [self setObserverForIncomingMessages:self.fireUser];
//        });
//    }];
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

- (void)setObserverForIncomingMessages:(TSFireUser *)fireUser
{
    NSDictionary *chats = fireUser.chats;
    NSArray *allKeys = [chats allKeys];
    NSInteger currentCountMessage = 0;
    for (int i = 0; i < [chats count]; i++) {
        NSString *key = [allKeys objectAtIndex:i];
        NSArray *chat = [chats objectForKey:key];
        currentCountMessage = currentCountMessage + [chat count];
    }
    
    NSInteger saveCountMessage = [[NSUserDefaults standardUserDefaults] integerForKey:@"countMessage"];
    
    NSInteger differenceMessage = currentCountMessage - saveCountMessage;
    
    [[NSUserDefaults standardUserDefaults] setInteger:differenceMessage forKey:@"countMessage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UITabBarItem *itemsChat = [self.tabBar.items objectAtIndex:2];
    itemsChat.badgeValue = [NSString stringWithFormat:@"%ld", (long)differenceMessage];
    
    NSLog(@"currentCountMessage %ld", (long)differenceMessage);
}

@end
