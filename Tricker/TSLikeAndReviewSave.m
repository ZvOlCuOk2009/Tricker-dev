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

- (void)saveReviewInTheDatabase:(NSMutableDictionary *)reviewsUserData reviews:(NSMutableArray *)reviews
{
    NSString *reviewUserUid = [reviewsUserData objectForKey:@"userID"];
    
    if (!reviewUserUid) {
        reviewUserUid = [[reviewsUserData objectForKey:@"userData"] objectForKey:@"userID"];
    }
    
    NSMutableArray *updateReviews = [NSMutableArray array];
    
    if (reviews == nil) {
        reviews = [NSMutableArray array];
        [reviews addObject:self.userUid];
    } else {
        
        BOOL recognizer = NO;
        
        for (NSString *review in reviews) {
            if ([review isEqualToString:self.userUid]) {
                recognizer = YES;
                break;
            } else {
                recognizer = NO;
            }
        }
        
        if (recognizer == NO) {
            [updateReviews addObject:self.userUid];
        }
    }
    
    if ([updateReviews count] > 0) {
        [reviews addObjectsFromArray:updateReviews];
    }
    
    [self saveParametrsReviewAndLikesToDatabase:reviewUserUid byKeyField:@"reviews" parametr:reviews];
}

- (void)saveLikeInTheDatabase:(NSMutableDictionary *)likeUser
{
    
    NSMutableDictionary *likeUserData = [likeUser objectForKey:@"userData"];
    NSString *likeUserUid = [likeUserData objectForKey:@"userID"];
    NSMutableArray *likes = [likeUser objectForKey:@"likes"];
    NSMutableArray *updateLikes = [NSMutableArray array];
    
    if (likes == nil) {
        likes = [NSMutableArray array];
        [likes addObject:self.userUid];
    } else {
        
        BOOL recognizer = NO;
        
        for (NSString *likeUid in likes) {
            if ([likeUid isEqualToString:self.userUid]) {
                recognizer = YES;
                break;
            } else {
                recognizer = NO;
            }
        }
        
        if (recognizer == NO) {
            [updateLikes addObject:self.userUid];
        }
    }
    
    if ([updateLikes count] > 0) {
        [likes addObjectsFromArray:updateLikes];
    }
    
    if (likes) {
        [self saveParametrsReviewAndLikesToDatabase:likeUserUid byKeyField:@"likes" parametr:likes];
    }
}

- (void)saveParametrsReviewAndLikesToDatabase:(NSString *)keyUid byKeyField:(NSString *)keyField
                                     parametr:(NSMutableArray *)parameter
{
    [[[[[self.ref child:@"dataBase"] child:@"users"] child:keyUid] child:keyField] setValue:parameter];
    [self.ref  removeAllObservers];
}

@end
