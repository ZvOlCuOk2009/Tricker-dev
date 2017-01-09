//
//  TSFireInterlocutor.m
//  Tricker
//
//  Created by Mac on 17.12.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "TSFireInterlocutor.h"

@implementation TSFireInterlocutor

+ (TSFireInterlocutor *)initWithSnapshot:(FIRDataSnapshot *)snapshot byIdentifier:(NSString *)identifier
{
    
    TSFireInterlocutor *interlocutor = [[TSFireInterlocutor alloc] init];
    
    NSString *keyInterlocutorData = [NSString stringWithFormat:@"dataBase/users/%@/userData", identifier];
    NSString *keyToParameters = [NSString stringWithFormat:@"dataBase/users/%@", identifier];
    NSString *keyToPhotos = [NSString stringWithFormat:@"dataBase/users/%@", identifier];
    
    FIRDataSnapshot *fireInterlocutor = [snapshot childSnapshotForPath:keyInterlocutorData];
    FIRDataSnapshot *fireInterlocutorParameters = [snapshot childSnapshotForPath:keyToParameters];
    FIRDataSnapshot *fireInterlocutorPhotos = [snapshot childSnapshotForPath:keyToPhotos];
    
    FIRDataSnapshot *interlocutorIdent = fireInterlocutor.value[@"userID"];
    FIRDataSnapshot *interlocutorName = fireInterlocutor.value[@"displayName"];
    FIRDataSnapshot *interlocutorEmail = fireInterlocutor.value[@"email"];
    FIRDataSnapshot *interlocutorPhoto = fireInterlocutor.value[@"photoURL"];
    FIRDataSnapshot *interlocutorOfBirth = fireInterlocutor.value[@"dateOfBirth"];
    FIRDataSnapshot *age = fireInterlocutor.value[@"age"];
    FIRDataSnapshot *location = fireInterlocutor.value[@"location"];
    FIRDataSnapshot *gender = fireInterlocutor.value[@"gender"];
    FIRDataSnapshot *online = fireInterlocutor.value[@"online"];
    FIRDataSnapshot *parameters = fireInterlocutorParameters.value[@"parameters"];
    FIRDataSnapshot *photos = fireInterlocutorPhotos.value[@"photos"];
    
    
    interlocutor.uid = (NSString *)interlocutorIdent;
    interlocutor.displayName = (NSString *)interlocutorName;
    interlocutor.email = (NSString *)interlocutorEmail;
    interlocutor.photoURL = (NSString *)interlocutorPhoto;
    interlocutor.dateOfBirth = (NSString *)interlocutorOfBirth;
    interlocutor.age = (NSString *)age;
    interlocutor.location = (NSString *)location;
    interlocutor.gender = (NSString *)gender;
    interlocutor.online = (NSString *)online;
    interlocutor.userData = (NSMutableDictionary *)fireInterlocutor;
    interlocutor.parameters = (NSMutableDictionary *)parameters;
    interlocutor.photos = (NSMutableArray *)photos;
    
    return interlocutor;
}

@end
