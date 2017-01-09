//
//  TSLikeSave.m
//  Tricker
//
//  Created by Mac on 08.01.17.
//  Copyright © 2017 Mac. All rights reserved.
//

#import "TSLikeAndReviewSave.h"
#import "TSFireInterlocutor.h"

@import FirebaseAuth;
@import FirebaseDatabase;

@interface TSLikeAndReviewSave ()

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSString *userUid;

@end

@implementation TSLikeAndReviewSave

- (instancetype)init
{
    self = [super init];
    if (self) {
        FIRUser *fireUser = [FIRAuth auth].currentUser;
        self.userUid = fireUser.uid;
        self.ref = [[FIRDatabase database] reference];
    }
    return self;
}

+ (TSLikeAndReviewSave *)sharedLikeAndReviewSaveManager
{
    static TSLikeAndReviewSave *likeSave = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        likeSave = [[TSLikeAndReviewSave alloc] init];
    });
    return likeSave;
}


- (void)saveLikeInTheDatabase:(NSMutableDictionary *)likeUser
{
    
    NSMutableDictionary *likeUserData = [likeUser objectForKey:@"userData"];
    NSString *likeUserUid = [likeUserData objectForKey:@"userID"];
    NSMutableArray *likes = [likeUser objectForKey:@"likes"];
    
    if (likes == nil) {
        likes = [NSMutableArray array];
        [likes addObject:self.userUid];
    } else {
        
        for (NSString *likeUid in likes) {
            if (![likeUid isEqualToString:self.userUid]) {
                [likes addObject:self.userUid];
            }
        }
    }
    
    [[[[[self.ref child:@"dataBase"] child:@"users"] child:likeUserUid] child:@"likes"] setValue:likes];
    [self.ref  removeAllObservers];
}


- (void)saveReviewInTheDatabase:(NSMutableDictionary *)reviewsUserData reviews:(NSMutableArray *)reviews
{

    NSString *reviewUserUid = [reviewsUserData objectForKey:@"userID"];
    
    if (reviews == nil) {
        reviews = [NSMutableArray array];
        [reviews addObject:self.userUid];
    } else {
        
        for (NSString *review in reviews) {
            if (![review isEqualToString:self.userUid]) {
                [reviews addObject:self.userUid];
            }
        }
    }
    
    [[[[[self.ref child:@"dataBase"] child:@"users"] child:reviewUserUid] child:@"reviews"] setValue:reviews];
    [self.ref  removeAllObservers];
}


//- (void)saveParametrsReviewAndLikesToDatabase:(NSString *)key parametr:(NSMutableArray *)parameter
//{
//    [[[[[self.ref child:@"dataBase"] child:@"users"] child:reviewUserUid] child:@"rewiews"] setValue:reviews];
//}


@end
