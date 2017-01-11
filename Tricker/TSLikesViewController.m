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
#import "TSFireUser.h"
#import "TSFireBase.h"
#import "TSTrickerPrefixHeader.pch"

#import <SVProgressHUD.h>

@interface TSLikesViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) TSFireUser *fireUser;
@property (strong, nonatomic) NSDictionary *fireBase;
@property (strong, nonatomic) NSArray *likesUsersUid;
@property (strong, nonatomic) NSMutableArray *likesUsers;
@property (strong, nonatomic) NSMutableArray *likesUsersAvatar;

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
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self progressHubShow];
    [self configureController];
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
            
            NSDictionary *userDataLikeParam = @{@"nameUserInterest":nameUserInterest,
                                                  @"ageUserInterest":ageUserInterest};
            
            [self.likesUsers addObject:userDataLikeParam];
            [self.likesUsersAvatar addObject:[self convertAvatarByUrl:photoUserInterest]];
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
