//
//  TSReviewsViewController.m
//  Tricker
//
//  Created by Mac on 09.01.17.
//  Copyright © 2017 Mac. All rights reserved.
//

#import "TSReviewsViewController.h"
#import "TSProfileTableViewController.h"
#import "TSTableViewStatisticsCell.h"
#import "TSGetInterlocutorParameters.h"
#import "TSSwipeView.h"
#import "TSFireUser.h"
#import "TSFireBase.h"
#import "TSReachability.h"
#import "TSAlertController.h"
#import "TSTrickerPrefixHeader.pch"

#import <SVProgressHUD.h>

@import FirebaseDatabase;

@interface TSReviewsViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) TSFireUser *fireUser;
@property (strong, nonatomic) TSSwipeView *swipeView;
@property (strong, nonatomic) NSDictionary *fireBase;
@property (strong, nonatomic) NSString *interlocutorID;
@property (strong, nonatomic) NSMutableArray *reviewsUsersUid;
@property (strong, nonatomic) NSMutableArray *reviewsUsers;
@property (strong, nonatomic) NSMutableArray *reviewsUsersAvatar;
@property (strong, nonatomic) NSMutableArray *reviewsUsersParams;
@property (strong, nonatomic) NSMutableArray *reviewsPhotos;

@property (assign, nonatomic) CGRect frameBySizeDevice;
@property (assign, nonatomic) CGRect heartInitFrame;
@property (assign, nonatomic) CGRect heartFinalFrame;
@property (assign, nonatomic) float difference;

@end

@implementation TSReviewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ref = [[FIRDatabase database] reference];
    self.title = @"Вашу анкету смотрели";
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    [backItem setImage:[UIImage imageNamed:@"back"]];
    [backItem setTintColor:DARK_GRAY_COLOR];
    self.navigationItem.leftBarButtonItem = backItem;
    [backItem setTarget:self];
    [backItem setAction:@selector(cancelInteraction)];
    
    self.reviewsUsersUid = [NSMutableArray array];
    self.reviewsUsers = [NSMutableArray array];
    self.reviewsUsersAvatar = [NSMutableArray array];
    self.reviewsUsersParams = [NSMutableArray array];
    self.reviewsPhotos = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[TSReachability sharedReachability] verificationInternetConnection]) {
        if ([self.reviewsUsers count] == 0) {
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
    controller.reviewsLabel.hidden = YES;
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
    
    [self.ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.fireUser = [TSFireUser initWithSnapshot:snapshot];
        self.reviewsUsersUid = self.fireUser.reviews;
        if ([self.reviewsUsersUid count] > 0) {
            [self fillingDataSource];
        }
    }];
}

- (void)fillingDataSource
{
    [self progressHubShow];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self.ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            self.fireBase = [TSFireBase initWithSnapshot:snapshot];
            for (NSString *reviewsUserUid in self.reviewsUsersUid) {
                if (![self.fireUser.uid isEqualToString:reviewsUserUid]) {
                    NSDictionary *userDataReviews = [self.fireBase objectForKey:reviewsUserUid];
                    NSString *nameUserInterest = [[userDataReviews objectForKey:@"userData"] objectForKey:@"displayName"];
                    NSString *ageUserInterest = [[userDataReviews objectForKey:@"userData"] objectForKey:@"age"];
                    NSString *photoUserInterest = [[userDataReviews objectForKey:@"userData"] objectForKey:@"photoURL"];
                    NSArray *paramsReviews = [userDataReviews objectForKey:@"parameters"];
                    NSArray *photosReviews = [userDataReviews objectForKey:@"photos"];
                    NSDictionary *userDataReviewParam = @{@"nameUserInterest":nameUserInterest,
                                                          @"ageUserInterest":ageUserInterest};
                    [self.reviewsUsers addObject:userDataReviewParam];
                    [self.reviewsUsersAvatar addObject:[self convertAvatarByUrl:photoUserInterest]];
                    [self.reviewsUsersParams addObject:paramsReviews];
                    if (photosReviews) {
                        [self.reviewsPhotos addObject:photosReviews];
                    } else {
                        NSArray *emptyArray = @[];
                        [self.reviewsPhotos addObject:emptyArray];
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ([self.reviewsUsers count] > 0) {
                    [self.tableView reloadData];
                    [self progressHubDismiss];
                }
            });
        }];
    });
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.reviewsUsers count];
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
    cell.interestUserName.text = [[self.reviewsUsers objectAtIndex:indexPath.row] objectForKey:@"nameUserInterest"];
    cell.interestUserAge.text = [[self.reviewsUsers objectAtIndex:indexPath.row] objectForKey:@"ageUserInterest"];
    cell.interestAvatar.image = [self.reviewsUsersAvatar objectAtIndex:indexPath.row];
}

- (UIImage *)convertAvatarByUrl:(NSString *)url
{
    UIImage *avatar = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    return avatar;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //swipeView добавляется лишь в случае если её ещё нету на экране
    if (![self.swipeView isDescendantOfView:self.view]) {
        NSString *nameReviewUser = [[self.reviewsUsers objectAtIndex:indexPath.row] objectForKey:@"nameUserInterest"];
        NSString *ageReviewUser = [[self.reviewsUsers objectAtIndex:indexPath.row] objectForKey:@"ageUserInterest"];
        
        self.swipeView = [TSSwipeView initDetailView];
        self.swipeView.frame = CGRectMake(10, - 600, self.swipeView.frame.size.width, self.swipeView.frame.size.width);
        self.swipeView.nameLabel.text = nameReviewUser;
        self.swipeView.ageLabel.text = ageReviewUser;
        self.swipeView.avatarImageView.image = [self.reviewsUsersAvatar objectAtIndex:indexPath.row];
        self.swipeView.backgroundImageView.image = [self.reviewsUsersAvatar objectAtIndex:indexPath.row];
        self.swipeView.parameterUser = [self.reviewsUsersParams objectAtIndex:indexPath.row];
        
        NSMutableArray *photos = [self.reviewsPhotos objectAtIndex:indexPath.row];
        self.swipeView.photos = photos;
        
        if ([photos count] > 0) {
            self.swipeView.countPhotoLabel.text = [NSString stringWithFormat:@"%ld", (long)[photos count] - 1];
        }
        [self.view addSubview:self.swipeView];
        
        [UIView animateWithDuration:0.35
                              delay:0
             usingSpringWithDamping:0.6
              initialSpringVelocity:1.2
                            options:0
                         animations:^{
                             self.swipeView.frame = self.frameBySizeDevice;
                         } completion:nil];
        
        //передача ID пользователя на два разных контроллера в зависимости от потребности
        
        self.interlocutorID = [self.reviewsUsersUid objectAtIndex:indexPath.row];
        self.swipeView.interlocutorUid = [self.reviewsUsersUid objectAtIndex:indexPath.row];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(hendlePanGesture)];
        tapGestureRecognizer.numberOfTapsRequired = 2;
        [self.swipeView addGestureRecognizer:tapGestureRecognizer];
        recognizerTransitionOnChatController = 2;
        
        UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hendleswipeGesture)];
        [self.swipeView addGestureRecognizer:swipeGestureRecognizer];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.reviewsUsersUid removeObjectAtIndex:indexPath.row];
        [self.reviewsUsers removeObjectAtIndex:indexPath.row];
        [self.reviewsUsersAvatar removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[[[[self.ref child:@"dataBase"] child:@"users"] child:self.fireUser.uid]
              child:@"reviews"] setValue:self.reviewsUsersUid];
        });
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
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

- (void)hendleswipeGesture:(UISwipeGestureRecognizer *)gesture
{
    
}

//тут баг, падение при свайпе, свайп горизонтальный и кривой

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pointInView = [[touches anyObject] locationInView:self.view];
    
    float xTarget = pointInView.x - self.difference;
    if(xTarget > self.tableView.frame.size.width) {
        xTarget = self.tableView.frame.size.width;
    } else if( xTarget < 0) {
        xTarget = 0;
    }
    [UIView animateWithDuration:.25
                     animations:^{
                         [self.swipeView setFrame:CGRectMake(xTarget, self.swipeView.frame.origin.y, self.swipeView.frame.size.width, self.swipeView.frame.size.height)];
                     }
     ];
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.swipeView.hidden = YES;
    [self.swipeView removeFromSuperview];
}

#pragma mark - SVProgressHUD

- (void)progressHubShow
{
    [SVProgressHUD show];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setBackgroundColor:YELLOW_COLOR];
    [SVProgressHUD setForegroundColor:DARK_GRAY_COLOR];
}

- (void)progressHubDismiss
{
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
