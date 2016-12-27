//
//  TSCardsViewController.m
//  Tricker
//
//  Created by Mac on 24.11.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "TSCardsViewController.h"
#import "TSFireUser.h"
#import "TSFireBase.h"
#import "ZLSwipeableView.h"
#import "TSSwipeView.h"
#import "TSAlertViewCard.h"
#import "TSSettingsTableViewController.h"
#import "TSTabBarViewController.h"
#import "TSTrickerPrefixHeader.pch"

@interface TSCardsViewController () <ZLSwipeableViewDataSource, ZLSwipeableViewDelegate>

@property (strong, nonatomic) ZLSwipeableView *swipeableView;
@property (weak, nonatomic) TSSwipeView *swipeView;
@property (strong, nonatomic) UIImage *convertImage;

@property (assign, nonatomic) NSInteger counterIndexPath;

@end

@implementation TSCardsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureController];
}


- (void)configureController
{
    
    CGRect frame = CGRectMake(0, - 20, self.view.bounds.size.width, self.view.bounds.size.height);
    
    self.swipeableView = [[ZLSwipeableView alloc] initWithFrame:self.view.frame];
    self.swipeableView.frame = frame;
    [self.view addSubview:self.swipeableView];
    
    self.swipeableView.dataSource = self;
    self.swipeableView.delegate = self;
    
    [self.swipeableView swipeTopViewToLeft];
    [self.swipeableView swipeTopViewToRight];
    
    [self.swipeableView discardAllViews];
    [self.swipeableView loadViewsIfNeeded];
    
    self.counterIndexPath = 0;
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[[[self.tabBarController tabBar] items] objectAtIndex:2] setEnabled:NO];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[[[self.tabBarController tabBar] items] objectAtIndex:2] setEnabled:YES];
    [self.tabBarItem setImage:[UIImage imageNamed:@"cards_click"]];
}


#pragma mark - ZLSwipeableViewDataSource


- (UIView *)nextViewForSwipeableView:(ZLSwipeableView *)swipeableView
{
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.counterIndexPath inSection:0];
    
    if (self.selectedUsers.count > 0) {
        
        NSInteger indexPathRow = indexPath.row;
        NSDictionary *selectedUser = [self.selectedUsers objectAtIndex:indexPathRow];
        
        self.swipeView = [TSSwipeView initProfileView];
        
        NSInteger max = [self.selectedUsers count];
        
        NSDictionary *selectedUserData = [selectedUser objectForKey:@"userData"];
        NSDictionary *parametersUser = [selectedUser objectForKey:@"parameters"];
        NSMutableArray *photosUser = [selectedUser objectForKey:@"photos"];
        NSString *photoURL = [selectedUserData objectForKey:@"photoURL"];
        NSString *displayName = [selectedUserData objectForKey:@"displayName"];
        NSString *age = [selectedUserData objectForKey:@"age"];
        NSString *online = [selectedUserData objectForKey:@"online"];
        NSString *uid = [selectedUserData objectForKey:@"userID"];
        
        
        //установка индикации онлайн
        
        if ([online isEqualToString:@"оффлайн"]) {
            self.swipeView.onlineView.backgroundColor = [UIColor redColor];
        } else if ([online isEqualToString:@"онлайн"]) {
            self.swipeView.onlineView.backgroundColor = [UIColor greenColor];
        }
        
        //установка изображения и фона
        
        UIImage *avatar = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoURL]]];
        
        self.swipeView.backgroundImageView.image = avatar;
        self.swipeView.avatarImageView.image = avatar;
        
        if (!photoURL) {
            photoURL = @"";
            self.swipeView.avatarImageView.image = [UIImage imageNamed:@"placeholder"];
        }
        
        
        NSString *firstString = [photosUser firstObject];
        if ([firstString isEqualToString:@""]) {
            [photosUser removeObjectAtIndex:0];
        }
        
        //установка параметров
        
        self.swipeView.nameLabel.text = displayName;
        self.swipeView.ageLabel.text = age;
        
        NSString *countPhoto = [NSString stringWithFormat:@"%ld", (long)[photosUser count]];
        
        if ([countPhoto isEqualToString:@"0"]) {
            countPhoto = @"";
        }
        
        self.swipeView.countPhotoLabel.text = countPhoto;
        
        self.swipeView.parameterUser = parametersUser;
        self.swipeView.photos = photosUser;
        self.swipeView.interlocutorUid = uid;
        self.swipeView.interlocutorAvatar = avatar;
        self.swipeView.interlocutorName = displayName;
        
        [self.swipeView.chatButton setImage:[UIImage imageNamed:@"chat"] forState:UIControlStateNormal];
        
        self.counterIndexPath++;
        
        if (self.counterIndexPath == max) {
            
//            [UIView animateWithDuration:0.35
//                                  delay:0.0
//                 usingSpringWithDamping:1.5
//                  initialSpringVelocity:0.9
//                                options:UIViewAnimationOptionAllowUserInteraction
//                             animations:^{
//                                 TSAlertViewCard *alertViewCard = [TSAlertViewCard initAlertViewCard];
//                                 alertViewCard.frame = CGRectOffset(alertViewCard.frame, 0, 150);
//                                 [self.view addSubview:alertViewCard];
//                             } completion:^(BOOL finished) {
//                                 
//                             }];
            
            self.counterIndexPath = 0;
        }
        
    } else {
        
        //alert!!!
    }
    
    return self.swipeView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
