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
#import "TSTrickerPrefixHeader.pch"

#import <SVProgressHUD.h>

@interface TSLikesViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) TSFireUser *fireUser;
@property (strong, nonatomic) TSSwipeView *swipeView;
@property (strong, nonatomic) NSDictionary *fireBase;
@property (strong, nonatomic) NSString *interlocutorID;
@property (strong, nonatomic) NSArray *likesUsersUid;
@property (strong, nonatomic) NSMutableArray *likesUsers;
@property (strong, nonatomic) NSMutableArray *likesUsersAvatar;
@property (strong, nonatomic) NSMutableArray *likesUsersParams;
@property (strong, nonatomic) NSMutableArray *likesPhotos;

@end

@implementation TSLikesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.ref = [[FIRDatabase database] reference];
    
    self.title = @"Вы нравитесь";
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    [backItem setImage:[UIImage imageNamed:@"back"]];
    [backItem setTintColor:DARK_GRAY_COLOR];
    self.navigationItem.leftBarButtonItem = backItem;
    
    [backItem setTarget:self];
    [backItem setAction:@selector(cancelInteraction)];
    
    self.likesUsersUid = [NSArray array];
    self.likesUsers = [NSMutableArray array];
    self.likesUsersAvatar = [NSMutableArray array];
    self.likesUsersParams = [NSMutableArray array];
    self.likesPhotos = [NSMutableArray array];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.likesUsers count] == 0) {
        [self configureController];
        [self progressHubShow];
    }
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ProfileStoryboard" bundle:[NSBundle mainBundle]];
    TSProfileTableViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"TSProfileTableViewController"];
    controller.likesLabel.hidden = YES;
}


- (void)cancelInteraction
{
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0]
                                          animated:YES];
}


- (void)configureController
{
    
    [self.ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        self.fireUser = [TSFireUser initWithSnapshot:snapshot];
        self.likesUsersUid = self.fireUser.likes;
        
        if ([self.likesUsersUid count] > 0) {
            [self fillingDataSource];
        }
    }];
}


- (void)fillingDataSource
{
    
    [self.ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        self.fireBase = [TSFireBase initWithSnapshot:snapshot];
        
        for (NSString *reviewsUserUid in self.likesUsersUid) {
            
            NSDictionary *userDataReviews = [self.fireBase objectForKey:reviewsUserUid];
            NSString *nameUserInterest = [[userDataReviews objectForKey:@"userData"] objectForKey:@"displayName"];
            NSString *ageUserInterest = [[userDataReviews objectForKey:@"userData"] objectForKey:@"age"];
            NSString *photoUserInterest = [[userDataReviews objectForKey:@"userData"] objectForKey:@"photoURL"];
            
            NSArray *paramsLikes = [userDataReviews objectForKey:@"parameters"];
            NSArray *photosLikes = [userDataReviews objectForKey:@"photos"];
            
            NSDictionary *userDataLikeParam = @{@"nameUserInterest":nameUserInterest,
                                                  @"ageUserInterest":ageUserInterest};
            
            [self.likesUsers addObject:userDataLikeParam];
            [self.likesUsersAvatar addObject:[self convertAvatarByUrl:photoUserInterest]];
            [self.likesUsersParams addObject:paramsLikes];
            
            if (photosLikes) {
                [self.likesPhotos addObject:photosLikes];
            } else {
                NSArray *emptyArray = @[];
                [self.likesPhotos addObject:emptyArray];
            }
        }
        
        if ([self.likesUsers count] > 0) {
            [self.tableView reloadData];
            [self progressHubDismiss];
        } else {
            [self progressHubDismiss];
        }
        
    }];
    
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
    UIImage *avatar = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
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
    
    NSString *nameReviewUser = [[self.likesUsers objectAtIndex:indexPath.row] objectForKey:@"nameUserInterest"];
    NSString *ageReviewUser = [[self.likesUsers objectAtIndex:indexPath.row] objectForKey:@"ageUserInterest"];
    
    self.swipeView = [TSSwipeView initDetailView];
    self.swipeView.frame = CGRectMake(10, - 400, self.swipeView.frame.size.width, self.swipeView.frame.size.width);
    self.swipeView.nameLabel.text = nameReviewUser;
    self.swipeView.ageLabel.text = ageReviewUser;
    
    self.swipeView.avatarImageView.image = [self.likesUsersAvatar objectAtIndex:indexPath.row];
    self.swipeView.backgroundImageView.image = [self.likesUsersAvatar objectAtIndex:indexPath.row];
    self.swipeView.parameterUser = [self.likesUsersParams objectAtIndex:indexPath.row];
    
    NSMutableArray *photos = [self.likesPhotos objectAtIndex:indexPath.row];
    
    self.swipeView.photos = photos;
    
    if ([photos count] > 0) {
        self.swipeView.countPhotoLabel.text = [NSString stringWithFormat:@"%ld",
                                               (long)[photos count] - 1];
    }
    
    [self.view addSubview:self.swipeView];
    
    [UIView animateWithDuration:0.35
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:1.2
                        options:0
                     animations:^{
                         self.swipeView.frame = CGRectMake(10, 72, 300, 352);
                     } completion:nil];
    
    //передача ID пользователя на два разных контроллера в зависимости от потребности
    
    self.interlocutorID = [self.likesUsersUid objectAtIndex:indexPath.row];
    self.swipeView.interlocutorUid = [self.likesUsersUid objectAtIndex:indexPath.row];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(hendlePanGesture)];
    tapGestureRecognizer.numberOfTapsRequired = 2;
    [self.swipeView addGestureRecognizer:tapGestureRecognizer];
    
    recognizerTransitionOnChatController = 2;
    
}

- (void)hendlePanGesture
{
    UIImageView *heart = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heart"]];
    heart.frame = CGRectMake(- 155, 0, 630, 600);
    heart.alpha = 0;
    [self.swipeView addSubview:heart];
    
    [UIView animateWithDuration:0.35
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.8
                        options:UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         heart.alpha = 1;
                         heart.frame = CGRectMake(75, 110, 150, 130);
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
