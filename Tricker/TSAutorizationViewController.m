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
@property (assign, nonatomic) NSInteger topSignInButton;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

#pragma mark - configure controller

- (void)configureController
{
    CGRect frame = CGRectMake(22, self.view.frame.size.height - 61, self.view.frame.size.width - 44, 39);
    _signInButton = [[UIButton alloc] init];
    _signInButton.frame = frame;
    _signInButton.backgroundColor = LIGHT_GRAY_COLOR;
    [_signInButton setTitle:@"Войти" forState:UIControlStateNormal];
    _signInButton.layer.cornerRadius = 19.5f;
    [_signInButton addTarget:self action:@selector(signIn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_signInButton];
    
    if (IS_IPHONE_4) {
        self.topSignInButton = 215;
    } else if (IS_IPHONE_5) {
        self.topSignInButton = 300;
    } else if (IS_IPHONE_6) {
        self.topSignInButton = 350;
    } else if (IS_IPHONE_6_PLUS) {
        self.topSignInButton = 450;
    } else if (IS_IPAD_2) {
        self.topSignInButton = 700;
    } else if (IS_IPAD_PRO) {
        self.topSignInButton = 930;
    }
}

#pragma mark - Actions

- (void)signIn
{
    if ([[TSReachability sharedReachability] verificationInternetConnection]) {
        if (![self.emailTextField.text isEqualToString:@""] && self.passwordTextField.text.length > 5) {
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
    [TSAlertController sharedAlertController:@"Сброс пароля!!!\nВведите адрес электронной почты. На который будет отправленно письмо с инструкцией по восстановлению доступа к аккаунту" size:17];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Електронная почта";
        textField.secureTextEntry = YES;
        self.recoverPasswordTextField = textField;
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Отменить"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         
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
    [cancel setValue:[UIColor blackColor] forKey:@"titleTextColor"];
    [okAction setValue:[UIColor blackColor] forKey:@"titleTextColor"];
    [alertController addAction:cancel];
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
    
    [UIView animateWithDuration:0.35f animations:^{
        CGRect frame = CGRectMake(22, self.topSignInButton, self.view.frame.size.width - 44, 39);
        _signInButton.frame = frame;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    [UIView animateWithDuration:0.35f animations:^{
        CGRect frame = CGRectMake(22, self.view.frame.size.height - 61, self.view.frame.size.width - 44, 39);
        _signInButton.frame = frame;
    }];
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
