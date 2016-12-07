//
//  TSFacebookManager.h
//  Tricker
//
//  Created by Mac on 05.11.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface TSFacebookManager : NSObject <FBSDKAppInviteDialogDelegate>

+ (TSFacebookManager *)sharedManager;

- (void)requestUserDataTheServerFacebook:(void(^)(NSDictionary *dictioaryValues))success;
- (void)logOutUser;

@end
