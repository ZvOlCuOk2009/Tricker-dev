//
//  TSPhotoAndNameViewController.m
//  Tricker
//
//  Created by Mac on 08.11.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "TSPhotoAndNameViewController.h"
#import "TSRegistrationViewController.h"
#import "TSTabBarViewController.h"
#import "TSFireImage.h"
#import "TSReachability.h"
#import "TSAlertController.h"
#import "UIAlertController+TSAlertController.h"
#import "TSTrickerPrefixHeader.pch"

@import Firebase;
@import FirebaseAuth;
@import FirebaseStorage;
@import FirebaseDatabase;

@interface TSPhotoAndNameViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIImage *image;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *authButton;

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) FIRStorageReference *storageRef;

@end

@implementation TSPhotoAndNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ref = [[FIRDatabase database] reference];
    self.storageRef = [[FIRStorage storage] reference];
    self.nameTextField.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification object:nil];
    [self configureController];
}

- (void)viewDidLayoutSubviews
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSInteger value = self.view.frame.size.width / 2;
        CGRect recr = CGRectMake(value / 2, self.view.frame.size.height / 4, value, value);
        [self.cameraButton.layer setFrame:recr];
        NSInteger rad = value / 2;
        _cameraButton.layer.cornerRadius = rad;
        _cameraButton.clipsToBounds = YES;
        [_cameraButton setNeedsDisplay];
    }
    self.view.autoresizesSubviews = NO;
}

#pragma mark - configure controller

- (void)configureController
{
    self.title = @"Регистрация";
    self.ref = [[FIRDatabase database] reference];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    [backItem setImage:[UIImage imageNamed:@"back"]];
    [backItem setTintColor:DARK_GRAY_COLOR];
    self.navigationItem.leftBarButtonItem = backItem;
    [backItem setTarget:self];
    [backItem setAction:@selector(cancelInteraction)];
    
    self.cameraButton.layer.cornerRadius = 65;
    self.cameraButton.clipsToBounds = YES;
}

- (void)cancelInteraction
{
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0]
                                          animated:YES];
}

#pragma mark - Actions

- (IBAction)tapSelectCameraButton:(id)sender
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Выберите фото"
                                                                                 message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        NSInteger value = self.view.frame.size.width / 2;
        CGRect recr = CGRectMake(value / 2, self.view.frame.size.height / 4, value, value);
        UIView *view = [[UIView alloc] initWithFrame:recr];
        alertController.popoverPresentationController.sourceView = view;
        alertController.popoverPresentationController.sourceRect = view.frame;
        UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Камера"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self makePhoto];
                                                       }];
        
        UIAlertAction *galery = [UIAlertAction actionWithTitle:@"Галерея"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self selectPhoto];
                                                       }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Отменить"
                                                         style:UIAlertActionStyleDefault
                                                       handler:nil];
        
        UIView *subview = alertController.view.subviews.firstObject;
        UIView *alertContentView = subview.subviews.firstObject;
        alertContentView.backgroundColor = YELLOW_COLOR;
        alertContentView.layer.cornerRadius = 10;
        alertController.view.tintColor = DARK_GRAY_COLOR;
        
        NSMutableAttributedString *mutableAttrString = [[NSMutableAttributedString alloc] initWithString:@"Выберите фото"];
        [mutableAttrString addAttribute:NSFontAttributeName
                                  value:[UIFont systemFontOfSize:20.0]
                                  range:NSMakeRange(0, 13)];
        [alertController setValue:mutableAttrString forKey:@"attributedTitle"];
        
        [alertController addAction:camera];
        [alertController addAction:galery];
        [alertController addAction:cancel];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Выберите фото"
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Камера"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self makePhoto];
                                                       }];
        
        UIAlertAction *galery = [UIAlertAction actionWithTitle:@"Галерея"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self selectPhoto];
                                                       }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Отменить"
                                                         style:UIAlertActionStyleDefault
                                                       handler:nil];
        
        UIView *subview = alertController.view.subviews.firstObject;
        UIView *alertContentView = subview.subviews.firstObject;
        alertContentView.backgroundColor = YELLOW_COLOR;
        alertContentView.layer.cornerRadius = 10;
        alertController.view.tintColor = DARK_GRAY_COLOR;
        
        NSMutableAttributedString *mutableAttrString = [[NSMutableAttributedString alloc] initWithString:@"Выберите фото"];
        [mutableAttrString addAttribute:NSFontAttributeName
                                  value:[UIFont systemFontOfSize:20.0]
                                  range:NSMakeRange(0, 13)];
        [alertController setValue:mutableAttrString forKey:@"attributedTitle"];
        
        [alertController addAction:camera];
        [alertController addAction:galery];
        [alertController addAction:cancel];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)makePhoto {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.navigationBar.barStyle = UIBarStyleBlack;
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)selectPhoto {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.navigationBar.barStyle = UIBarStyleBlack;
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    } else {
        self.image = [info objectForKey:UIImagePickerControllerEditedImage];
    }
    [self.cameraButton setImage:self.image forState:UIControlStateNormal];
}

- (IBAction)saveUserButton:(id)sender
{
    if ([[TSReachability sharedReachability] verificationInternetConnection]) {
        if (![self.nameTextField.text isEqualToString:@""]) {
            
            NSString *email = self.email;
            NSString *password = self.password;
            NSString *displayName = self.nameTextField.text;
            
            [[FIRAuth auth] createUserWithEmail:email
                                       password:password
                                     completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
                                         if (!error) {
                                             
                                             if (user.uid) {
                                                 
                                                 NSString *dateOfBirth = @"";
                                                 NSString *location = @"";
                                                 NSString *photoURL = @"";
                                                 NSString *gender = @"";
                                                 NSString *age = @"";
                                                 NSString *online = @"";
                                                 
                                                 NSData *imageData = UIImageJPEGRepresentation(self.image, 0.8);
                                                 
                                                 NSString *imagePath = [NSString stringWithFormat:@"%@/%lld.jpg", user.uid, (long long)([NSDate date].timeIntervalSince1970 * 1000.0)];
                                                 
                                                 NSMutableDictionary *userData = [NSMutableDictionary dictionary];
                                                 
                                                 [userData setObject:user.uid forKey:@"userID"];
                                                 [userData setObject:displayName forKey:@"displayName"];
                                                 [userData setObject:dateOfBirth forKey:@"dateOfBirth"];
                                                 [userData setObject:photoURL forKey:@"photoURL"];
                                                 [userData setObject:location forKey:@"location"];
                                                 [userData setObject:gender forKey:@"gender"];
                                                 [userData setObject:age forKey:@"age"];
                                                 [userData setObject:online forKey:@"online"];
                                                 
                                                 FIRStorageReference *imagesRef = [self.storageRef child:imagePath];
                                                 FIRStorageMetadata *metadata = [FIRStorageMetadata new];
                                                 metadata.contentType = @"image/jpeg";
                                                 
                                                 [[self.storageRef child:imagePath] putData:imageData metadata:metadata
                                                                                 completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
                                                                                     
                                                                                     if (error) {
                                                                                         NSLog(@"Error uploading: %@", error);
                                                                                     }
                                                                                     
                                                                                     [imagesRef downloadURLWithCompletion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
                                                                                         
                                                                                         NSString *photoURL = [NSString stringWithFormat:@"%@", URL];
                                                                                         
                                                                                         [userData setObject:photoURL forKey:@"photoURL"];
                                                                                         
                                                                                         [[[[[self.ref child:@"dataBase"] child:@"users"] child:user.uid] child:@"userData"] setValue:userData];
                                                                                         
                                                                                         NSString *token = user.uid;
                                                                                         
                                                                                         [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
                                                                                         [[NSUserDefaults standardUserDefaults] synchronize];
                                                                                         
                                                                                         TSTabBarViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"TSTabBarViewController"];
                                                                                         [self presentViewController:controller animated:YES completion:nil];
                                                                                     }];
                                                                                 }];
                                             }
                                         } else {
                                             NSLog(@"Error - %@", error.localizedDescription);
                                             [self alertControllerEmail];
                                         }
                                     }];
        } else {
            [self alertControllerTextFieldNil];
        }
    } else {
        TSAlertController *alertController =
        [TSAlertController noInternetConnection:@"Проверьте интернет соединение..."];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (self.nameTextField.text.length > 1) {
        self.authButton.backgroundColor = DARK_GRAY_COLOR;
    } else {
        self.authButton.backgroundColor = LIGHT_GRAY_COLOR;
    }
    return YES;
}

#pragma mark - UIAlertControllers

- (void)alertControllerEmail
{
    TSAlertController *alertController = [TSAlertController sharedAlertController:@"Этот электронной адрес уже зарегистрирован в базе данных, или его не существует..."];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ок"
                                                   style:UIAlertActionStyleDefault
                                                 handler:nil];
    [alertController customizationAlertView:@"Этот электронной адрес уже зарегистрирован в базе данных, или его не существует..." byFont:20.f];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)alertControllerTextFieldNil
{
    TSAlertController *alertController =
    [TSAlertController sharedAlertController:@"Пожалуйста, заполните все текстовые поля для регистрации..."];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ок"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alertController customizationAlertView:@"Пожалуйста, заполните все текстовые поля для регистрации..."
                                     byFont:20.f];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Keyboard notification

- (void)keyboardDidShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.view.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, self.view.frame.origin.y - kbSize.height);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
