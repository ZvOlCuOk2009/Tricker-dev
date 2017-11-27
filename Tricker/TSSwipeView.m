
//  TSSwipeView.m
//  Tricker
//
//  Created by Mac on 24.11.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "TSSwipeView.h"
#import "TSCardsViewController.h"
#import "TSChatViewController.h"
#import "TSTabBarViewController.h"
#import "TSViewCell.h"
#import "TSFireInterlocutor.h"
#import "TSPhotoView.h"
#import "TSLikeAndReviewSave.h"
#import "TSGetInterlocutorParameters.h"
#import "TSAlertController.h"
#import "TSTrickerPrefixHeader.pch"

#import <SVProgressHUD.h>
#import <MessageUI/MessageUI.h>

@import FirebaseDatabase;

NSInteger recognizerTransitionOnChatController;
NSInteger recognizerControllersCardsAndChat;

@interface TSSwipeView () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSArray *allKeys;

@property (strong, nonatomic) NSMutableArray *updateDataSource;
@property (strong, nonatomic) NSMutableArray *getParameters;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *backgroundTableView;

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) TSFireInterlocutor *fireInterlocutor;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@property (strong, nonatomic) TSPhotoView *photoView;
@property (strong, nonatomic) NSString *photosView;

@property (assign, nonatomic) NSInteger counter;

@end

@implementation TSSwipeView

- (void)drawRect:(CGRect)rect {
    
    [self awakeFromNib];
    self.dataSource = @[@"Ищу", @"Возраст", @"С целью", @"Рост", @"Вес", @"Фигура", @"Глаза", @"Волосы", @"Отношения", @"Дети", @"Доход", @"Образование", @"Жильё", @"Автомобиль", @"Отношение к курению", @"Алкоголь"];
    self.counter = 0;
    
    self.updateDataSource = [NSMutableArray array];
    self.getParameters = [NSMutableArray array];
    
    NSMutableArray *tempArrayDataSource = [NSMutableArray array];
    NSMutableArray *tempArrayGetParameters = [NSMutableArray array];
    
    for (int i = 0; i < 16; i++) {
        NSString *cap = @"";
        [tempArrayDataSource addObject:cap];
        [tempArrayGetParameters addObject:cap];
    }
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(handleSingleTap:)];
    self.tapGesture.delegate = self;
    self.tapGesture.enabled = NO;
    [self addGestureRecognizer:self.tapGesture];
    self.tableView.allowsSelection = NO;
    [self.tableView setShowsVerticalScrollIndicator:NO];
    self.allKeys = [self.parameterUser allKeys];
    
    //наполнение массивов заголовками и данными
    
    [tempArrayDataSource insertObject:@"Анкета" atIndex:0];
    [tempArrayGetParameters addObject:@""];
    
    for (int i = 0; i < [self.parameterUser count]; i++) {
        NSString *key = [self.allKeys objectAtIndex:i];
        NSString *shortKey = [key substringFromIndex:3];
        NSInteger index = [shortKey integerValue];
        NSString *parameter = [self.parameterUser objectForKey:key];
        
        if ([parameter isEqualToString:@"man"]) {
            parameter = @"Парня";
        } else if ([parameter isEqualToString:@"woman"]) {
            parameter = @"Девушку";
        } else if ([parameter isEqualToString:@"man woman"]) {
            parameter = @"Парня и девушку";
        }
        
        //добавление тайтлов и параметров в промежуточные массивы
        NSString *title = [self.dataSource objectAtIndex:index - 1];
        
        [tempArrayDataSource insertObject:title atIndex:index];
        [tempArrayGetParameters insertObject:parameter atIndex:index];
    }

    //добавление тайтлов и параметров в массивы по порядковым номерам
    NSInteger counterDSArray = 0;
    NSInteger counterParamArray = 0;
    
    for (NSString *title in tempArrayDataSource) {
        if (![title isEqualToString:@""]) {
            [self.updateDataSource addObject:title];
        }
        counterDSArray++;
    }
    
    for (NSString *parameter in tempArrayGetParameters) {
        if (![parameter isEqualToString:@""] || counterParamArray == 0) {
            [self.getParameters addObject:parameter];
        }
        counterParamArray++;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (IS_IPHONE_4) {
            self.photosView = kTSPhotoView;
        } else if (IS_IPHONE_5) {
            self.photosView = kTSPhotoView5;
        } else if (IS_IPHONE_6) {
            self.photosView = kTSPhotoView6;
        } else if (IS_IPHONE_6_PLUS) {
            self.photosView = kTSPhotoView_6_Plus;
        }
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (IS_IPAD_2) {
            self.photosView = kTSPhotoViewIpad;
        } else if (IS_IPAD_PRO) {
            self.photosView = kTSPhotoViewIpadPro;
        }
    }
    
    UIImage *chatImage = [UIImage imageNamed:@"chat"];
    UIImage *cancelViewImage = [UIImage imageNamed:@"cancel_view"];
    
    if (recognizerTransitionOnChatController == 0) {
        self.chatImageView.image = chatImage;
    } else {
        self.chatImageView.image = cancelViewImage;
    }
    
    //установка индикации онлайн
    if ([self.onlineState isEqualToString:@"оффлайн"]) {
        self.onlineView.backgroundColor = [UIColor redColor];
    } else if ([self.onlineState isEqualToString:@"онлайн"]) {
        self.onlineView.backgroundColor = [UIColor greenColor];
    }
}

- (void)setup {
   
    self.layer.cornerRadius = 10;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.33;
    self.layer.shadowOffset = CGSizeMake(0, 1.5);
    self.layer.shadowRadius = 7.0;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.layer.masksToBounds = YES;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}


+ (instancetype)initProfileView
{
    TSSwipeView *view = nil;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (IS_IPHONE_4) {
            view = [self initProfileViewNibBySizeDevice:view nameNib:@"TSSwipeView"
                                               frameNib:kTSSwipeViewFrame];
        } else if (IS_IPHONE_5) {
            view = [self initProfileViewNibBySizeDevice:view nameNib:@"TSSwipeView5"
                                               frameNib:kTSSwipeView5Frame];
        } else if (IS_IPHONE_6) {
            view = [self initProfileViewNibBySizeDevice:view nameNib:@"TSSwipeView6"
                                               frameNib:kTSSwipeView6Frame];
        } else if (IS_IPHONE_6_PLUS) {
            view = [self initProfileViewNibBySizeDevice:view nameNib:@"TSSwipeView6plus"
                                               frameNib:kTSSwipeView6PlusFrame];
        }
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (IS_IPAD_2) {
            view = [self initProfileViewNibBySizeDevice:view nameNib:@"TSSwipeViewIpad"
                                               frameNib:kTSSwipeViewIpadFrame];
        } else if (IS_IPAD_PRO) {
            view = [self initDetailViewNibBySizeDevice:view nameNib:@"TSSwipeViewIpadPro"
                                              frameNib:kTSSwipeViewIpadProFrame];
        }
    }
    return view;
}

+ (instancetype)initDetailView
{
    TSSwipeView *view = nil;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (IS_IPHONE_4) {
            view = [self initDetailViewNibBySizeDevice:view nameNib:@"TSDetailView"
                                              frameNib:kTSSwipeDetailViewFrame];
        } else if (IS_IPHONE_5) {
            view = [self initDetailViewNibBySizeDevice:view nameNib:@"TSDetailView5"
                                              frameNib:kTSSwipeDetailView5Frame];
        } else if (IS_IPHONE_6) {
            view = [self initDetailViewNibBySizeDevice:view nameNib:@"TSDetailView6"
                                              frameNib:kTSSwipeDetailView6Frame];
        } else if (IS_IPHONE_6_PLUS) {
            view = [self initDetailViewNibBySizeDevice:view nameNib:@"TSDetailView6plus"
                                              frameNib:kTSSwipeDetailView6PlusFrame];
        }
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (IS_IPAD_2) {
            view = [self initDetailViewNibBySizeDevice:view nameNib:@"TSDetailViewIpad"
                                              frameNib:kTSSwipeDetailViewIpadFrame];
        } else if (IS_IPAD_PRO) {
            view = [self initDetailViewNibBySizeDevice:view nameNib:@"TSDetailViewIpadPro"
                                              frameNib:kTSSwipeDetailViewIpadProFrame];
        }
    }
    return view;
}

#pragma mark - init nib

+ (TSSwipeView *)initProfileViewNibBySizeDevice:(TSSwipeView *)view nameNib:(NSString *)name frameNib:(CGRect)frame
{
    UINib *nib = [UINib nibWithNibName:name bundle:nil];
    view = [nib instantiateWithOwner:self options:nil][0];
    view.frame = frame;
    
    return view;
}

+ (TSSwipeView *)initDetailViewNibBySizeDevice:(TSSwipeView *)view nameNib:(NSString *)name frameNib:(CGRect)frame
{
    UINib *nib = [UINib nibWithNibName:name bundle:nil];
    view = [nib instantiateWithOwner:self options:nil][0];
    view.frame = frame;
    return view;
}

#pragma mark - Actions

- (IBAction)photoActionButton:(id)sender
{
    self.photoView = [[[NSBundle mainBundle] loadNibNamed:self.photosView
                                                    owner:self options:nil] firstObject];
    [self addSubview:self.photoView];
    [self.photoView setFrame:CGRectMake(0.0f, self.photoView.frame.size.height,
                                   self.photoView.frame.size.width, self.photoView.frame.size.height)];
    [UIView beginAnimations:@"animateView" context:nil];
    [UIView setAnimationDuration:0.3];
    [self.photoView setFrame:CGRectMake(0.0f, 0.0f,self.photoView.frame.size.width,self.photoView.frame.size.height)];
    [UIView commitAnimations];
    self.photoView.photos = self.photos;
    [self markReviewUserByRecognizer];
}

//разворот карточки на 180 градусов

- (IBAction)parametersActionButton:(id)sender
{
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromRight forView:self cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.35];
    [UIView commitAnimations];
    
    [self.tableView reloadData];
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.backgroundTableView.alpha = 1;
                         self.tableView.alpha = 1;
                     }];
    
    self.tapGesture.enabled = YES;
    [self markReviewUserByRecognizer];
}

- (IBAction)chatActionButton:(id)sender
{
    if (recognizerTransitionOnChatController == 2) {
        [UIView animateWithDuration:0.35
                              delay:0
             usingSpringWithDamping:0.7
              initialSpringVelocity:0.6
                            options:0
                         animations:^{
                             self.frame = CGRectMake(10, 1000, self.frame.size.width, self.frame.size.height);
                         } completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removeFromSuperview];
        });
        recognizerTransitionOnChatController = 0;
    } else {
        recognizerTransitionOnChatController = 1;
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:self.interlocutorUid forKey:@"intelocID"];
        [userDefault synchronize];

        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        TSTabBarViewController *tabBarViewController =
        [mainStoryboard instantiateViewControllerWithIdentifier:@"TSTabBarViewController"];
        [tabBarViewController setSelectedIndex:3];
        UIViewController *currentTopVC = [self currentTopViewController];
        [currentTopVC presentViewController:tabBarViewController animated:YES completion:nil];
    }
}

- (IBAction)yetActionButton:(id)sender
{
    TSAlertController *alertController = [TSAlertController sharedAlertController:@"Выберите" size:20];
    
    UIAlertAction *complain = [UIAlertAction actionWithTitle:@"Пожаловаться на пользователя"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                     [self complainAboutUser];
                                                 }];
    
    UIAlertAction *block = [UIAlertAction actionWithTitle:@"Заблокировать пользователя"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       [self blockUser];
                                                   }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Отмена"
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * _Nonnull action) {

                                                  }];
    
    [complain setValue:[UIColor blackColor] forKey:@"titleTextColor"];
    [block setValue:[UIColor blackColor] forKey:@"titleTextColor"];
    [cancel setValue:[UIColor blackColor] forKey:@"titleTextColor"];
    
    [alertController addAction:complain];
    [alertController addAction:block];
    [alertController addAction:cancel];
    
    UIViewController *currentTopVC = [self currentTopViewController];
    [currentTopVC presentViewController:alertController animated:YES completion:nil];
}

- (void)complainAboutUser
{
    TSAlertController *alertController = [TSAlertController sharedAlertController:@"Выберите" size:20];
    
    self.ref = [[FIRDatabase database] reference];
    [self.ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.fireInterlocutor = [TSFireInterlocutor initWithSnapshot:snapshot byIdentifier:self.interlocutorUid];
        
        UIAlertAction *insults = [UIAlertAction actionWithTitle:@"Пишет оскорбления"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            [self complainAboutUser:0 name:self.fireInterlocutor.displayName uid:self.fireInterlocutor.uid];
                                                        }];
        
        UIAlertAction *spam = [UIAlertAction actionWithTitle:@"Распространяет спам"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         [self complainAboutUser:1 name:self.fireInterlocutor.displayName uid:self.fireInterlocutor.uid];
                                                     }];
        
        UIAlertAction *porno = [UIAlertAction actionWithTitle:@"Распространяет порнографические фото"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          [self complainAboutUser:2 name:self.fireInterlocutor.displayName uid:self.fireInterlocutor.uid];
                                                      }];
        
        UIAlertAction *violence = [UIAlertAction actionWithTitle:@"Распространяет фото насилия"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self complainAboutUser:3 name:self.fireInterlocutor.displayName uid:self.fireInterlocutor.uid];
                                                         }];
        
        UIAlertAction *suicidec = [UIAlertAction actionWithTitle:@"Приывы к суициду"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self complainAboutUser:4 name:self.fireInterlocutor.displayName uid:self.fireInterlocutor.uid];
                                                         }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Отменить"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self complainAboutUser:5 name:self.fireInterlocutor.displayName uid:self.fireInterlocutor.uid];
                                                       }];
        
        [insults setValue:[UIColor blackColor] forKey:@"titleTextColor"];
        [spam setValue:[UIColor blackColor] forKey:@"titleTextColor"];
        [porno setValue:[UIColor blackColor] forKey:@"titleTextColor"];
        [violence setValue:[UIColor blackColor] forKey:@"titleTextColor"];
        [suicidec setValue:[UIColor blackColor] forKey:@"titleTextColor"];
        [cancel setValue:[UIColor blackColor] forKey:@"titleTextColor"];
        
        [alertController addAction:insults];
        [alertController addAction:spam];
        [alertController addAction:porno];
        [alertController addAction:violence];
        [alertController addAction:suicidec];
        [alertController addAction:cancel];
        
        UIViewController *currentTopVC = [self currentTopViewController];
        [currentTopVC presentViewController:alertController animated:YES completion:nil];
    }];
}

- (void)blockUser
{
    TSAlertController *alertController = [TSAlertController sharedAlertController:@"Заблокировав пользователя, Вы не сможете получать от него сообщений и видеть его анкету" size:16];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Подтвердить блокировку"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         [self blockedUser];
                                                     }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Отменить блокировку"
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * _Nonnull action) {

                                                  }];
    
    [confirm setValue:[UIColor blackColor] forKey:@"titleTextColor"];
    [cancel setValue:[UIColor blackColor] forKey:@"titleTextColor"];
    
    [alertController addAction:confirm];
    [alertController addAction:cancel];
    
    UIViewController *currentTopVC = [self currentTopViewController];
    [currentTopVC presentViewController:alertController animated:YES completion:nil];
}

//заблокировать пользоватля

- (void)blockedUser
{
    self.ref = [[FIRDatabase database] reference];
    [self.ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.fireInterlocutor = [TSFireInterlocutor initWithSnapshot:snapshot byIdentifier:self.interlocutorUid];
        NSMutableDictionary *userData = [NSMutableDictionary dictionary];
        [userData setValue:self.fireInterlocutor.age forKey:@"age"];
        [userData setValue:@"blocked" forKey:@"blocked"];
        [userData setValue:self.fireInterlocutor.dateOfBirth forKey:@"dateOfBirth"];
        [userData setValue:self.fireInterlocutor.displayName forKey:@"displayName"];
        [userData setValue:self.fireInterlocutor.gender forKey:@"gender"];
        [userData setValue:self.fireInterlocutor.location forKey:@"location"];
        [userData setValue:self.fireInterlocutor.online forKey:@"online"];
        [userData setValue:self.fireInterlocutor.photoURL forKey:@"photoURL"];
        [userData setValue:self.fireInterlocutor.uid forKey:@"userID"];
        
        [[[[[self.ref child:@"dataBase"] child:@"users"] child:self.fireInterlocutor.uid]
          child:@"userData"] setValue:userData];
    }];
    
//    [UIView animateWithDuration:0.3 animations:^{
//        self.alpha = 0;
//    }];
}

- (void)complainAboutUser:(NSInteger)numberComplaint name:(NSString *)name uid:(NSString *)uid
{
    NSString *complaint = nil;
    switch (numberComplaint) {
        case 0:
            complaint = [NSString stringWithFormat:@"Пользователь %@ %@ пишет оскорбления", name, uid];
            break;
        case 1:
            complaint = [NSString stringWithFormat:@"Пользователь %@ %@ распространяет спам", name, uid];
            break;
        case 2:
            complaint = [NSString stringWithFormat:@"Пользователь %@ %@ распространяет порнографические фото", name, uid];
            break;
        case 3:
            complaint = [NSString stringWithFormat:@"Пользователь %@ %@ распространяет фото насилия", name, uid];
            break;
        case 4:
            complaint = [NSString stringWithFormat:@"Пользователь %@ %@ призывает к суициду", name, uid];
            break;
        case 5:
        default:
            break;
    }
    
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;
        
        [mailCont setSubject:@"Жалоба!!!"];
        [mailCont setToRecipients:[NSArray arrayWithObject:@"mircamnia@com.ua"]];
        [mailCont setMessageBody:complaint isHTML:NO];
        
        [[self currentTopViewController] presentViewController:mailCont
                                                      animated:YES
                                                    completion:nil];
    }
}

//отобразить алерт с вьюхи

- (UIViewController *)currentTopViewController {
    UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

//возвращение карточки в исходное положение

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromLeft forView:self cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    [UIView commitAnimations];
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.backgroundTableView.alpha = 0;
                         self.tableView.alpha = 0;
                     }];
    self.tapGesture.enabled = NO;
}

#pragma mark - Save mark review user

- (void)markReviewUserByRecognizer
{
    if (recognizerControllersCardsAndChat == 1) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[TSLikeAndReviewSave sharedLikeAndReviewSaveManager] saveReviewInTheDatabase:self.interlocutorData
                                                                                  reviews:self.interlocutorReviews];
        });
    } else if (recognizerControllersCardsAndChat == 2 || recognizerControllersCardsAndChat == 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[TSGetInterlocutorParameters sharedGetInterlocutor] getInterlocutorFromDatabase:self.interlocutorUid
                                                                                  respondent:@"TSSwipeView"];
        });
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.getParameters count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    
    TSViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TSViewCell" owner:self options:nil] firstObject];
    }
    
    NSInteger index = indexPath.row;
    NSString *title = [self.updateDataSource objectAtIndex:index];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@", title];
    
    if (indexPath.row == 0) {
        cell.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.f];
        cell.parameterLabel.text = @"";
    } else {
        
        NSString *parameter = [self.getParameters objectAtIndex:index];
        cell.parameterLabel.text = [NSString stringWithFormat:@"%@", parameter];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
