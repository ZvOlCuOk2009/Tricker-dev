//
//  AppDelegate.m
//  Tricker
//
//  Created by Mac on 05.11.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "AppDelegate.h"
#import "TSSocialNetworkLoginViewController.h"
#import "TSTabBarViewController.h"
#import "TSFireUser.h"
#import "TSTrickerPrefixHeader.pch"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import <GGLCore/GGLCore.h>
#import <GoogleMaps/GoogleMaps.h>
#import <VKSdk.h>

@import Firebase;
@import FirebaseAuth;
@import FirebaseDatabase;

@interface AppDelegate () <GIDSignInDelegate>

@property (strong, nonatomic) TSFireUser *fireUser;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) GIDGoogleUser *googleUser;
@property (strong, nonatomic) UIStoryboard *storyBoard;

@property (assign, nonatomic) NSInteger counter;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    self.storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    if (token) {
        
        TSTabBarViewController *tabBarController = [self.storyBoard instantiateViewControllerWithIdentifier:@"TSTabBarViewController"];
        self.window.rootViewController = tabBarController;
        
    } else {
        
        TSSocialNetworkLoginViewController *loginController = [self.storyBoard instantiateViewControllerWithIdentifier:@"TSSocialNetworkLoginViewController"];
        self.window.rootViewController = loginController;
        
    }
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    [FIRApp configure];
    
    [GMSServices provideAPIKey:API_KEY_GOOGLE_MAPS];
    
    NSError* configureError;
    [[GGLContext sharedInstance] configureWithError: &configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
    [GIDSignIn sharedInstance].delegate = self;
    
    self.ref = [[FIRDatabase database] reference];
        
    return YES;
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    if ([[url scheme] isEqualToString:@"com.googleusercontent.apps.851257023912-5ocemga5kbbkep2ful306ipstauicedc"]) {
        return [[GIDSignIn sharedInstance] handleURL:url
                                   sourceApplication:sourceApplication
                                          annotation:annotation];
    } else {
        
        [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url
                                                    sourceApplication:sourceApplication annotation:annotation];
        
        return [VKSdk processOpenURL:url fromApplication:sourceApplication];
    }
    
    return YES;
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSDKAppEvents activateApp];
    
    self.counter = 0;
    
    [self.ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        self.fireUser = [TSFireUser initWithSnapshot:snapshot];
        
        [self updateOnlineParameter:@"онлайн"];
    }];
    
}


- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error
{
    
    if (error == nil) {
        
        self.googleUser = user;
        
        GIDAuthentication *authentication = user.authentication;
        FIRAuthCredential *credential = [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
                                                                         accessToken:authentication.accessToken];
        [[FIRAuth auth] signInWithCredential:credential
                                  completion:^(FIRUser *user, NSError *error) {
                                      
                                      if (!error) {
                                          
                                          NSString *accessToken = authentication.accessToken;
                                          
                                          if (accessToken) {
                                              
                                              NSString *userID = user.uid;
                                              NSString *name = user.displayName;
                                              NSString *email = user.email;
                                              NSString *photoURL = nil;
                                              NSString *dateOfBirth = @"";
                                              NSString *location = @"";
                                              NSString *gender = @"";
                                              NSString *age = @"";
                                              NSString *online = @"";
                                              
                                              if (self.googleUser.profile.hasImage) {
                                                  photoURL = [[self.googleUser.profile imageURLWithDimension:600] absoluteString];
                                              }
                                              
                                              NSDictionary *userData = @{@"userID":userID,
                                                                         @"displayName":name,
                                                                         @"photoURL":photoURL,
                                                                         @"email":email,
                                                                         @"dateOfBirth":dateOfBirth,
                                                                         @"location":location,
                                                                         @"gender":gender,
                                                                         @"age":age,
                                                                         @"online":online};
                                              
                                              [[[[[self.ref child:@"dataBase"] child:@"users"] child:user.uid] child:@"userData"] setValue:userData];
                                              
                                              NSString *token = user.uid;
                                              
                                              [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
                                              [[NSUserDefaults standardUserDefaults] synchronize];
                                              
                                            
                                              TSTabBarViewController *controller = [self.storyBoard instantiateViewControllerWithIdentifier:@"TSTabBarViewController"];
                                              self.window.rootViewController = controller;
                                          }
                                          
                                      } else {
                                          
                                          NSLog(@"Error %@", error.localizedDescription);
                                      }
                                      
                                      
                                  }];
        
    } else {
        
        NSLog(@"%@", error.localizedDescription);
    }
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    self.counter = 0;
    [self updateOnlineParameter:@"оффлайн"];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    self.counter = 0;
    [self updateOnlineParameter:@"онлайн"];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    
    self.counter = 0;
    [self updateOnlineParameter:@"оффлайн"];
}


//обновление онлайн индикации


- (void)updateOnlineParameter:(NSString *)onlinePosition
{
    
    if (self.counter == 0) {
        
        FIRUser *user = [FIRAuth auth].currentUser;
        
        NSString *userID = self.fireUser.uid;
        NSString *name = self.fireUser.displayName;
        NSString *email = self.fireUser.email;
        NSString *photoURL = self.fireUser.photoURL;
        NSString *dateOfBirth = self.fireUser.dateOfBirth;
        NSString *location = self.fireUser.location;
        NSString *gender = self.fireUser.gender;
        NSString *age = self.fireUser.age;
        NSString *online = onlinePosition;
        
        NSDictionary *userData = @{@"userID":userID,
                                   @"displayName":name,
                                   @"photoURL":photoURL,
                                   @"email":email,
                                   @"dateOfBirth":dateOfBirth,
                                   @"location":location,
                                   @"gender":gender,
                                   @"age":age,
                                   @"online":online};
        
        [[[[[self.ref child:@"dataBase"] child:@"users"] child:user.uid] child:@"userData"] setValue:userData];
        
        self.counter = 1;
    }
    
}


@end
