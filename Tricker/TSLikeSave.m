//
//  TSLikeSave.m
//  Tricker
//
//  Created by Mac on 08.01.17.
//  Copyright © 2017 Mac. All rights reserved.
//

#import "TSLikeSave.h"

@import FirebaseAuth;
@import FirebaseDatabase;

@interface TSLikeSave ()

@property (strong, nonatomic) FIRDatabaseReference *ref;

@end

@implementation TSLikeSave

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.ref = [[FIRDatabase database] reference];
    }
    return self;
}

+ (TSLikeSave *)sharedLikeSaveManager
{
    static TSLikeSave *likeSave = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        likeSave = [[TSLikeSave alloc] init];
    });
    return likeSave;
}


- (void)saveLikeInTheDatabase:(NSDictionary *)likeUser
{
    FIRUser *fireUser = [FIRAuth auth].currentUser;
    
    NSString *userName = fireUser.displayName;
    NSString *userAvatarUrl = fireUser.displayName;
    NSString *userUid = fireUser.displayName;
    
    NSDictionary *likeUserData = [likeUser objectForKey:@"userData"];
    
    NSString *likeUserName = [likeUserData objectForKey:@"displayName"];
    NSString *likeUserAvatarUrl = [likeUserData objectForKey:@"photoURL"];
    NSString *likeUserUid = [likeUserData objectForKey:@"userID"];
    
    NSLog(@"%@ %@", likeUserName, likeUserUid);
    
    [self.ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
    }];
}


@end
