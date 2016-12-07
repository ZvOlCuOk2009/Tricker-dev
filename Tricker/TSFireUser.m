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
    
    if(token)
    {
        
        NSString *keyUserData = [NSString stringWithFormat:@"dataBase/users/%@/userData", fireUser.uid];
        NSString *keyToParameters = [NSString stringWithFormat:@"dataBase/users/%@", fireUser.uid];
        NSString *keyToPhotos = [NSString stringWithFormat:@"dataBase/users/%@", fireUser.uid];
        
        FIRDataSnapshot *fireUser = [snapshot childSnapshotForPath:keyUserData];
        FIRDataSnapshot *fireUserParameters = [snapshot childSnapshotForPath:keyToParameters];
        FIRDataSnapshot *fireUserPhotos = [snapshot childSnapshotForPath:keyToPhotos];
        
        FIRDataSnapshot *userIdent = fireUser.value[@"userID"]; 
        FIRDataSnapshot *userName = fireUser.value[@"displayName"];
        FIRDataSnapshot *userEmail = fireUser.value[@"email"];
        FIRDataSnapshot *userPhoto = fireUser.value[@"photoURL"];
        FIRDataSnapshot *dateOfBirth = fireUser.value[@"dateOfBirth"];
        FIRDataSnapshot *age = fireUser.value[@"age"];
        FIRDataSnapshot *location = fireUser.value[@"location"];
        FIRDataSnapshot *gender = fireUser.value[@"gender"];
        FIRDataSnapshot *online = fireUser.value[@"online"];
        FIRDataSnapshot *parameters = fireUserParameters.value[@"parameters"];
        FIRDataSnapshot *photos = fireUserPhotos.value[@"photos"];
        
        
        user.uid = (NSString *)userIdent;
        user.displayName = (NSString *)userName;
        user.email = (NSString *)userEmail;
        user.photoURL = (NSString *)userPhoto;
        user.dateOfBirth = (NSString *)dateOfBirth;
        user.age = (NSString *)age;
        user.location = (NSString *)location;
        user.gender = (NSString *)gender;
        user.online = (NSString *)online;
        user.parameters = (NSMutableDictionary *)parameters;
        user.photos = (NSMutableArray *)photos;
        
    }
    
    return user;
}

@end
