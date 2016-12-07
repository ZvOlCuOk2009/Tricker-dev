//
//  TSRegistrationViewController.m
//  Tricker
//
//  Created by Mac on 07.11.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "TSRegistrationViewController.h"
#import "TSPhotoAndNameViewController.h"
#import "TSTrickerPrefixHeader.pch"

@interface TSRegistrationViewController ()

@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation TSRegistrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureController];
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

        

- (IBAction)doneActionButton:(id)sender
{
    
    if ([[self checkAvailabilityAtAnEmail] isEqualToString:@"yes"] && ([self.passwordTextField.text length] >= 6))
    {
        TSPhotoAndNameViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"TSPhotoAndNameViewController"];
        controller.email = self.emailTextField.text;
        controller.password = self.passwordTextField.text;
        [self.navigationController pushViewController:controller animated:YES];
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




#pragma mark - UITextFieldDelegate


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if ([[self checkAvailabilityAtAnEmail] isEqualToString:@"yes"] && [self.passwordTextField.text length] >= 5) {
        self.doneButton.backgroundColor = DARK_GRAY_COLOR;
    } else {
        self.doneButton.backgroundColor = LIGHT_GRAY_COLOR;
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
        
        

#pragma mark - Notification keyboard


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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}


- (void)keyboardWillShow:(NSNotification *)notification {
    
    if (self.counter == 0) {
        [UIView animateWithDuration:0.35f animations:^{
            
            CGRect frame = CGRectOffset(self.doneButton.frame, 0, - 210);
            self.doneButton.frame = frame;
        }];
        
        self.counter = 1;
    }

}


- (void)keyboardWillHide:(NSNotification *)notification {
    
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
