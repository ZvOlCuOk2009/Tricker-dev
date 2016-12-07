//
//  TSIntermediateViewController.m
//  Tricker
//
//  Created by Mac on 26.11.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "TSIntermediateViewController.h"
#import "TSCardsViewController.h"
#import "TSFireUser.h"
#import "TSFireBase.h"
#import "TSTrickerPrefixHeader.pch"

#import <SVProgressHUD.h>

@import Firebase;
@import FirebaseAuth;
@import FirebaseDatabase;

@interface TSIntermediateViewController ()

@property (strong, nonatomic) NSDictionary *fireBase;
@property (strong, nonatomic) NSMutableArray *usersFoundOnTheGender;
@property (strong, nonatomic) NSMutableArray *usersFoundOnTheAge;
@property (strong, nonatomic) NSMutableArray *usersFoundOnGenderAndAge;

@property (strong, nonatomic) NSString *genderSearch;
@property (strong, nonatomic) NSString *ageSearch;

@property (strong, nonatomic) NSString *notification;

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) TSFireUser *fireUser;

@end

@implementation TSIntermediateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.ref = [[FIRDatabase database] reference];
    
    [self.ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        self.fireUser = [TSFireUser initWithSnapshot:snapshot];
        self.fireBase = [TSFireBase initWithSnapshot:snapshot];
        
        [self configureController];

    }];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


#pragma mark - configure the controller


- (void)configureController
{
    
    self.genderSearch = [self.fireUser.parameters objectForKey:@"key1"];
    self.ageSearch = [self.fireUser.parameters objectForKey:@"key2"];
    
    NSArray *keysTaBase = [self.fireBase allKeys];
    
    self.usersFoundOnTheGender = [NSMutableArray array];
    self.usersFoundOnTheAge = [NSMutableArray array];
    self.usersFoundOnGenderAndAge = [NSMutableArray array];
    
    if (self.genderSearch) {
        
        [self userSelectionOfGender:keysTaBase];
    }
    
    if (self.ageSearch) {
        
        [self userSelectionOfAge:keysTaBase];
    }
    
    if (self.genderSearch && self.ageSearch) {
        
        for (NSDictionary *selectedUserTheGender in self.usersFoundOnTheGender) {
            NSDictionary *userData = [selectedUserTheGender objectForKey:@"userData"];
            NSString *age = [userData objectForKey:@"age"];
            NSString *uid = [userData objectForKey:@"userID"];
            if ([self computationSearchAge:self.ageSearch receivedAge:age] && ![self.fireUser.uid isEqualToString:uid]) {
                [self.usersFoundOnGenderAndAge addObject:selectedUserTheGender];
            }
        }
    }
    
    NSLog(@"Gender and age count %ld", (long)[self.usersFoundOnGenderAndAge count]);
    
    [self prepareForSegue];
}


- (void)userSelectionOfGender:(NSArray *)allKeysTaBase
{
    
    NSString *genderSearch = [self.fireUser.parameters objectForKey:@"key1"];
    
    NSArray *componentGender = [genderSearch componentsSeparatedByString:@" "];
    
    if ([componentGender count] > 1) {
        
        NSString *man = [componentGender objectAtIndex:0];
        NSString *woman = [componentGender objectAtIndex:1];
        
        for (NSString *key in allKeysTaBase) {
            NSDictionary *anyUser = [self.fireBase objectForKey:key];
            NSDictionary *userData = [anyUser objectForKey:@"userData"];
            NSString *genderAnyUser = [userData objectForKey:@"gender"];
            
            if (([genderAnyUser isEqualToString:man] && ![self.fireUser.uid isEqualToString:key]) ||
                ([genderAnyUser isEqualToString:woman] && ![self.fireUser.uid isEqualToString:key])) {
                [self.usersFoundOnTheGender addObject:anyUser];
            }
        }
        
    } else {
        
        for (NSString *key in allKeysTaBase) {
            NSDictionary *anyUser = [self.fireBase objectForKey:key];
            NSDictionary *userData = [anyUser objectForKey:@"userData"];
            NSString *genderAnyUser = [userData objectForKey:@"gender"];
            
            if ([genderAnyUser isEqualToString:genderSearch] && ![self.fireUser.uid isEqualToString:key]) {
                [self.usersFoundOnTheGender addObject:anyUser];
            }
        }
    }
}


- (void)userSelectionOfAge:(NSArray *)allKeysTaBase
{
    
    NSString *ageSearch = [self.fireUser.parameters objectForKey:@"key2"];
    
    for (NSString *key in allKeysTaBase) {
        NSDictionary *anyUser = [self.fireBase objectForKey:key];
        NSDictionary *userData = [anyUser objectForKey:@"userData"];
        NSString *ageAnyUser = [userData objectForKey:@"age"];
        
        if ([self computationSearchAge:ageSearch receivedAge:ageAnyUser] && ![self.fireUser.uid isEqualToString:key]) {
            [self.usersFoundOnTheAge addObject:anyUser];
        }
    }
}


- (BOOL)computationSearchAge:(NSString *)specifiedRange receivedAge:(NSString *)receivedAge
{
    
    NSArray *rangeDigit = [specifiedRange componentsSeparatedByString:@" "];
    NSInteger specRangeOne = [[rangeDigit objectAtIndex:0] intValue];
    NSInteger specRangeTwo = [[rangeDigit objectAtIndex:1] intValue];
    NSInteger getAge = [receivedAge intValue];
    
    BOOL totalValue;
    
    if (getAge >= specRangeOne && getAge <= specRangeTwo) {
        totalValue = YES;
    } else {
        totalValue = NO;
    }
    
    return totalValue;
    
}


- (void)prepareForSegue
{
    
    NSMutableArray *selectedUsers = nil;
    
    if (self.genderSearch) {
        selectedUsers = [NSMutableArray arrayWithArray:self.usersFoundOnTheGender];
    } else if (self.ageSearch) {
        selectedUsers = [NSMutableArray arrayWithArray:self.usersFoundOnTheAge];
    }
    
    if (self.genderSearch && self.ageSearch) {
        selectedUsers = [NSMutableArray arrayWithArray:self.usersFoundOnGenderAndAge];
    }
    
    TSCardsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"TSCardsViewController"];
    controller.selectedUsers = selectedUsers;
    
    [self.navigationController pushViewController:controller animated:NO];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


@end
