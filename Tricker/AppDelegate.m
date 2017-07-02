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
#import "TSFireImage.h"
#import "TSTrickerPrefixHeader.pch"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import <GGLCore/GGLCore.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@import GoogleMobileAds;

//#import <Appodeal/Appodeal.h>
//#import <GoogleMaps/GoogleMaps.h>
//#import <VKSdk.h>

NSString * AppDelegateStatusUserNotificatoin = @"AppDelegateStatusUserNotificatoin";

@import Firebase;
@import FirebaseAuth;
@import FirebaseStorage;
@import FirebaseDatabase;

@interface AppDelegate () <GIDSignInDelegate>

@property (strong, nonatomic) TSFireUser *fireUser;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) GIDGoogleUser *googleUser;
@property (strong, nonatomic) UIStoryboard *storyBoard;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    self.storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    if (token) {
        [self openTabBarController];
    } else {
        TSSocialNetworkLoginViewController *loginController = [self.storyBoard instantiateViewControllerWithIdentifier:@"TSSocialNetworkLoginViewController"];
        self.window.rootViewController = loginController;
    }
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    [FIRApp configure];
    
    [GADMobileAds configureWithApplicationID:API_KEY_ADMOB];
    
//    [GMSServices provideAPIKey:API_KEY_GOOGLE_MAPS];
    
//    [Appodeal initializeWithApiKey:API_KEY_APPODEAL types:(AppodealAdType)AppodealAdTypeRewardedVideo | AppodealAdTypeInterstitial];
    
    NSError* configureError;
    [[GGLContext sharedInstance] configureWithError: &configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
    [GIDSignIn sharedInstance].delegate = self;
    
    //в случае креша, в базу отправляются данные offline об отсутствии пользователя в сети
    
    NSSetUncaughtExceptionHandler(&HandleException);
    
    struct sigaction signalAction;
    memset(&signalAction, 0, sizeof(signalAction));
    signalAction.sa_handler = &HandleSignal;
    
    sigaction(SIGABRT, &signalAction, NULL);
    sigaction(SIGILL, &signalAction, NULL);
    sigaction(SIGBUS, &signalAction, NULL);
    
    return YES;
}

void HandleException(NSException *exception) {
    NSLog(@"App crashing with exception: %@", [exception callStackSymbols]);
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateStatusUserNotificatoin object:@"offline"];
}

void HandleSignal(int signal) {
    NSLog(@"We received a signal: %d", signal);
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateStatusUserNotificatoin object:@"offline"];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[url scheme] isEqualToString:@"com.googleusercontent.apps.851257023912-5ocemga5kbbkep2ful306ipstauicedc"]) {
        return [[GIDSignIn sharedInstance] handleURL:url
                                   sourceApplication:sourceApplication
                                          annotation:annotation];
    } else {
        return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url
                                                    sourceApplication:sourceApplication annotation:annotation];
//        return [VKSdk processOpenURL:url fromApplication:sourceApplication];
    }
    return YES;
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSDKAppEvents activateApp];
}

#pragma mark - Google autorization

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error
{
    if (error == nil) {
        self.googleUser = user;
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
        
        if (!token) {
            GIDAuthentication *authentication = user.authentication;
            FIRAuthCredential *credential = [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
                                                                             accessToken:authentication.accessToken];
            [[FIRAuth auth] signInWithCredential:credential
                                      completion:^(FIRUser *user, NSError *error) {
                                          
                                          if (!error) {
                                              if (user.uid) {
                                                  NSString *token = user.uid;
                                                  [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
                                                  [[NSUserDefaults standardUserDefaults] synchronize];
                                                  [self openTabBarController];
                                              } else {
                                                  NSString *accessToken = authentication.accessToken;
                                                  
                                                  if (accessToken) {
                                                      NSString *imagePath = [NSString stringWithFormat:@"%@/avatar",
                                                                             [FIRAuth auth].currentUser.uid];
                                                      NSString *userID = user.uid;
                                                      NSString *name = user.displayName;
                                                      NSString *dateOfBirth = @"";
                                                      NSString *location = @"";
                                                      NSString *gender = @"";
                                                      NSString *age = @"";
                                                      NSString *online = @"";
                                                      NSString *stringPhoto = nil;
                                                      if (self.googleUser.profile.hasImage) {
                                                          stringPhoto = [[self.googleUser.profile imageURLWithDimension:600] absoluteString];
                                                      }
                                                      NSMutableDictionary *userData = [NSMutableDictionary dictionary];
                                                      [userData setObject:userID forKey:@"userID"];
                                                      [userData setObject:name forKey:@"displayName"];
                                                      [userData setObject:dateOfBirth forKey:@"dateOfBirth"];
                                                      [userData setObject:location forKey:@"location"];
                                                      [userData setObject:gender forKey:@"gender"];
                                                      [userData setObject:age forKey:@"age"];
                                                      [userData setObject:online forKey:@"online"];
                                                      
                                                      NSData *avatarData = [NSData dataWithContentsOfURL:[NSURL URLWithString:stringPhoto]];
                                                      
                                                      TSFireImage *saveFireImage = [[TSFireImage alloc] init];
                                                      [saveFireImage saveAvatarInTheDatabase:avatarData byPath:imagePath dictParam:userData];
                                                      FIRUser *fireUser = [FIRAuth auth].currentUser;
                                                      FIRDatabaseReference *ref = [[FIRDatabase database] reference];
                                                      FIRStorageReference *storageRef = [[FIRStorage storage] reference];
                                                      FIRStorageReference *imagesRef = [storageRef child:imagePath];
                                                      FIRStorageMetadata *metadata = [FIRStorageMetadata new];
                                                      metadata.contentType = @"image/jpeg";
                                                      
                                                      [[storageRef child:imagePath] putData:avatarData metadata:metadata
                                                                                 completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
                                                                                     if (error) {
                                                                                         NSLog(@"Error uploading: %@", error);
                                                                                     }
                                                                                     [imagesRef downloadURLWithCompletion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
                                                                                         NSString *photoURL = [NSString stringWithFormat:@"%@", URL];
                                                                                         [userData setObject:photoURL forKey:@"photoURL"];
                                                                                         [[[[[ref child:@"dataBase"] child:@"users"] child:fireUser.uid] child:@"userData"] setValue:userData];
                                                                                         [self openTabBarController];
                                                                                     }];
                                                                                 }];
                                                      NSString *token = user.uid;
                                                      [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
                                                      [[NSUserDefaults standardUserDefaults] synchronize];
                                                  }
                                              }
                                          } else {
                                              NSLog(@"Error %@", error.localizedDescription);
                                          }
                                      }];
        }
        NSLog(@"%@", error.localizedDescription);
    }
}

- (void)openTabBarController
{
    TSTabBarViewController *controller = [self.storyBoard instantiateViewControllerWithIdentifier:@"TSTabBarViewController"];
    self.window.rootViewController = controller;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateStatusUserNotificatoin object:@"offline"];
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateStatusUserNotificatoin object:@"offline"];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateStatusUserNotificatoin object:@"online"];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateStatusUserNotificatoin object:@"offline"];
}


@end
