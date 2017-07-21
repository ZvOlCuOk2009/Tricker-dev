//
//  TSAutorizationViewController.m
//  Tricker
//
//  Created by Mac on 08.11.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "TSAutorizationViewController.h"
#import "TSTabBarViewController.h"
#import "TSReachability.h"
#import "TSAlertController.h"
#import "TSTrickerPrefixHeader.pch"

@import FirebaseAuth;

@interface TSAutorizationViewController ()

@property (strong, nonatomic) UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) UITextField *recoverPasswordTextField;
@property (assign, nonatomic) NSInteger counter;


@end

@implementation TSAutorizationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

#pragma mark - configure controller

- (void)configureController
{
    self.counter = 0;
    CGRect frame = CGRectMake(22, 419, 276, 39);
    _signInButton = [[UIButton alloc] init];
    _signInButton.frame = frame;
    _signInButton.backgroundColor = LIGHT_GRAY_COLOR;
    [_signInButton setTitle:@"Войти" forState:UIControlStateNormal];
    _signInButton.layer.cornerRadius = 19.5f;
    [_signInButton addTarget:self action:@selector(signIn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_signInButton];
    NSLog(@"signIngButton %f %f %f %f", _signInButton.frame.origin.x, _signInButton.frame.origin.y, _signInButton.frame.size.width, _signInButton.frame.size.height);
}

#pragma mark - Actions

- (void)signIn
{
    if ([[TSReachability sharedReachability] verificationInternetConnection]) {
        if (![self.emailTextField.text isEqualToString:@""] && ![self.passwordTextField.text isEqualToString:@""]) {
            [self signInWithEmailAndPassword];
        }
    } else {
        TSAlertController *alertController =
        [TSAlertController noInternetConnection:@"Проверьте интернет соединение..."];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (IBAction)cancelActionButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)signIngActionButton:(id)sender
{
    if ([[TSReachability sharedReachability] verificationInternetConnection]) {
        if (![self.emailTextField.text isEqualToString:@""] && ![self.passwordTextField.text isEqualToString:@""]) {
            [self signInWithEmailAndPassword];
        }
    } else {
        TSAlertController *alertController =
        [TSAlertController noInternetConnection:@"Проверьте интернет соединение..."];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - reset password

- (IBAction)resetPassword:(id)sender
{
    TSAlertController *alertController =
    [TSAlertController sharedAlertController:@"Сброс пароля!!!" size:18];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Електронная почта";
        textField.secureTextEntry = YES;
        self.recoverPasswordTextField = textField;
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ок"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         
                                                         [[FIRAuth auth] sendPasswordResetWithEmail:self.recoverPasswordTextField.text
                                                                                         completion:^(NSError * _Nullable error) {
                                                                                             if (!error) {
                                                                                                 NSLog(@"сборос");
                                                                                                 [self showAlertRecovePassword:1];
                                                                                             } else {
                                                                                                 [self showAlertRecovePassword:0];
                                                                                                 NSLog(@"ошибка");
                                                                                             }
                                                                                         }];
                                                         
                                                     }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)showAlertRecovePassword:(NSInteger)result
{
    NSString *massage = nil;

    switch (result) {
        case 0:
            massage = @"Не существует пользователя с указанной электронной почтой...";
            break;
        case 1:
            massage = @"Письмо по сбросу пароля было отправленно на Вашу электронную почту!";
            break;
        default:
            break;
    }
    
    TSAlertController *alertController =
    [TSAlertController sharedAlertController:massage size:18];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ок"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [okAction setValue:[UIColor blackColor] forKey:@"titleTextColor"];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)signInWithEmailAndPassword
{
    [[FIRAuth auth] signInWithEmail:self.emailTextField.text
                           password:self.passwordTextField.text
                         completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
                             if (!error) {
                                 TSTabBarViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"TSTabBarViewController"];
                                 [self presentViewController:controller animated:YES completion:nil];
                                 NSString *token = user.uid;
                                 [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
                                 [[NSUserDefaults standardUserDefaults] synchronize];
                             } else {
                                 NSLog(@"Error %@", error.localizedDescription);
                                 [self alertController];
                             }
                         }];
}

- (void)alertController
{
    TSAlertController *alertController =
    [TSAlertController sharedAlertController:@"Неверный пароль или адрес электронной почты, попробуйте еще раз..." size:20];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ок"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
//    [alertController customizationAlertView:@"Неверный пароль или адрес электронной почты, попробуйте еще раз..."
//                                     byFont:20.f];
    [okAction setValue:[UIColor blackColor] forKey:@"titleTextColor"];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([[self checkAvailabilityAtAnEmail] isEqualToString:@"yes"] && [self.passwordTextField.text length] >= 5) {
        self.signInButton.backgroundColor = DARK_GRAY_COLOR;
    } else {
        self.signInButton.backgroundColor = LIGHT_GRAY_COLOR;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.emailTextField) {
        [textField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
    }
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    if (self.counter == 0) {
        NSInteger offset = 0;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            offset = - 210;
        } else {
            offset = - 310;
        }
        [UIView animateWithDuration:0.35f animations:^{
            
//            CGRect frame = CGRectOffset(self.signIngButton.frame, 0, + 200);
//            self.signIngButton.frame = frame;
//                CGRect fram = CGRectMake(22, 0, self.signIngButton.frame.size.width, self.signIngButton.frame.size.height);
//            CGRect frame = CGRectOffset(self.signIngButton.frame, 0, - 440);
            CGRect frame = CGRectMake(22, 215, 276, 39);
            _signInButton.frame = frame;
            NSLog(@"signIngButton %f %f %f %f", _signInButton.frame.origin.x, _signInButton.frame.origin.y, _signInButton.frame.size.width, _signInButton.frame.size.height);
        }];
        self.counter = 1;
    }
}

- (NSString *)checkAvailabilityAtAnEmail
{
    NSString *email = self.emailTextField.text;
    NSString *availabilityAT = nil;
    
    if ([email rangeOfString:@"@"].location == NSNotFound) {
        availabilityAT = @"no";
    } else {
        availabilityAT = @"yes";
    }
    return availabilityAT;
}


@end
