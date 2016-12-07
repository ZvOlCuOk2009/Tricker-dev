//
//  TSFacebookManager.m
//  Tricker
//
//  Created by Mac on 05.11.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "TSFacebookManager.h"

#import <GoogleSignIn/GoogleSignIn.h>

@implementation TSFacebookManager


+ (TSFacebookManager *)sharedManager
{
    
    static TSFacebookManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TSFacebookManager alloc] init];
    });
    
    return manager;
    
}


#pragma mark - FBSDKGraphRequest


- (void)requestUserDataTheServerFacebook:(void(^)(NSDictionary *dictioaryValues))success
{
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me?fields=picture.height(500).width(500)"
                                       parameters:nil]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
     {
         if (!error) {
             if (success) {
                 success(result);
             }
         } else {
             NSLog(@"Error %@", [error localizedDescription]);
         }
     }];
    
}


#pragma mark - FBSDKAppInviteDialogDelegate


- (void)inviteUserFriendsTheServerFacebook:(UIViewController *)controller
{
    FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
    content.appLinkURL = [NSURL URLWithString:@"https://fb.me/1745102679089901"];
    [FBSDKAppInviteDialog showFromViewController:controller withContent:content delegate:self];
}


- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results {
    NSLog(@"results = %@", results);
}


- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error {
    NSLog(@"error = %@", error);
}


#pragma mark - log out


- (void)logOutUser
{
    
    [[[FBSDKLoginManager alloc] init] logOut];
    [FBSDKAccessToken setCurrentAccessToken:nil];
    [FBSDKProfile setCurrentProfile:nil];
    [[GIDSignIn sharedInstance] signOut];
}


@end
