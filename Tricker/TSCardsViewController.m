//
//  TSCardsViewController.m
//  Tricker
//
//  Created by Mac on 24.11.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "TSCardsViewController.h"
//#import "TSFireUser.h"
#import "TSFireBase.h"
#import "ZLSwipeableView.h"
#import "TSSwipeView.h"
#import "TSIntermediateViewController.h"
#import "TSSettingsTableViewController.h"
#import "TSTabBarViewController.h"
#import "TSPhotoZoomViewController.h"
#import "TSLikeAndReviewSave.h"
#import "TSReachability.h"
#import "TSAlertController.h"
#import "TSSVProgressHUD.h"
#import "TSTrickerPrefixHeader.pch"

@interface TSCardsViewController () <ZLSwipeableViewDataSource, ZLSwipeableViewDelegate>

@property (strong, nonatomic) ZLSwipeableView *swipeableView;
@property (weak, nonatomic) TSSwipeView *swipeView;

@property (strong, nonatomic) UIImage *convertImage;
@property (strong, nonatomic) UIView *cap;
@property (strong, nonatomic) NSMutableDictionary *selectedUserData;
@property (strong, nonatomic) NSMutableArray *selectedReviews;

@property (assign, nonatomic) NSInteger counterIndexPath;
@property (assign, nonatomic) NSInteger indexPathRow;
@property (assign, nonatomic) CGRect heartInitFrame;
@property (assign, nonatomic) CGRect heartFinalFrame;

@end

@implementation TSCardsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureController];
}

- (void)configureController
{
     if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
          if (IS_IPHONE_4) {
               self.heartInitFrame = kTSInitialHeartCardContrRect5;
               self.heartFinalFrame = kTSFinalHeartCardContrRect5;
          } else if (IS_IPHONE_5) {
               self.heartInitFrame = kTSInitialHeartCardContrRect5;
               self.heartFinalFrame = kTSFinalHeartCardContrRect5;
          } else if (IS_IPHONE_6) {
               self.heartInitFrame = kTSInitialHeartCardContrRect6;
               self.heartFinalFrame = kTSFinalHeartCardContrRect6;
          } else if (IS_IPHONE_6_PLUS) {
               self.heartInitFrame = kTSInitialHeartCardContrRect6plus;
               self.heartFinalFrame = kTSFinalHeartCardContrRect6plus;
          }
     } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
          if (IS_IPAD_2) {
               self.heartInitFrame = kTSInitialHeartCardContrRectIpad;
               self.heartFinalFrame = kTSFinalHeartCardContrRectIpad;
          } else if (IS_IPAD_PRO) {
               self.heartInitFrame = kTSInitialHeartCardContrRectIpad;
               self.heartFinalFrame = kTSFinalHeartCardContrRectIpad;
          }
     }
     
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
     if ([[TSReachability sharedReachability] verificationInternetConnection]) {
          if (self.cap) {
               self.cap.hidden = NO;
          } else {
               self.cap = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 5) * 2, self.view.frame.size.height - 44, self.view.frame.size.width / 5, 44)];
               self.cap.backgroundColor = [UIColor redColor];
               NSArray *buttons = @[@"", @"", self.cap];
               [self.tabBarController setToolbarItems:buttons];
          }
          recognizerControllersCardsAndChat = 1;
     } else {
          TSAlertController *alertController =
          [TSAlertController noInternetConnection:@"Проверьте интернет соединение..."];
          [self presentViewController:alertController animated:YES completion:nil];
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
    self.indexPathRow = indexPath.row;
    
    if (self.selectedUsers.count > 0) {
         if (self.indexPathRow <= max - 1) {
            NSDictionary *selectedUser = [self.selectedUsers objectAtIndex:self.indexPathRow];
            self.swipeView = [TSSwipeView initProfileView];
              [self setParametersFoundByUser:selectedUser];
        }
        self.counterIndexPath++;
        
        //алерт вызывается когда пользователи закончились
        if (self.indexPathRow == max + 1) {
             TSAlertController *alertController =
             [TSAlertController sharedAlertController:@"По данным параметрам пользователей больше нету..." size:18];
             UIAlertAction *repearAction = [UIAlertAction actionWithTitle:@"Просмотреть ещё раз"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
                                                                 [self callTabBarControllerByIndex:2];
                                                            }];
             
             UIAlertAction *changeAction = [UIAlertAction actionWithTitle:@"Изменить параметры поиска"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
                                                                 [self callTabBarControllerByIndex:4];
                                                            }];
             
             UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Отменить"
                                                              style:UIAlertActionStyleDefault
                                                            handler:nil];
             
             [repearAction setValue:[UIColor blackColor] forKey:@"titleTextColor"];
             [changeAction setValue:[UIColor blackColor] forKey:@"titleTextColor"];
             [cancelAction setValue:[UIColor blackColor] forKey:@"titleTextColor"];

             [alertController addAction:repearAction];
             [alertController addAction:changeAction];
             [alertController addAction:cancelAction];
             [self presentViewController:alertController animated:YES completion:nil];
         }
     } else {
        //алерт вызывается в случае когда пользователей нету по заданным параметрам
          TSAlertController *alertController =
          [TSAlertController sharedAlertController:@"По данным параметрам пользователей не найдено..." size:18];
          UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Oк"
                                                             style:UIAlertActionStyleDefault
                                                           handler:nil];
          [alertController addAction:okAction];
          [self presentViewController:alertController animated:YES completion:nil];
     }
     
     UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(hendlePanGesture)];
     tapGestureRecognizer.numberOfTapsRequired = 2;
     [self.view addGestureRecognizer:tapGestureRecognizer];
     
     if (self.indexPathRow >= max) {
          return nil;
     } else {
          return self.swipeView;
     }
}

- (void)setParametersFoundByUser:(NSDictionary *)selectedUser
{
     self.selectedUserData = [selectedUser objectForKey:@"userData"];
     NSDictionary *parametersUser = [selectedUser objectForKey:@"parameters"];
     NSMutableArray *photosUser = [selectedUser objectForKey:@"photos"];
     NSString *photoURL = [self.selectedUserData objectForKey:@"photoURL"];
     NSString *displayName = [self.selectedUserData objectForKey:@"displayName"];
     NSString *age = [self.selectedUserData objectForKey:@"age"];
     NSString *online = [self.selectedUserData objectForKey:@"online"];
     NSString *uid = [self.selectedUserData objectForKey:@"userID"];
     self.selectedReviews = [selectedUser objectForKey:@"reviews"];
     
     //установка индикации онлайн
     if ([online isEqualToString:@"оффлайн"]) {
          self.swipeView.onlineView.backgroundColor = [UIColor redColor];
     } else if ([online isEqualToString:@"онлайн"]) {
          self.swipeView.onlineView.backgroundColor = [UIColor greenColor];
     }
     
     //установка изображения и фона
     if (photoURL) {
          self.swipeView.backgroundImageView.image = [self.userAvatars objectAtIndex:self.indexPathRow];
          self.swipeView.avatarImageView.image = [self.userAvatars objectAtIndex:self.indexPathRow];
     } else {
          photoURL = @"";
          self.swipeView.avatarImageView.image = [UIImage imageNamed:@"placeholder"];
          self.swipeView.backgroundImageView.image = [UIImage imageNamed:@"placeholder"];
     }
     
     NSString *firstString = [photosUser firstObject];
     if ([firstString isEqualToString:@""]) {
          [photosUser removeObjectAtIndex:0];
     }
     
     //установка параметров
     self.swipeView.nameLabel.text = displayName;
     self.swipeView.ageLabel.text = age;
     self.swipeView.interlocutorAvatarUrl = photoURL;
     NSInteger countPhotos = [photosUser count];
     if (countPhotos > 0) {
          countPhotos = countPhotos - 1;
     }
     
     NSString *countPhoto = [NSString stringWithFormat:@"%ld", (long)countPhotos];
     if ([countPhoto isEqualToString:@"0"]) {
          countPhoto = @"";
     }
     
     //передача параметров
     self.swipeView.countPhotoLabel.text = countPhoto;
     self.swipeView.parameterUser = parametersUser;
     self.swipeView.photos = photosUser;
     self.swipeView.interlocutorUid = uid;
     self.swipeView.interlocutorAvatar = [self.userAvatars objectAtIndex:self.indexPathRow];
     self.swipeView.interlocutorName = displayName;
     
     //параметры просмотров и лайков
     self.swipeView.interlocutorData = self.selectedUserData;
     self.swipeView.interlocutorReviews = self.selectedReviews;
}

- (void)callTabBarControllerByIndex:(NSInteger)index
{
     UIStoryboard *stotyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
     TSTabBarViewController *controller =
     [stotyboard instantiateViewControllerWithIdentifier:@"TSTabBarViewController"];
     [controller setSelectedIndex:index];
     [self presentViewController:controller animated:YES completion:nil];
}

- (void)setProgressHub
{
     [TSSVProgressHUD showProgressHud];
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          [TSSVProgressHUD dissmisProgressHud];
     });
}

#pragma mark - UITapGestureRecognizer

//обработка лайков

- (void)hendlePanGesture
{
     if ([self.view subviews] > 0) {
          
          UIImageView *heart = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heart"]];
          heart.frame = self.heartInitFrame;
          heart.alpha = 0;
          [self.view addSubview:heart];
          
          [UIView animateWithDuration:0.4
                                delay:0
               usingSpringWithDamping:1.2
                initialSpringVelocity:1.3
                              options:UIViewAnimationOptionLayoutSubviews
                           animations:^{
                                heart.alpha = 1;
                                heart.frame = self.heartFinalFrame;
                           } completion:nil];
          
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
               [UIView animateWithDuration:0.15
                                animations:^{
                                     heart.alpha = 0;
                                }];
          });
          
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
               [heart removeFromSuperview];
          });
          
          NSMutableDictionary *likeUserData = [self.selectedUsers objectAtIndex:self.indexPathRow - 1];
          
          dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
               [[TSLikeAndReviewSave sharedLikeAndReviewSaveManager] saveLikeInTheDatabase:likeUserData];
          });
     }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
