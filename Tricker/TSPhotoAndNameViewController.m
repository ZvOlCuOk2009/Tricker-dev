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
#import "TSTrickerPrefixHeader.pch"

@import Firebase;
@import FirebaseAuth;
@import FirebaseStorage;
@import FirebaseDatabase;

@interface TSPhotoAndNameViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIImage *image;

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) FIRStorageReference *storageRef;

@end

@implementation TSPhotoAndNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.ref = [[FIRDatabase database] reference];
    self.storageRef = [[FIRStorage storage] reference];
    
    [self configureController];
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
                                                   handler:^(UIAlertAction * _Nonnull action) {

                                                   }];
    
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
    
    self.image = [info objectForKey:UIImagePickerControllerEditedImage];
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
                                             
                                             //                                         [self alertControllerEmail];
                                         }
                                     }];
            
        } else {
            NSLog(@"Пустой текстфилд");
            //        [self alertControllerTextFieldNil];
        }
        
    } else {
        
        TSAlertController *alertController =
        [TSAlertController noInternetConnection:@"Проверьте интернет соединение..."];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


@end
