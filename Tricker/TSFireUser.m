//
//  TSFireUser.m
//  Tricker
//
//  Created by Mac on 06.11.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "TSFireUser.h"

@implementation TSFireUser

+ (TSFireUser *)initWithSnapshot:(FIRDataSnapshot *)snapshot
{
    TSFireUser *user = [[TSFireUser alloc] init];
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:@"token"];
    FIRUser *fireUser = [FIRAuth auth].currentUser;

    if(token) {
        NSString *keyUserData = [NSString stringWithFormat:@"dataBase/users/%@/userData", fireUser.uid];
        NSString *keyToParameters = [NSString stringWithFormat:@"dataBase/users/%@", fireUser.uid];
        NSString *keyToChats = [NSString stringWithFormat:@"dataBase/chats/%@", fireUser.uid];
        NSString *keyToPhotos = [NSString stringWithFormat:@"dataBase/users/%@", fireUser.uid];
        NSString *keyToReviews = [NSString stringWithFormat:@"dataBase/users/%@", fireUser.uid];
        NSString *keyToLikes = [NSString stringWithFormat:@"dataBase/users/%@", fireUser.uid];
        
        FIRDataSnapshot *fireUser = [snapshot childSnapshotForPath:keyUserData];
        FIRDataSnapshot *fireUserParameters = [snapshot childSnapshotForPath:keyToParameters];
        FIRDataSnapshot *fireUserChats = [snapshot childSnapshotForPath:keyToChats];
        FIRDataSnapshot *fireUserPhotos = [snapshot childSnapshotForPath:keyToPhotos];
        FIRDataSnapshot *fireUserReviews = [snapshot childSnapshotForPath:keyToReviews];
        FIRDataSnapshot *fireUserLikes = [snapshot childSnapshotForPath:keyToLikes];
        
        FIRDataSnapshot *userIdent = fireUser.value[@"userID"]; 
        FIRDataSnapshot *userName = fireUser.value[@"displayName"];
        FIRDataSnapshot *userPhotoURL = fireUser.value[@"photoURL"];
        FIRDataSnapshot *dateOfBirth = fireUser.value[@"dateOfBirth"];
        FIRDataSnapshot *age = fireUser.value[@"age"];
        FIRDataSnapshot *location = fireUser.value[@"location"];
        FIRDataSnapshot *gender = fireUser.value[@"gender"];
        FIRDataSnapshot *online = fireUser.value[@"online"];
        FIRDataSnapshot *parameters = fireUserParameters.value[@"parameters"];
        FIRDataSnapshot *chats = nil;
        if ([snapshot hasChild:keyToChats]) {
            chats = fireUserChats.value[@"chat"];
        }
        
        FIRDataSnapshot *photos = fireUserPhotos.value[@"photos"];
        FIRDataSnapshot *reviews = fireUserReviews.value[@"reviews"];
        FIRDataSnapshot *likes = fireUserLikes.value[@"likes"];
        FIRDataSnapshot *countReviews = fireUserReviews.value[@"reviewsCount"];
        FIRDataSnapshot *countLikes = fireUserLikes.value[@"likesCount"];
        
        user.uid = (NSString *)userIdent;
        user.displayName = (NSString *)userName;
        user.photoURL = (NSString *)userPhotoURL;
        user.dateOfBirth = (NSString *)dateOfBirth;
        user.age = (NSString *)age;
        user.location = (NSString *)location;
        user.gender = (NSString *)gender;
        user.online = (NSString *)online;
        user.parameters = (NSMutableDictionary *)parameters;
        user.chats = (NSDictionary *)chats;
        user.photos = (NSMutableArray *)photos;
        user.reviews = (NSMutableArray *)reviews;
        user.likes = (NSMutableArray *)likes;
        user.countReviews = (NSString *)countReviews;
        user.countLikes = (NSString *)countLikes;
    }
    return user;
}

@end
