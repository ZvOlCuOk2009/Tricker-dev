//
//  TSProfileTableViewController.m
//  Tricker
//
//  Created by Mac on 09.11.16.
//  Copyright © 2016 Mac. All rights reserved.
//

@import Photos;

#import "TSProfileTableViewController.h"
#import "AppDelegate.h"
#import "TSSocialNetworkLoginViewController.h"
#import "TSFacebookManager.h"
#import "TSFireImage.h"
#import "TSTabBarViewController.h"
#import "UIAlertController+TSAlertController.h"
#import "TSReachability.h"
#import "TSAlertController.h"
#import "TSIntroductionViewController.h"
#import "TSSVProgressHUD.h"
#import "TSTrickerPrefixHeader.pch"

@interface TSProfileTableViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) NSString *selectCity;
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (strong, nonatomic) UIBarButtonItem *doneButton;
@property (strong, nonatomic) TSFireUser *fireUser;

@property (assign, nonatomic) FIRDatabaseHandle handle;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) FIRStorageReference *storageRef;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateBirdthDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) NSString *selectData;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *valueYAvatarConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *valueWidthAvatarConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *valueHieghtAvatarConstraint;

@property (weak, nonatomic) IBOutlet UITextField *textFieldName;

@property (weak, nonatomic) IBOutlet UIButton *manButton;
@property (weak, nonatomic) IBOutlet UIButton *womanButton;
@property (strong, nonatomic) UIImage *pointImage;
@property (strong, nonatomic) UIImage *circleImage;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@property (strong, nonatomic) NSString *positionButtonGender;
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) NSString *countReviews;
@property (strong, nonatomic) NSString *countLikes;

@property (assign, nonatomic) NSInteger progressHUD;
@property (assign, nonatomic) NSInteger heightHeader;
@property (assign, nonatomic) NSInteger setUserOnlinePosition;
@property (assign, nonatomic) CGFloat fixSide;
@property (assign, nonatomic) CGFloat fixOffset;
@property (assign, nonatomic) CGFloat fixCornerRadius;
@property (assign, nonatomic) CGFloat correctingValue;
@property (strong, nonatomic) UIImageView *logo;
@property (assign, nonatomic) BOOL stateDatePicker;

@end

@implementation TSProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"TSProfileTableViewController");
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    self.tableView.backgroundView = imageView;
    
    //начальные парметры аватара
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (IS_IPHONE_4) {
            self.heightHeader = kHeightHeader_4_5;
            self.valueWidthAvatarConstraint.constant = kAvatarSide_4_5;
            self.valueHieghtAvatarConstraint.constant = kAvatarSide_4_5;
            self.avatarImageView.layer.cornerRadius = kAvatarSide_4_5 / 2;
            self.fixSide = kAvatarSide_4_5;
            self.fixOffset = kAvatarOffset_4_5;
            self.fixCornerRadius = kAvatarCornerRadius_4_5;
            self.correctingValue = 0;
        } else if (IS_IPHONE_5) {
            self.heightHeader = kHeightHeader_4_5;
            self.valueWidthAvatarConstraint.constant = kAvatarSide_4_5;
            self.valueHieghtAvatarConstraint.constant = kAvatarSide_4_5;
            self.avatarImageView.layer.cornerRadius = kAvatarSide_4_5 / 2;
            self.fixSide = kAvatarSide_4_5;
            self.fixOffset = kAvatarOffset_4_5;
            self.fixCornerRadius = kAvatarCornerRadius_4_5;
            self.correctingValue = 0;
        } else if (IS_IPHONE_6) {
            self.heightHeader = kHeightHeader_6;
            self.valueWidthAvatarConstraint.constant = kAvatarSide_6;
            self.valueHieghtAvatarConstraint.constant = kAvatarSide_6;
            self.avatarImageView.layer.cornerRadius = kAvatarSide_6 / 2;
            self.fixSide = kAvatarSide_6;
            self.fixOffset = kAvatarOffset_6;
            self.fixCornerRadius = kAvatarCornerRadius_6;
            self.correctingValue = 0;
        } else if (IS_IPHONE_6_PLUS) {
            self.heightHeader = kHeightHeader_6_S;
            self.valueWidthAvatarConstraint.constant = kAvatarSide_6_S;
            self.valueHieghtAvatarConstraint.constant = kAvatarSide_6_S;
            self.avatarImageView.layer.cornerRadius = kAvatarSide_6_S / 2;
            self.fixSide = kAvatarSide_6_S;
            self.fixOffset = kAvatarOffset_6_S;
            self.fixCornerRadius = kAvatarCornerRadius_6_S;
            self.correctingValue = 0;
        }
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (IS_IPAD_2) {
            self.heightHeader = kHeightHeaderIpad;
            self.valueWidthAvatarConstraint.constant = kAvatarSideIpad;
            self.valueHieghtAvatarConstraint.constant = kAvatarSideIpad;
            self.avatarImageView.layer.cornerRadius = kAvatarSideIpad / 2;
            self.fixSide = kAvatarSideIpad;
            self.fixOffset = kAvatarOffsetIpad;
            self.fixCornerRadius = kAvatarCornerRadiusIpad;
            self.correctingValue = -150;
        } else if (IS_IPAD_PRO) {
            self.heightHeader = kHeightHeaderIpadPro;
            self.valueWidthAvatarConstraint.constant = kAvatarSideIpadPro;
            self.valueHieghtAvatarConstraint.constant = kAvatarSideIpadPro;
            self.avatarImageView.layer.cornerRadius = kAvatarSideIpadPro / 2;
            self.fixSide = kAvatarSideIpadPro;
            self.fixOffset = kAvatarOffsetIpadPro;
            self.fixCornerRadius = kAvatarCornerRadiusIpadPro;
            self.correctingValue = -217;
        }
    }
    
    self.avatarImageView.clipsToBounds = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userStatusNotification:)
                                                 name:AppDelegateStatusUserNotificatoin
                                               object:nil];
    
    [self.tableView setSeparatorColor:DARK_GRAY_COLOR];
    
    self.progressHUD = 0;
    NSLog(@"avatarImageView x %f y %f wtdth %f height %f", self.avatarImageView.frame.origin.x, self.avatarImageView.frame.origin.y, self.avatarImageView.frame.size.width, self.avatarImageView.frame.size.height);
    UIImage *logoImage = [UIImage imageNamed:@"logo"];
    self.logo = [[UIImageView alloc] initWithImage:logoImage];
    self.logo.frame = CGRectMake((self.view.frame.size.width / 2) - (self.logo.frame.size.width / 2), 9, 150, 30);
    [self.navigationController.navigationBar addSubview:self.logo];
    self.setUserOnlinePosition = 1;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([[TSReachability sharedReachability] verificationInternetConnection]) {
        self.ref = [[FIRDatabase database] reference];
        self.storageRef = [[FIRStorage storage] reference];
        [self configureController];
    } else {
        TSAlertController *alertController =
        [TSAlertController noInternetConnection:@"Проверьте интернет соединение..."];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //[self.ref removeObserverWithHandle:self.handle];
    [self.ref removeAllObservers];
}

- (void)callIntroductionViewController
{
    TSIntroductionViewController *controller =
    [self.storyboard instantiateViewControllerWithIdentifier:@"TSIntroductionViewController"];
    controller.providesPresentationContextTransitionStyle = YES;
    controller.definesPresentationContext = YES;
    [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:controller animated:YES completion:nil];
    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark - configure the Controller

- (void)configureController
{
    if (self.progressHUD == 0) {
        [TSSVProgressHUD showProgressHud];
        ++self.progressHUD;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.handle = [self.ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            self.fireUser = [TSFireUser initWithSnapshot:snapshot];
            
            if (self.setUserOnlinePosition == 1) {
                [self updateDataUser:@"online"];
                ++self.setUserOnlinePosition;
            }
            UIImage *avatar = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.fireUser.photoURL]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.fireUser) {
                    [self setAvatarAndBackground:avatar];
                    [self setParametrUser:self.fireUser];
                    [TSSVProgressHUD dissmisProgressHud];
                }
            });
        }];
    });
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.pointImage = [UIImage imageNamed:@"click"];
    self.circleImage = [UIImage imageNamed:@"no_click"];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"dd.MM.yyyy"];
    
    self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Готово" style:UIBarButtonItemStylePlain
                                                      target:self action:@selector(doneAction)];
    [self.doneButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:@"System-light" size:20.0], NSFontAttributeName,
                                        [UIColor blackColor], NSForegroundColorAttributeName,
                                        nil] forState:UIControlStateNormal];
    self.navigationController.navigationBar.tintColor = DARK_GRAY_COLOR;
    self.stateDatePicker = NO;
}

//установка аватара и данных в лейблы

- (void)setAvatarAndBackground:(UIImage *)avatar
{
    self.avatarImageView.image = avatar;
    self.backgroundImageView.image = avatar;
    [TSSVProgressHUD dissmisProgressHud];
}

- (void)setParametrUser:(TSFireUser *)fireUser
{
    if ([fireUser.gender isEqualToString:@"man"]) {
        [self.manButton setImage:self.pointImage forState:UIControlStateNormal];
        [self.womanButton setImage:self.circleImage forState:UIControlStateNormal];
    } else if ([fireUser.gender isEqualToString:@"woman"]) {
        [self.manButton setImage:self.circleImage forState:UIControlStateNormal];
        [self.womanButton setImage:self.pointImage forState:UIControlStateNormal];
    }
    if (fireUser.dateOfBirth) {
        self.dateBirdthDayLabel.text = fireUser.dateOfBirth;
    }
    if (fireUser.age) {
        self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", fireUser.displayName, fireUser.age];
        self.textFieldName.placeholder = [NSString stringWithFormat:@"%@ %@", fireUser.displayName, fireUser.age];
    } else {
        self.nameLabel.text = fireUser.displayName;
        self.textFieldName.placeholder = fireUser.displayName;
    }
    [self setPostionLabelReviewsAndLikes:fireUser];
}

//установка лейблов просмотров и лайков

- (void)setPostionLabelReviewsAndLikes:(TSFireUser *)fireUser
{
//    self.countReviews = [NSString stringWithFormat:@"%ld", (long)[fireUser.reviews count]];
//    self.countLikes = [NSString stringWithFormat:@"%ld", (long)[fireUser.likes count]];
    
    self.countReviews = fireUser.countReviews;
    self.countLikes = fireUser.countLikes;
    NSString *nilString = @"0";
    if (!self.countReviews) {
        self.countReviews = nilString;
    }
    if (!self.countLikes) {
        self.countLikes = nilString;
    }
    
//    NSString *countReviewsSave = [self.userDefaults objectForKey:[NSString stringWithFormat:@"reviews/%@", fireUser.uid]];
//    NSString *countLikesSave = [self.userDefaults objectForKey:[NSString stringWithFormat:@"likes/%@", fireUser.uid]];

    NSString *countReviewsSave = [NSString stringWithFormat:@"%ld", (long)[fireUser.reviews count]];
    NSString *countLikesSave = [NSString stringWithFormat:@"%ld", (long)[fireUser.likes count]];
    
    if (!countReviewsSave) {
        countReviewsSave = @"0";
    }
    if (!countLikesSave) {
        countLikesSave = @"0";
    }
    NSString *differenceCountReviews = [NSString stringWithFormat:@"%ld", (long)[countReviewsSave integerValue] - (long)[self.countReviews integerValue]];
    NSString *differenceCountLikes = [NSString stringWithFormat:@"%ld", (long)[countLikesSave integerValue] - (long)[self.countLikes integerValue]];
    if ([differenceCountReviews integerValue] <= 0) {
        self.reviewsLabel.hidden = YES;
    } else {
        self.reviewsLabel.hidden = NO;
    }
    if ([differenceCountLikes integerValue] <= 0) {
        self.likesLabel.hidden = YES;
    } else {
        self.likesLabel.hidden = NO;
    }
    self.reviewsLabel.text = differenceCountReviews;
    self.likesLabel.text = differenceCountLikes;
}

#pragma mark - Actions

- (IBAction)actionUserBoyButton:(UIButton *)sender
{
    self.positionButtonGender = @"woman";
    if ([self.positionButtonGender isEqualToString:@"man"]) {
        [sender setImage:self.circleImage forState:UIControlStateNormal];
        [self.womanButton setImage:self.pointImage forState:UIControlStateNormal];
        self.positionButtonGender = @"woman";
    } else {
        [sender setImage:self.pointImage forState:UIControlStateNormal];
        [self.womanButton setImage:self.circleImage forState:UIControlStateNormal];
        self.positionButtonGender = @"man";
    }
}

- (IBAction)actionUserGirlButton:(UIButton *)sender
{
    self.positionButtonGender = @"man";
    
    if ([self.positionButtonGender isEqualToString:@"woman"]) {
        [sender setImage:self.circleImage forState:UIControlStateNormal];
        [self.manButton setImage:self.pointImage forState:UIControlStateNormal];
        self.positionButtonGender = @"man";
    } else {
        [sender setImage:self.pointImage forState:UIControlStateNormal];
        [self.manButton setImage:self.circleImage forState:UIControlStateNormal];
        self.positionButtonGender = @"woman";
    }
}

- (IBAction)changeAvatarActionButton:(id)sender
{
    TSAlertController *alertController = [TSAlertController sharedAlertController:@"Выберите фото"];
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Камера"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       [self addImage:UIImagePickerControllerSourceTypeCamera];
                                                   }];
    UIAlertAction *galery = [UIAlertAction actionWithTitle:@"Галерея"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       [self addImage:UIImagePickerControllerSourceTypePhotoLibrary];
                                                   }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Отменить"
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
    [alertController customizationAlertView:@"Выберите фото" byFont:20.f];
    [alertController addAction:camera];
    [alertController addAction:galery];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)addImage:(enum UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.navigationBar.barStyle = UIBarStyleBlack;
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = sourceType;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        UIImage *image = info[UIImagePickerControllerEditedImage];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
        NSString *imagePath = [NSString stringWithFormat:@"%@/avatar", [FIRAuth auth].currentUser.uid];
        NSMutableDictionary *userData = [NSMutableDictionary dictionary];
        [userData setObject:self.fireUser.uid forKey:@"userID"];
        [userData setObject:self.fireUser.displayName forKey:@"displayName"];
        [userData setObject:self.fireUser.dateOfBirth forKey:@"dateOfBirth"];
        [userData setObject:self.fireUser.photoURL forKey:@"photoURL"];
        [userData setObject:self.fireUser.location forKey:@"location"];
        [userData setObject:self.fireUser.gender forKey:@"gender"];
        [userData setObject:self.fireUser.age forKey:@"age"];
        [userData setObject:self.fireUser.online forKey:@"online"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            TSFireImage *fireImage = [[TSFireImage alloc] init];
            [fireImage saveAvatarInTheDatabase:imageData byPath:imagePath dictParam:userData];
        });
    });
}

#pragma mark - notification

- (void)userStatusNotification:(NSNotification *)notification
{
    [self updateDataUser:[notification object]];
}

//сохранение основных данных

- (IBAction)saveUserAtionButton:(id)sender
{
    [self updateDataUser:nil];
}

- (void)updateDataUser:(NSString *)userStatus
{
    NSString *userID = nil;
    NSString *name = nil;
    NSString *online = nil;
    NSString *gender = nil;
    NSString *photoURL = nil;
    NSString *dateOfBirth = nil;
    NSString *age = nil;
    NSString *location = nil;
    
    userID = self.fireUser.uid;
    name = self.fireUser.displayName;
    online = self.fireUser.online;
    photoURL = self.fireUser.photoURL;
    age = self.fireUser.age;
    
    if ([self.textFieldName.text length] > 0) {
        name = self.textFieldName.text;
    } else {
        name = self.fireUser.displayName;
    }
    
    if (self.positionButtonGender) {
        gender = self.positionButtonGender;
    } else {
        gender = self.fireUser.gender;
    }
    
    if (self.selectData) {
        dateOfBirth = self.selectData;
    } else {
        dateOfBirth = self.fireUser.dateOfBirth;
    }
    
    if ([self computationAge:dateOfBirth]) {
        age = [self computationAge:dateOfBirth];
    } else {
        dateOfBirth = self.fireUser.age;
    }
    
    if (self.selectCity) {
        location = self.selectCity;
    } else {
        location = self.fireUser.location;
    }
    
    if ([age length] == 0) {
        age = @"";
    }
    
    if ([gender length] == 0) {
        gender = @"";
    }
    
    if ([dateOfBirth length] == 0) {
        dateOfBirth = @"";
    }
    
    if ([location length] == 0) {
        location = @"";
    }
    
    if ([online length] == 0) {
        online = @"";
    }
    
    if ([userStatus isEqualToString:@"offline"]) {
        online = @"оффлайн";
    } else if ([userStatus isEqualToString:@"online"]) {
        online = @"онлайн";
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *userData = @{@"userID":userID,
                                   @"displayName":name,
                                   @"dateOfBirth":dateOfBirth,
                                   @"gender":gender,
                                   @"photoURL":photoURL,
                                   @"age":age,
                                   @"location":location,
                                   @"online":online};
        
        [[[[[self.ref child:@"dataBase"] child:@"users"] child:userID] child:@"userData"] setValue:userData];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressHUD = 0;
            [self configureController];
            self.textFieldName.text = @"";
        });
    });
}

//вычисление возраста

- (NSString *)computationAge:(NSString *)selectData
{
    NSDate *currentData = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSDate *convertDateOfBirth = [dateFormatter dateFromString:selectData];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *components = [calendar components:unitFlags fromDate:convertDateOfBirth
                                                 toDate:currentData options:0];
    NSInteger age;
    age = [components year];
    return [NSString stringWithFormat:@"%ld", (long)age];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return self.heightHeader;
    }
    if (indexPath.row == 9) {
        return kHeightCellButtonSaveAndOut;
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (IS_IPAD_2) {
            if (indexPath.row == 0) {
                return 300;
            }
        }
    }
    return kHeightCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 5 && self.stateDatePicker == NO) {
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ru_UA"];
        self.datePicker = [[UIDatePicker alloc] init];
        [self.datePicker setValue:DARK_GRAY_COLOR forKey:@"textColor"];
        self.datePicker.backgroundColor = LIGHT_YELLOW_COLOR;
        self.datePicker.locale = locale;
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
        if (self.datePicker.superview == nil)
        {
            [self.view.window addSubview: self.datePicker];
            self.view.window.backgroundColor = [UIColor whiteColor];
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            CGSize pickerSize = [self.datePicker sizeThatFits:CGSizeZero];
            CGRect startRect = CGRectMake(0.0,
                                          screenRect.origin.y + screenRect.size.height,
                                          pickerSize.width, pickerSize.height);
            self.datePicker.frame = startRect;
            CGRect pickerRect = CGRectMake(0.0, screenRect.origin.y + screenRect.size.height - pickerSize.height - 49,
                                           self.view.frame.size.width, self.datePicker.frame.size.height);
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            [UIView setAnimationDelegate:self];
            self.datePicker.frame = pickerRect;
            CGRect newFrame = self.tableView.frame;
            newFrame.size.height -= self.datePicker.frame.size.height;
            self.tableView.frame = newFrame;
            [UIView commitAnimations];
            [self.navigationItem setRightBarButtonItem:self.doneButton animated:YES];
            //жест
            self.tapGestureRecognizer =
            [[UITapGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(doneAction)];
            [self.view addGestureRecognizer:self.tapGestureRecognizer];
        }
        self.stateDatePicker = YES;
    }
    
    if (indexPath.row == 7) {
        NSString *sharedCountReviews = [NSString stringWithFormat:@"%ld",
                                        (long)[self.fireUser.reviews count]];
        if (!sharedCountReviews) {
            sharedCountReviews = @"0";
        }
        [[[[[self.ref child:@"dataBase"] child:@"users"] child:self.fireUser.uid] child:@"reviewsCount"] setValue:sharedCountReviews];
    }
    
    if (indexPath.row == 8) {
        NSString *sharedCountLikes = [NSString stringWithFormat:@"%ld",
                                        (long)[self.fireUser.likes count]];
        if (!sharedCountLikes) {
            sharedCountLikes = @"0";
        }
        [[[[[self.ref child:@"dataBase"] child:@"users"] child:self.fireUser.uid] child:@"likesCount"] setValue:sharedCountLikes];
    }
}

- (void)dateChanged:(UIDatePicker *)sender
{
    self.selectData = [self.dateFormatter stringFromDate:[sender date]];
    self.dateBirdthDayLabel.text = self.selectData;
}

//получение даты рождения

- (void)doneAction
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect endFrame = self.datePicker.frame;
    endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
    self.datePicker.frame = endFrame;
    [UIView commitAnimations];
    CGRect newFrame = self.tableView.frame;
    newFrame.size.height += self.datePicker.frame.size.height;
    self.tableView.frame = newFrame;
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationItem setRightBarButtonItems:nil animated:YES];
    self.stateDatePicker = NO;
    [self.view removeGestureRecognizer:self.tapGestureRecognizer];
}

- (void)slideDownDidStop
{
    [self.datePicker removeFromSuperview];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - change avatar frame when scrolling

//кадрирование аватара

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect scrollBounds = scrollView.bounds;
    scrollView.bounds = scrollBounds;
    CGFloat changeHeight = scrollBounds.origin.y + kHeightNavBar;
    CGFloat changeSide = self.fixSide - changeHeight;
    CGFloat changeDiameter = changeSide / 2;
    CGFloat correctionValue = (self.fixSide / 2) - changeDiameter;
    CGFloat offsetSizeWidth = self.fixOffset + correctionValue;
    CGFloat offsetSizeHeight = self.fixOffset + ((correctionValue * 2) - (changeHeight / 3));
    CGRect changeFrame = CGRectMake(offsetSizeWidth, offsetSizeHeight + self.correctingValue, changeSide, changeSide);
    
    self.avatarImageView.layer.cornerRadius = self.fixCornerRadius;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.frame = changeFrame;
    self.avatarImageView.layer.cornerRadius = changeDiameter;
    self.avatarImageView.hidden = NO;
    
    if (changeDiameter >= self.fixCornerRadius) {
        self.avatarImageView.frame = CGRectMake(self.fixOffset, self.fixOffset + self.correctingValue, self.fixSide, self.fixSide);
        self.avatarImageView.layer.cornerRadius = self.fixCornerRadius;
    } else if (changeDiameter <= 0) {
        self.avatarImageView.hidden = YES;
    }
    if (changeHeight < 0) {
        changeHeight = 1;
    }
    self.logo.frame = CGRectMake((self.view.frame.size.width / 2) - (self.logo.frame.size.width / 2), - (changeHeight / 4), self.logo.frame.size.width, self.logo.frame.size.height);
    self.logo.alpha = 4 / changeHeight;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
