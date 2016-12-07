//
//  TSAutorizationViewController.m
//  Tricker
//
//  Created by Mac on 08.11.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "TSAutorizationViewController.h"
#import "TSTabBarViewController.h"
#import "TSTrickerPrefixHeader.pch"

@import FirebaseAuth;

@interface TSAutorizationViewController ()

@property (weak, nonatomic) IBOutlet UIButton *signIngButton;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation TSAutorizationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureController];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


#pragma mark - configure controller


- (void)configureController
{
    self.counter = 0;
}


#pragma mark - Actions


- (IBAction)cancelActionButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)signIngActionButton:(id)sender
{
    if (![self.emailTextField.text isEqualToString:@""] && ![self.passwordTextField.text isEqualToString:@""]) {
        [self signInWithEmailAndPassword];
    }
}


- (void)signInWithEmailAndPassword
{
    
    [[FIRAuth auth] signInWithEmail:self.emailTextField.text
                           password:self.passwordTextField.text
                         completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
                             if (!error) {
                                 
                                 NSArray *provider = user.providerData;
                                 NSLog(@"provider = %@", provider.description);
                                 
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
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Invalid password or e-mail, try again..."
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       
                                                   }];
    
    [alertController addAction:action];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - UITextFieldDelegate


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if ([[self checkAvailabilityAtAnEmail] isEqualToString:@"yes"] && [self.passwordTextField.text length] >= 5) {
        self.signIngButton.backgroundColor = DARK_GRAY_COLOR;
    } else {
        self.signIngButton.backgroundColor = LIGHT_GRAY_COLOR;
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
        [UIView animateWithDuration:0.35f animations:^{
            
//            CGRect frame = CGRectOffset(self.signIngButton.frame, 0, + 200);
            CGRect frame = CGRectMake(22, 10, self.signIngButton.frame.size.width, self.signIngButton.frame.size.height);
            self.signIngButton.frame = frame;
        }];
        
        self.counter = 1;
    }
    
}




@end
