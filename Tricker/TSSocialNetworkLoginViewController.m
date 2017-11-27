//
//  TSSocialNetworkLoginViewController.m
//  Tricker
//
//  Created by Mac on 05.11.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "TSSocialNetworkLoginViewController.h"
#import "TSTabBarViewController.h"
#import "TSRegistrationViewController.h"
#import "TSFacebookManager.h"
#import "TSFireImage.h"
#import "TSReachability.h"
#import "TSAlertController.h"
#import "TSTrickerPrefixHeader.pch"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import <VKSdk.h>

//#import <JWT.h>

@import Firebase;
@import FirebaseAuth;
@import FirebaseStorage;
@import FirebaseDatabase;

@interface TSSocialNetworkLoginViewController () <FBSDKLoginButtonDelegate, GIDSignInUIDelegate, TSFireImageDalegate> //VKSdkDelegate, VKSdkUIDelegate,

@property (strong, nonatomic) IBOutlet FBSDKLoginButton *loginButton;
@property (weak, nonatomic) IBOutlet GIDSignInButton *signInButton;

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) FIRStorageReference *storageRef;

@property (strong, nonatomic) NSArray *scope;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoTopLayoutConstraint;
@property (strong, nonatomic) UIView *modalView;

@end

@implementation TSSocialNetworkLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ref = [[FIRDatabase database] reference];
    self.storageRef = [[FIRStorage storage] reference];
    [self configureController];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (IS_IPHONE_4) {
            self.logoTopLayoutConstraint.constant = 45;
        } else if (IS_IPHONE_5) {
            self.logoTopLayoutConstraint.constant = 85;
        } else if (IS_IPHONE_6) {
            self.logoTopLayoutConstraint.constant = 100;
        } else if (IS_IPHONE_6_PLUS) {
            self.logoTopLayoutConstraint.constant = 110;
        }
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.logoTopLayoutConstraint.constant = 120;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)configureController
{
    self.loginButton = [[FBSDKLoginButton alloc] init];
    self.loginButton.hidden = YES;
    [self.view addSubview:self.loginButton];
    self.loginButton.delegate = self;
    
    [GIDSignIn sharedInstance].uiDelegate = self;
    [[GIDSignIn sharedInstance] signInSilently];
    
    VKSdk *sdkInstance = [VKSdk initializeWithAppId:APP_ID_VK];
//
    [sdkInstance registerDelegate:self];
    [sdkInstance setUiDelegate:self];
    
    self.scope = @[@"friends", @"email"];
    
    [VKSdk wakeUpSession:self.scope completeBlock:^(VKAuthorizationState state, NSError *error) {
        if (state == VKAuthorizationAuthorized) {
            NSLog(@"state %lu", (unsigned long)state);
        } else {
            NSLog(@"err %@", error.localizedDescription);
        }
    }];
}


#pragma mark - Facebook autorization


- (IBAction)facebookButtonTouchUpInside:(id)sender
{
    if ([self verificationInternetConnecting]) {
        [self.loginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
              error:(NSError *)error
{
    if (result.isCancelled == YES) {
        return;
    }
    NSString *tokenFB = [[FBSDKAccessToken currentAccessToken] tokenString];
    
    if (tokenFB) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                           parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (error) {
                 NSLog(@"Error %@", error);
             }
         }];
    } else {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logInWithReadPermissions:@[@"public_profile"]
                     fromViewController:self
                                handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                    if (error) {
                                        NSLog(@"Process error");
                                    } else if (result.isCancelled) {
                                        NSLog(@"Cancelled");
                                        return;
                                    } else {
                                        NSLog(@"Logged in");
                                    }
                                }];
        
    }
    
    FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                     credentialWithAccessToken:[FBSDKAccessToken currentAccessToken].tokenString];
    [[FIRAuth auth] signInWithCredential:credential
                              completion:^(FIRUser *user, NSError *error) {
                                  [self saveUserToFirebase:user];
                              }];
}

- (void)saveUserToFirebase:(FIRUser *)user
{
    NSString *token = user.uid;
    if (token) {
        [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self openTabBarcontroller];
    } else {
        [[TSFacebookManager sharedManager] requestUserDataTheServerFacebook:^(NSDictionary *dictionaryValues) {
            
            NSMutableDictionary *userData = [NSMutableDictionary dictionary];
            NSString *stringPhoto =
            [[[dictionaryValues objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
            NSString *imagePath = [NSString stringWithFormat:@"%@/%lld.jpg", [FIRAuth auth].currentUser.uid, (long long)([NSDate date].timeIntervalSince1970 * 1000.0)];
            NSString *userID = user.uid;
            NSString *name = user.displayName;
            NSString *dateOfBirth = @"";
            NSString *location = @"";
            NSString *gender = @"";
            NSString *age = @"";
            NSString *online = @"";
            NSString *blocked = @"";
            
            [userData setObject:userID forKey:@"userID"];
            [userData setObject:name forKey:@"displayName"];
            [userData setObject:dateOfBirth forKey:@"dateOfBirth"];
            [userData setObject:location forKey:@"location"];
            [userData setObject:gender forKey:@"gender"];
            [userData setObject:age forKey:@"age"];
            [userData setObject:online forKey:@"online"];
            [userData setObject:blocked forKey:@"blocked"];
            
            NSData *avatarData = [NSData dataWithContentsOfURL:[NSURL URLWithString:stringPhoto]];
            TSFireImage *fireImage = [[TSFireImage alloc] init];
            fireImage.delegate = self;
            [fireImage saveAvatarInTheDatabase:avatarData
                                        byPath:imagePath dictParam:userData];
        }];
        NSString *token = user.uid;
        [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - Autorization Google

- (IBAction)gPlusButtonTouchUpInside:(id)sender
{
    [[GIDSignIn sharedInstance] signIn];
}

- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error
{
    
}

- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController
{
    if ([self verificationInternetConnecting]) {
        [self presentViewController:viewController animated:YES completion:nil];
    }
}

- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error
{
    
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    
}

- (void)openTabBarcontroller
{
    TSTabBarViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"TSTabBarViewController"];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)deleteModalView
{
    NSInteger width = self.view.frame.size.width;
    NSInteger height = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         _modalView.frame = CGRectMake(width / 4, height + 100, (width / 4) - width, (height / 2) - height);
                     }];
}



#pragma mark - VK autorization

- (IBAction)vkButtonTouchUpInside:(id)sender
{
    [VKSdk authorize:self.scope];
}

- (void)vkSdkAccessAuthorizationFinishedWithResult:(VKAuthorizationResult *)result
{
    if (result.token) {
        
        VKRequest *user = [[VKApi users] get:@{VK_API_USER_IDS:result.token.userId}];
        
        __block NSString *nameVK = nil;
        __block NSString *photoURL = nil;
        __block NSString *customToken = result.token.accessToken;
        
        [user executeWithResultBlock:^(VKResponse *response) {
            
            NSDictionary *dictionary = [response.json objectAtIndex:0];

            nameVK = [NSString stringWithFormat:@"%@ %@", [dictionary objectForKey:@"first_name"], [dictionary objectForKey:@"last_name"]];
            
            /// тут должен быть кастомный токен
            
            NSString *firstSecret = @"first";
            NSArray *manySecrets = @[@"second", @"third", @"forty two"];
            // translate to data
            NSArray *manySecretsData = @[];
            for (NSString *secret in manySecrets) {
                NSData *secretData = [JWTBase64Coder dataWithBase64UrlEncodedString:secret];
                if (secret) {
                    manySecretsData = [manySecretsData arrayByAddingObject:secretData];
                }
            }
            
            NSString *algorithmName = JWTAlgorithmNameHS384;
            
            id <JWTAlgorithmDataHolderProtocol> firstHolder = [JWTAlgorithmHSFamilyDataHolder new].algorithmName(algorithmName).secret(firstSecret);
            
            JWTAlgorithmDataHolderChain *chain = [JWTAlgorithmDataHolderChain chainWithHolder:firstHolder];
            
            NSLog(@"chain has: %@", chain.debugDescription);
            
            JWTAlgorithmDataHolderChain *expandedChain = [chain chainByPopulatingAlgorithm:firstHolder.currentAlgorithm withManySecretData:manySecretsData];
            
            NSLog(@"expanded chain has: %@", expandedChain.debugDescription);
            
            
            [[FIRAuth auth] signInWithCustomToken:customToken
                                       completion:^(FIRUser *_Nullable user,
                                                    NSError *_Nullable error) {
                                           // ...
                                           NSLog(@"user %@", user.description);
                                           NSLog(@"error %@", error.localizedDescription);
                                       }];
            
            NSLog(@"Json result: %@", response.json);
        } errorBlock:^(NSError * error) {
            if (error.code != VK_API_ERROR) {
                [error.vkError.request repeat];
            } else {
                NSLog(@"VK error: %@", error);
            }
        }];
        
        VKRequest *photoRequest = [VKRequest requestWithMethod:@"photos.get" parameters:@{VK_API_USER_IDS:result.token.userId, VK_API_ALBUM_ID:@"profile", VK_API_PHOTO:@"photo"}];
        [photoRequest executeWithResultBlock:^(VKResponse *response) {
            
            NSArray *photos = [response.json objectForKey:@"items"];
            NSDictionary *dictionary = [photos lastObject];
            NSString *maxURL = [dictionary objectForKey:@"photo_604"];
            NSString *minURL = [dictionary objectForKey:@"photo_130"];
            
            if (maxURL) {
                photoURL = maxURL;
            } else {
                photoURL = minURL;
            }
            
            
            NSLog(@"Json result photo: %@", response.json);
        } errorBlock:^(NSError *error) {
            NSLog(@"VK error photo: %@", error);
        }];
        
//        [[[[[self.ref child:@"dataBase"] child:@"users"] child:user.uid] child:@"userData"] setValue:userData];

//        [self openTabBarcontroller];
        
        NSLog(@"result %lu", (unsigned long)result);
    } else if (result.error) {
        NSLog(@"result %lu", (unsigned long)result);
    }
}


- (void)vkSdkShouldPresentViewController:(UIViewController *)controller
{
    [self presentViewController:controller animated:YES completion:nil];
}


- (void)vkSdkUserAuthorizationFailed
{
    
}


- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError
{
    
}




#pragma mark - Reachability


- (BOOL)verificationInternetConnecting
{
    BOOL verification;
    if ([[TSReachability sharedReachability] verificationInternetConnection]) {
        verification = YES;
    } else {
        verification = NO;
        TSAlertController *alertController =
        [TSAlertController noInternetConnection:@"Проверьте интернет соединение..."];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    return verification;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
