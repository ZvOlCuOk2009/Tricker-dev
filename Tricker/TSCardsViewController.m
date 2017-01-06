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
#import "TSIntermediateViewController.h"
#import "TSSettingsTableViewController.h"
#import "TSTabBarViewController.h"
#import "UIAlertController+TSAlertController.h"
#import "TSPhotoZoomViewController.h"
#import "TSTrickerPrefixHeader.pch"

#import <SVProgressHUD.h>

@interface TSCardsViewController () <ZLSwipeableViewDataSource, ZLSwipeableViewDelegate>

@property (strong, nonatomic) ZLSwipeableView *swipeableView;
@property (weak, nonatomic) TSSwipeView *swipeView;
@property (strong, nonatomic) UIImage *convertImage;
@property (strong, nonatomic) UIView *cap;

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
    
    
    if (self.selectedUsers.count <= 2) {
        self.counterIndexPath = 0;
    } else {
        self.counterIndexPath = 2;
    }
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

//     [self showProgressHud];
     
    if (self.cap) {
        self.cap.hidden = NO;
    } else {
        
        self.cap = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 5) * 2, self.view.frame.size.height - 44, self.view.frame.size.width / 5, 44)];
        self.cap.backgroundColor = [UIColor redColor];
        NSArray *buttons = @[@"", @"", self.cap];
        [self.tabBarController setToolbarItems:buttons];
    }
    
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    self.cap.hidden = YES;
}


#pragma mark - ZLSwipeableViewDataSource


- (UIView *)nextViewForSwipeableView:(ZLSwipeableView *)swipeableView
{
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.counterIndexPath inSection:0];
    
    NSInteger max = [self.selectedUsers count];
    NSInteger indexPathRow = indexPath.row;
    
    if (self.selectedUsers.count > 0) {
         
         if (indexPathRow <= max - 1) {
        
            NSDictionary *selectedUser = [self.selectedUsers objectAtIndex:indexPathRow];
            
            self.swipeView = [TSSwipeView initProfileView];
            
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
            
            NSInteger countPhotos = [photosUser count];
            
            if (countPhotos > 0) {
                countPhotos = countPhotos - 1;
            }
            
            NSString *countPhoto = [NSString stringWithFormat:@"%ld", (long)countPhotos];
            
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
            
        }
        
        self.counterIndexPath++;
        
        //алерт вызывается в случае когда пользователи закончились
        
        if (indexPathRow == max + 1) {
          
             
             UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"По данным параметрам пользователей больше нету..."
                                                                                      message:nil
                                                                               preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction *repearAction = [UIAlertAction actionWithTitle:@"Просмотреть ещё раз"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {

                                                                 self.counterIndexPath = 0;
                                                                 [self repeatSearchParameter];

                                                            }];
             
             UIAlertAction *changeAction = [UIAlertAction actionWithTitle:@"Изменить параметры поиска"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {

                                                                 [self changeSearchParameter];
                                                            }];
             
             UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Отменить"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
                                                                 
                                                            }];
             
             [alertController customizationAlertView:@"По данным параметрам пользователей больше нету"
                                            byLength:46 byFont:16.f];
             
             [alertController addAction:repearAction];
             [alertController addAction:changeAction];
             [alertController addAction:cancelAction];
             
             [self presentViewController:alertController animated:YES completion:nil];
            
         }
        
     } else {
        
        //алерт вызывается в случае когда пользователей нету по заданным параметрам
        
          UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"По данным параметрам    пользователей не найдено..."
                                                                                   message:nil
                                                                            preferredStyle:UIAlertControllerStyleAlert];
        
          UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Oк"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                              
                                                           }];
         
          [alertController customizationAlertView:@"По данным параметрам пользователей не найдено..."
                                         byLength:48 byFont:16.f];
         
          [alertController addAction:okAction];
          [self presentViewController:alertController animated:YES completion:nil];
        
      }
     
     [self dissmisProgressHud];

     if (indexPathRow >= max) {
          return nil;
     } else {
          return self.swipeView;
     }
    
}


- (void)repeatSearchParameter
{
     [self.navigationController popToRootViewControllerAnimated:NO];
     [self showProgressHud];
}


- (void)changeSearchParameter
{
    self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:4];
}


#pragma mark - ProgressHUD


- (void)showProgressHud
{
     [SVProgressHUD show];
     [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
     [SVProgressHUD setBackgroundColor:YELLOW_COLOR];
     [SVProgressHUD setForegroundColor:DARK_GRAY_COLOR];
}


- (void)dissmisProgressHud
{
     [SVProgressHUD dismiss];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
