//
//  TSReviewsViewController.m
//  Tricker
//
//  Created by Mac on 09.01.17.
//  Copyright © 2017 Mac. All rights reserved.
//

#import "TSReviewsViewController.h"
#import "TSTableViewStatisticsCell.h"
#import "TSFireUser.h"
#import "TSFireBase.h"
#import "TSTrickerPrefixHeader.pch"

#import <SVProgressHUD.h>

@import FirebaseDatabase;

@interface TSReviewsViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) TSFireUser *fireUser;
@property (strong, nonatomic) NSDictionary *fireBase;
@property (strong, nonatomic) NSArray *reviewsUsersUid;
@property (strong, nonatomic) NSMutableArray *reviewsUsers;
@property (strong, nonatomic) NSMutableArray *reviewsUsersAvatar;

@end

@implementation TSReviewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.ref = [[FIRDatabase database] reference];
    
    self.title = @"Вашу анкету просматривали";
    
//    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor redColor],
//       NSFontAttributeName:[UIFont fontWithName:@"mplus-1c-regular" size:16]}];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    [backItem setImage:[UIImage imageNamed:@"back"]];
    [backItem setTintColor:DARK_GRAY_COLOR];
    self.navigationItem.leftBarButtonItem = backItem;
    
    [backItem setTarget:self];
    [backItem setAction:@selector(cancelInteraction)];
    
    self.reviewsUsersUid = [NSArray array];
    self.reviewsUsers = [NSMutableArray array];
    self.reviewsUsersAvatar = [NSMutableArray array];
    
    [self configureController];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [SVProgressHUD show];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setBackgroundColor:YELLOW_COLOR];
    [SVProgressHUD setForegroundColor:DARK_GRAY_COLOR];
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
        self.reviewsUsersUid = self.fireUser.reviews;
        
        if ([self.reviewsUsersUid count] > 0) {
            [self fillingDataSource];
        }
    }];
}


- (void)fillingDataSource
{
    
    [self.ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {

        self.fireBase = [TSFireBase initWithSnapshot:snapshot];
        
        for (NSString *reviewsUserUid in self.reviewsUsersUid) {
            
            NSDictionary *userDataReviews = [self.fireBase objectForKey:reviewsUserUid];
            NSString *nameUserInterest = [[userDataReviews objectForKey:@"userData"] objectForKey:@"displayName"];
            NSString *ageUserInterest = [[userDataReviews objectForKey:@"userData"] objectForKey:@"age"];
            NSString *photoUserInterest = [[userDataReviews objectForKey:@"userData"] objectForKey:@"photoURL"];
            
            NSDictionary *userDataReviewParam = @{@"nameUserInterest":nameUserInterest,
                                                  @"ageUserInterest":ageUserInterest};
            
            [self.reviewsUsers addObject:userDataReviewParam];
            [self.reviewsUsersAvatar addObject:[self convertAvatarByUrl:photoUserInterest]];
        }
        
        if ([self.reviewsUsers count] > 0) {
            [self.tableView reloadData];
            [SVProgressHUD dismiss];
        }
        
    }];
    
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
