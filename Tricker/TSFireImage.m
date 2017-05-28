//
//  TSFireSaveImage.m
//  Tricker
//
//  Created by Mac on 25.12.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "TSFireImage.h"
#import "TSSocialNetworkLoginViewController.h"

NSString * TSFireImageOpenTabBarNotification = @"TSFireImageOpenTabBarNotification";

@import Firebase;
@import FirebaseAuth;
@import FirebaseStorage;

@interface TSFireImage () 

@end

@implementation TSFireImage

+ (TSFireImage *)sharedManager {
    
    static TSFireImage * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TSFireImage alloc] init];
    });
    return manager;
}

- (void)saveAvatarInTheDatabase:(NSData *)avatarDataByPath byPath:(NSString *)path
                      dictParam:(NSMutableDictionary *)params
{
    FIRUser *fireUser = [FIRAuth auth].currentUser;
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    FIRStorageReference *storageRef = [[FIRStorage storage] reference];
    FIRStorageReference *imagesRef = [storageRef child:path];
    FIRStorageMetadata *metadata = [FIRStorageMetadata new];
    metadata.contentType = @"image/jpeg";
    
    [[storageRef child:path] putData:avatarDataByPath metadata:metadata
                          completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
                                   if (error) {
                                       NSLog(@"Error uploading: %@", error);
                                   }
                                   [imagesRef downloadURLWithCompletion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
                                       NSString *photoURL = [NSString stringWithFormat:@"%@", URL];
                                       [params setObject:photoURL forKey:@"photoURL"];
                                       [[[[[ref child:@"dataBase"] child:@"users"] child:fireUser.uid] child:@"userData"] setValue:params];
                                       [self.delegate openTabBarcontroller];
                                   }];
                               }];
    
}

- (void)savePhotos:(NSData *)imageDataByPath byPath:(NSString *)path photos:(NSMutableArray *)photos
{
    FIRUser *fireUser = [FIRAuth auth].currentUser;
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    FIRStorageReference *storageRef = [[FIRStorage storage] reference];
    FIRStorageReference *imagesRef = [storageRef child:path];
    FIRStorageMetadata *metadata = [FIRStorageMetadata new];
    metadata.contentType = @"image/jpeg";
    
    [[storageRef child:path] putData:imageDataByPath metadata:metadata
                          completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
                              
                              if (error) {
                                  NSLog(@"Error uploading: %@", error);
                              }
                              [imagesRef downloadURLWithCompletion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
                                  
                                  NSString *photoURL = [NSString stringWithFormat:@"%@", URL];
                                  [photos addObject:photoURL];
                                  [[[[[ref child:@"dataBase"] child:@"users"] child:fireUser.uid] child:@"photos"] setValue:photos];
                              }];
                          }];
}

@end
