//
//  TSLikesViewController.m
//  Tricker
//
//  Created by Mac on 09.01.17.
//  Copyright © 2017 Mac. All rights reserved.
//

#import "TSLikesViewController.h"
#import "TSProfileTableViewController.h"
#import "TSTableViewStatisticsCell.h"
#import "TSGetInterlocutorParameters.h"
#import "TSSwipeView.h"
#import "TSFireUser.h"
#import "TSFireBase.h"
#import "TSReachability.h"
#import "TSAlertController.h"
#import "TSSVProgressHUD.h"
#import "TSTrickerPrefixHeader.pch"

#import <MDCSwipeToChoose/MDCSwipeToChoose.h>

@interface TSLikesViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (assign, nonatomic) FIRDatabaseHandle handle;
@property (strong, nonatomic) TSFireUser *fireUser;
@property (strong, nonatomic) TSSwipeView *swipeView;
@property (strong, nonatomic) NSDictionary *fireBase;
@property (strong, nonatomic) NSString *interlocutorID;
@property (strong, nonatomic) NSMutableArray *likesUsersUid;
@property (strong, nonatomic) NSMutableArray *likesUsersUidUpdate;
@property (strong, nonatomic) NSMutableArray *likesUsers;
@property (strong, nonatomic) NSMutableArray *likesUsersAvatar;
@property (strong, nonatomic) NSMutableArray *likesUsersParams;
@property (strong, nonatomic) NSMutableArray *likesPhotos;

@property (strong, nonatomic) NSString *nameUserInterest;
@property (strong, nonatomic) NSString *ageUserInterest;
@property (strong, nonatomic) NSString *onlineUserInterest;
@property (strong, nonatomic) NSString *photoUserInterest;
@property (strong, nonatomic) NSArray *paramsLikes;
@property (strong, nonatomic) NSArray *photosLikes;

@property (assign, nonatomic) CGRect frameBySizeDevice;
@property (assign, nonatomic) CGRect heartInitFrame;
@property (assign, nonatomic) CGRect heartFinalFrame;

@end

@implementation TSLikesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"TSLikesViewController");
    self.ref = [[FIRDatabase database] reference];
    self.title = @"Вы нравитесь";
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    [backItem setImage:[UIImage imageNamed:@"back"]];
    [backItem setTintColor:DARK_GRAY_COLOR];
    self.navigationItem.leftBarButtonItem = backItem;
    
    [backItem setTarget:self];
    [backItem setAction:@selector(cancelInteraction)];
    
    self.likesUsersUid = [NSMutableArray array];
    self.likesUsersUidUpdate = [NSMutableArray array];
    self.likesUsers = [NSMutableArray array];
    self.likesUsersAvatar = [NSMutableArray array];
    self.likesUsersParams = [NSMutableArray array];
    self.likesPhotos = [NSMutableArray array];
}

#pragma mark - MDCSwipeToChoose

- (BOOL)view:(UIView *)view shouldBeChosenWithDirection:(MDCSwipeDirection)direction {
    [UIView animateWithDuration:0.16 animations:^{
        view.transform = CGAffineTransformIdentity;
        view.center = [view superview].center;
    }];
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[TSReachability sharedReachability] verificationInternetConnection]) {
        if ([self.likesUsers count] == 0) {
            [TSSVProgressHUD showProgressHud];
            [self configureController];
        }
    } else {
        TSAlertController *alertController =
        [TSAlertController noInternetConnection:@"Проверьте интернет соединение..."];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ProfileStoryboard" bundle:[NSBundle mainBundle]];
    TSProfileTableViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"TSProfileTableViewController"];
    controller.likesLabel.hidden = YES;
    //[self.ref removeAllObservers];
    //[self.ref removeObserverWithHandle:self.handle];
}

- (void)cancelInteraction
{
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0]
                                          animated:YES];
}

- (void)configureController
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (IS_IPHONE_4) {
            self.frameBySizeDevice = kTSSwipeDetailViewFrame;
            self.heartInitFrame = kTSInitialHeartRect;
            self.heartFinalFrame = kTSFinalHeartRect;
        } else if (IS_IPHONE_5) {
            self.frameBySizeDevice = kTSSwipeDetailView5Frame;
            self.heartInitFrame = kTSInitialHeartRect;
            self.heartFinalFrame = kTSFinalHeartRect;
        } else if (IS_IPHONE_6) {
            self.frameBySizeDevice = kTSSwipeDetailView6Frame;
            self.heartInitFrame = kTSInitialHeartRect;
            self.heartFinalFrame = kTSFinalHeartRect;
        } else if (IS_IPHONE_6_PLUS) {
            self.frameBySizeDevice = kTSSwipeDetailView6PlusFrame;
            self.heartInitFrame = kTSInitialHeartRect6plus;
            self.heartFinalFrame = kTSFinalHeartRect6plus;
        }
        
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        if (IS_IPAD_2) {
            self.frameBySizeDevice = kTSSwipeDetailViewIpadFrame;
            self.heartInitFrame = kTSInitialHeartRect;
            self.heartFinalFrame = kTSFinalHeartRect;
        }
    }
    
    self.handle = [self.ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.fireUser = [TSFireUser initWithSnapshot:snapshot];
        self.likesUsersUid = self.fireUser.likes;
        
        if ([self.likesUsersUid count] > 0) {
            [self fillingDataSource];
        } else {
            [TSSVProgressHUD dissmisProgressHud];
        }
    }];
}

- (void)fillingDataSource
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            self.fireBase = [TSFireBase initWithSnapshot:snapshot];
            for (NSString *reviewsUserUid in self.likesUsersUid) {
                if (![self.fireUser.uid isEqualToString:reviewsUserUid]) {
                    NSDictionary *userDataLikes = [self.fireBase objectForKey:reviewsUserUid];
                    self.nameUserInterest = [[userDataLikes objectForKey:@"userData"] objectForKey:@"displayName"];
                    self.ageUserInterest = [[userDataLikes objectForKey:@"userData"] objectForKey:@"age"];
                    self.onlineUserInterest = [[userDataLikes objectForKey:@"userData"] objectForKey:@"online"];
                    self.photoUserInterest = [[userDataLikes objectForKey:@"userData"] objectForKey:@"photoURL"];
                    self.paramsLikes = [userDataLikes objectForKey:@"parameters"];
                    self.photosLikes = [userDataLikes objectForKey:@"photos"];
                    
                    if (self.nameUserInterest == nil) {
                        [self setCaps];
                    }
                    
                    NSDictionary *userDataLikeParam = @{@"nameUserInterest":self.nameUserInterest,
                                                        @"ageUserInterest":self.ageUserInterest,
                                                        @"onlineUserInterest":self.onlineUserInterest};
                    [self.likesUsers addObject:userDataLikeParam];
                    [self.likesUsersAvatar addObject:[self convertAvatarByUrl:self.photoUserInterest]];
                    [self.likesUsersParams addObject:self.paramsLikes];
                    [self.likesUsersUidUpdate addObject:reviewsUserUid];
                    if (self.photosLikes) {
                        [self.likesPhotos addObject:self.photosLikes];
                    } else {
                        NSArray *emptyArray = @[];
                        [self.likesPhotos addObject:emptyArray];
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.likesUsers count] > 0) {
                    [self.tableView reloadData];
                    [TSSVProgressHUD dissmisProgressHud];
                }
            });
        }];
    });
}

- (void)setCaps
{
    if (self.nameUserInterest == nil) {
        self.nameUserInterest = @"not found";
    }
    
    if (self.ageUserInterest == nil) {
        self.ageUserInterest = @"not found";
    }
    
    if (self.onlineUserInterest == nil) {
        self.onlineUserInterest = @"not found";
    }
    
    if (self.photoUserInterest == nil) {
        self.photoUserInterest = @"not found";
    }
    
    if (self.paramsLikes == nil) {
        self.paramsLikes = [NSArray arrayWithObject:@""];
    }
    
    if (self.photosLikes == nil) {
        self.photosLikes = [NSArray arrayWithObject:@""];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.likesUsers count];
}

- (TSTableViewStatisticsCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    
    TSTableViewStatisticsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[TSTableViewStatisticsCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(TSTableViewStatisticsCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.interestUserName.text = [[self.likesUsers objectAtIndex:indexPath.row] objectForKey:@"nameUserInterest"];
    cell.interestUserAge.text = [[self.likesUsers objectAtIndex:indexPath.row] objectForKey:@"ageUserInterest"];
    cell.interestAvatar.image = [self.likesUsersAvatar objectAtIndex:indexPath.row];
}

- (UIImage *)convertAvatarByUrl:(NSString *)url
{
    UIImage *avatar = nil;
    if ([url isEqualToString:@"not found"]) {
        avatar = [UIImage imageNamed:@"placeholder_avarar"];
    } else {
        avatar = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    }
    return avatar;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //swipeView добавляется лишь в случае если его ещё нету на экране
    if (![self.swipeView isDescendantOfView:self.view]) {
        NSString *nameLikeUser = [[self.likesUsers objectAtIndex:indexPath.row] objectForKey:@"nameUserInterest"];
        NSString *ageLikeUser = [[self.likesUsers objectAtIndex:indexPath.row] objectForKey:@"ageUserInterest"];
        NSString *onlineUserInterest = [[self.likesUsers objectAtIndex:indexPath.row] objectForKey:@"onlineUserInterest"];
        
        if ([nameLikeUser isEqualToString:@"not found"]) {
            TSAlertController *alertController = [TSAlertController noInternetConnection:@"Пользователь удален!!!"];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            self.swipeView = [TSSwipeView initDetailView];
            self.swipeView.frame = CGRectMake(10, - 400, self.swipeView.frame.size.width, self.swipeView.frame.size.width);
            self.swipeView.nameLabel.text = nameLikeUser;
            self.swipeView.ageLabel.text = ageLikeUser;
            self.swipeView.onlineState = onlineUserInterest;
            self.swipeView.avatarImageView.image = [self.likesUsersAvatar objectAtIndex:indexPath.row];
            self.swipeView.backgroundImageView.image = [self.likesUsersAvatar objectAtIndex:indexPath.row];
            self.swipeView.parameterUser = [self.likesUsersParams objectAtIndex:indexPath.row];
            
            //container for swipeView
            MDCSwipeToChooseView *containerView = [[MDCSwipeToChooseView alloc] initWithFrame:self.view.bounds
                                                                                      options:nil];
            [containerView addSubview:self.swipeView];
            [self.view addSubview:containerView];
            
            NSMutableArray *photos = [self.likesPhotos objectAtIndex:indexPath.row];
            self.swipeView.photos = photos;
            
            if ([photos count] > 0) {
                self.swipeView.countPhotoLabel.text = [NSString stringWithFormat:@"%ld",
                                                       (long)[photos count] - 1];
            }
            
            [UIView animateWithDuration:0.35
                                  delay:0
                 usingSpringWithDamping:0.6
                  initialSpringVelocity:1.2
                                options:0
                             animations:^{
                                 self.swipeView.frame = self.frameBySizeDevice;
                             } completion:nil];
            
            //передача ID пользователя на два разных контроллера в зависимости от потребности
            
            self.interlocutorID = [self.likesUsersUidUpdate objectAtIndex:indexPath.row];
            self.swipeView.interlocutorUid = [self.likesUsersUidUpdate objectAtIndex:indexPath.row];
            
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                   action:@selector(hendlePanGesture)];
            tapGestureRecognizer.numberOfTapsRequired = 2;
            [self.swipeView addGestureRecognizer:tapGestureRecognizer];
            
            recognizerTransitionOnChatController = 0;

        }
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *button =
    [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Удалить" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
     {
         [self.likesUsersUidUpdate removeObjectAtIndex:indexPath.row];
         [self.likesUsers removeObjectAtIndex:indexPath.row];
         [self.likesUsersAvatar removeObjectAtIndex:indexPath.row];
         [tableView reloadData];
         
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
             [[[[[self.ref child:@"dataBase"] child:@"users"] child:self.fireUser.uid]
               child:@"likes"] setValue:self.likesUsersUidUpdate];
         });
     }];
    button.backgroundColor = DARK_GRAY_COLOR;
    return @[button];
}

- (void)hendlePanGesture
{
    UIImageView *heart = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heart"]];
    heart.frame = self.heartInitFrame;
    heart.alpha = 0;
    [self.swipeView addSubview:heart];
    
    [UIView animateWithDuration:0.35
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.8
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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[TSGetInterlocutorParameters sharedGetInterlocutor] getInterlocutorFromDatabase:self.interlocutorID
                                                                              respondent:@"ChatViewController"];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
