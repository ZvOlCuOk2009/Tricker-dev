//
//  TSChatViewController.m
//  Tricker
//
//  Created by Mac on 06.12.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "TSChatViewController.h"
#import "TSProfileTableViewController.h"
#import "TSFireUser.h"
#import "TSFireInterlocutor.h"
#import "TSSwipeView.h"
#import "TSLikeAndReviewSave.h"
#import "TSTabBarViewController.h"
#import "TSGetInterlocutorParameters.h"
#import "TSPhotoZoomViewController.h"
#import "UIAlertController+TSAlertController.h"
#import "TSReachability.h"
#import "TSAlertController.h"
#import "TSSVProgressHUD.h"
#import "TSTrickerPrefixHeader.pch"

#import <MDCSwipeToChoose/MDCSwipeToChoose.h>

NSInteger openChatVC;

@import Photos;
@import Firebase;
@import FirebaseDatabase;

@interface TSChatViewController () <JSQMessagesCollectionViewDataSource, UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) FIRUser *user;
@property (strong, nonatomic) TSFireUser *fireUser;
@property (strong, nonatomic) TSFireInterlocutor *fireInterlocutor;
@property (strong, nonatomic) FIRDatabaseReference *refChat;
@property (strong, nonatomic) FIRDatabaseReference *messageRefUser;
@property (strong, nonatomic) FIRDatabaseReference *messageRefInterlocutor;
@property (strong, nonatomic) FIRDatabaseQuery *usersTypingQuery;
@property (strong, nonatomic) FIRStorageReference *storageRef;
@property (assign, nonatomic) FIRDatabaseHandle handle;

@property (strong, nonatomic) NSMutableArray <JSQMessage *> *messages;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageView;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageView;
@property (strong, nonatomic) JSQPhotoMediaItem *photoMessageMap;

@property (strong, nonatomic) TSSwipeView *swipeView;

@property (strong, nonatomic) UIImage *userAvatar;
@property (strong, nonatomic) UIButton *interlocutorAvatarButtonNavBar;

@property (strong, nonatomic) NSDictionary *parametersInterlocutor;
@property (strong, nonatomic) NSString *imageURLNotSetKey;

@property (assign, nonatomic) CGRect frameBySizeDevice;
@property (assign, nonatomic) CGRect heartInitFrame;
@property (assign, nonatomic) CGRect heartFinalFrame;
@property (assign, nonatomic) CGFloat fontSizeBubble;

@end

@implementation TSChatViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSLog(@"TSChatViewController");
    self.refChat = [[FIRDatabase database] reference];
    self.storageRef = [[FIRStorage storage] reference];
    self.user = [FIRAuth auth].currentUser;
    
    self.messages = [NSMutableArray array];
    
    self.imageURLNotSetKey = @"NOTSET";
    
    self.senderId = self.user.uid;
    self.senderDisplayName = self.user.displayName;
    self.usersTypingQuery = [self.refChat queryOrderedByKey];
    
    if ([self.senderId isEqual:nil]) {
        self.senderId = @"";
    }
    
    if (self.senderDisplayName == nil) {
        self.senderDisplayName = @"";
    }
    
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = kRectAvatar;
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = kRectAvatar;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    [backItem setImage:[UIImage imageNamed:@"back"]];
    [backItem setTintColor:DARK_GRAY_COLOR];
    self.navigationItem.leftBarButtonItem = backItem;
    [backItem setTarget:self];
    [backItem setAction:@selector(cancelInteraction)];
    [TSSVProgressHUD showProgressHud];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.fontSizeBubble = kFontBubbleChatIphone;
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.fontSizeBubble = kFontBubbleChatIpad;
    }
    openChatVC = 1;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[TSReachability sharedReachability] verificationInternetConnection]) {
        [self setupBubbles];
        self.handle = [self.refChat observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            self.fireUser = [TSFireUser initWithSnapshot:snapshot];
            [self configureCurrentChat];
            
            NSURL *urlPhoto = [NSURL URLWithString:self.fireUser.photoURL];
            UIImage *imagePhoto = [UIImage imageWithData:[NSData dataWithContentsOfURL:urlPhoto]];
            self.userAvatar = imagePhoto;
        }];
        
        //проверяю есть ли ID собеседника если отсутствует, достаю из предварительно сохранившегося в NSUserDefaults
        //вызывается метод заполнения данными
        if (self.interlocutorID) {
            [self setDataInterlocutorToCard:self.interlocutorID];
        } else {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            self.interlocutorID = [userDefaults objectForKey:@"intelocID"];
            [self setDataInterlocutorToCard:self.interlocutorID];
        }
        recognizerControllersCardsAndChat = 2;
    } else {
        TSAlertController *alertController =
        [TSAlertController noInternetConnection:@"Проверьте интернет соединение..."];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    [self setMessageRef];
    clearArrayMessageChat = 0;
    //[self.inputToolbar.contentView.textView becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self observeMessages];
}

//наполнение данными карточки собеседника

- (void)setDataInterlocutorToCard:(NSString *)identifier
{
    self.handle = [self.refChat observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.fireInterlocutor = [TSFireInterlocutor initWithSnapshot:snapshot
                                                        byIdentifier:identifier];
        self.interlocutorAvatar =
        [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.fireInterlocutor.photoURL]]];
        self.interlocName = self.fireInterlocutor.displayName;
        self.parametersInterlocutor = self.fireInterlocutor.parameters;
        [self.interlocutorAvatarButtonNavBar setImage:self.interlocutorAvatar forState:UIControlStateNormal];
        
        NSArray *componentName = [self.interlocName componentsSeparatedByString:@" "];
        if (componentName.count > 1) {
            self.title = [componentName firstObject];
        } else {
            self.title = self.interlocName;
        }
        [self.refChat removeObserverWithHandle:self.handle];
    }];
}

//очистка чата от сообщений в момент скрытия контроллера с экрана

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if ([self.messages count] > 0 && clearArrayMessageChat == 0) {
        [self.messages removeAllObjects];
    }
    //удаление кнопки с навбара в момент возврата на контроллер чатов
    [self.interlocutorAvatarButtonNavBar removeFromSuperview];
    [self.refChat removeObserverWithHandle:self.handle];
}

- (void)configureCurrentChat
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (IS_IPHONE_4) {
            self.frameBySizeDevice = kTSSwipeDetailViewFrame;
            self.heartInitFrame = kTSInitialHeartRect5;
            self.heartFinalFrame = kTSFinalHeartRect5;
        } else if (IS_IPHONE_5) {
            self.frameBySizeDevice = kTSSwipeDetailView5Frame;
            self.heartInitFrame = kTSInitialHeartRect5;
            self.heartFinalFrame = kTSFinalHeartRect5;
        } else if (IS_IPHONE_6) {
            self.frameBySizeDevice = kTSSwipeDetailView6Frame;
            self.heartInitFrame = kTSInitialHeartRect6;
            self.heartFinalFrame = kTSFinalHeartRect6;
        } else if (IS_IPHONE_6_PLUS) {
            self.frameBySizeDevice = kTSSwipeDetailView6PlusFrame;
            self.heartInitFrame = kTSInitialHeartRect6plus;
            self.heartFinalFrame = kTSFinalHeartRect6plus;
        }
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (IS_IPAD_2) {
            self.frameBySizeDevice = kTSSwipeDetailViewIpadFrame;
            self.heartInitFrame = kTSInitialHeartRectIpad;
            self.heartFinalFrame = kTSFinalHeartRectIpad;
        } else if (IS_IPAD_PRO) {
            self.frameBySizeDevice = kTSSwipeDetailViewIpadProFrame;
            self.heartInitFrame = kTSInitialHeartRectIpad;
            self.heartFinalFrame = kTSFinalHeartRectIpad;
        }
    }
    
    NSArray *namesComponent = [self.interlocName componentsSeparatedByString:@" "];
    if ([namesComponent count] > 1) {
        self.title = [namesComponent firstObject];
    } else {
        self.title = self.interlocName;
    }
    
    [self.inputToolbar.contentView.rightBarButtonItem setTitleColor:DARK_GRAY_COLOR forState:UIControlStateNormal];
    [self.inputToolbar.contentView.rightBarButtonItem setTitle:@"Отпр" forState:UIControlStateNormal];
    self.inputToolbar.contentView.textView.placeHolder = @"Новое сообщение";
    self.interlocutorAvatarButtonNavBar = [[UIButton alloc] initWithFrame:kFrameInterlocutorAvatarNavBar];
    self.interlocutorAvatarButtonNavBar.layer.cornerRadius = self.interlocutorAvatarButtonNavBar.frame.size.width / 2;
    self.interlocutorAvatarButtonNavBar.layer.masksToBounds = YES;
    [self.interlocutorAvatarButtonNavBar addTarget:self
                                            action:@selector(interlocutorButtonNavBarActoin)
                                  forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:self.interlocutorAvatarButtonNavBar];
}

//селектор кнопки назад

- (void)cancelInteraction
{
    [self.navigationController popToViewController:[self.navigationController.viewControllers firstObject]
                                          animated:YES];
    recognizerTransitionOnChatController = 0;
}

//создание ссылок для сохранения разговора пользователя и собеседника в базу

- (void)setMessageRef
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.interlocutorID) {
            self.messageRefUser = [[[[[self.refChat child:@"dataBase"] child:@"chats"] child:self.user.uid] child:@"chat"] child:self.interlocutorID];
            self.messageRefInterlocutor = [[[[[self.refChat child:@"dataBase"] child:@"chats"] child:self.interlocutorID] child:@"chat"] child:self.user.uid];
            [TSSVProgressHUD dissmisProgressHud];
        }
    });
}

#pragma mark - Action

//call selector swipeView details

- (void)interlocutorButtonNavBarActoin
{
    //add a view to the screen only if it is not there yet
    if (![self.swipeView isDescendantOfView:self.view]) {
        //The identifier tells the TSSwipeView chat button that when pressed it should trigger the TSSwipeView removal method from the screen
        recognizerTransitionOnChatController = 0;
        
        //if there is a keyboard on the screen, then I remove it
        if ([self.inputToolbar.contentView.textView isFirstResponder]) {
            [self.inputToolbar.contentView.textView resignFirstResponder];
        }
        
        NSInteger leftValue = 10;
        if (IS_IPAD_PRO) {
            leftValue = 30;
        }
        
        self.swipeView = [TSSwipeView initDetailView];
        self.swipeView.frame = CGRectMake(leftValue, - 400, self.swipeView.frame.size.width, self.swipeView.frame.size.width);
        self.swipeView.nameLabel.text = self.interlocName;
        self.swipeView.ageLabel.text = self.fireInterlocutor.age;
        
        if ([self.fireInterlocutor.photos count] > 0) {
            self.swipeView.countPhotoLabel.text = [NSString stringWithFormat:@"%ld",
                                                   (long)[self.fireInterlocutor.photos count] - 1];
        }
        
        self.swipeView.avatarImageView.image = self.interlocutorAvatar;
        self.swipeView.backgroundImageView.image = self.interlocutorAvatar;
        self.swipeView.parameterUser = self.fireInterlocutor.parameters;
        self.swipeView.photos = self.fireInterlocutor.photos;
        self.swipeView.interlocutorUid = self.interlocutorID;
        
        //container for swipeView
        MDCSwipeToChooseView *containerView = [[MDCSwipeToChooseView alloc] initWithFrame:self.view.bounds
                                                                                  options:nil];
        [containerView addSubview:self.swipeView];
        [self.view addSubview:containerView];
                
        [UIView animateWithDuration:0.35
                              delay:0
             usingSpringWithDamping:0.6
              initialSpringVelocity:1.2
                            options:0
                         animations:^{
                             self.swipeView.frame = self.frameBySizeDevice;
                         } completion:nil];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(hendlePanGesture)];
        tapGestureRecognizer.numberOfTapsRequired = 2;
        [self.swipeView addGestureRecognizer:tapGestureRecognizer];
        
        //определитель TSSwipeView устанавливается в положение вызова чата из TSCardsViewController
        recognizerTransitionOnChatController = 2;
    }
}

#pragma mark - UITapGestureRecognizer

- (void)hendlePanGesture
{
    UIImageView *heart = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heart"]];
    heart.frame = self.heartInitFrame;
    heart.alpha = 0;
    [self.swipeView addSubview:heart];
    
    [UIView animateWithDuration:0.4
                          delay:0
         usingSpringWithDamping:1.2
          initialSpringVelocity:1.3
                        options:UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         heart.alpha = 1;
                         heart.frame = self.heartFinalFrame;
                     } completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.15
                         animations:^{
                             heart.alpha = 0;
                         }];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [heart removeFromSuperview];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[TSGetInterlocutorParameters sharedGetInterlocutor] getInterlocutorFromDatabase:self.interlocutorID
                                                                              respondent:@"ChatViewController"];
    });
}

#pragma mark - MDCSwipeToChoose

- (BOOL)view:(UIView *)view shouldBeChosenWithDirection:(MDCSwipeDirection)direction {
    [UIView animateWithDuration:0.16 animations:^{
        view.transform = CGAffineTransformIdentity;
        view.center = [view superview].center;
    }];
    return YES;
}

#pragma mark - JSQMessagesCollectionViewDataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.messages[indexPath.item];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.messages.count;
}

//входящие и исходящие пузыри

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageView;
    } else {
        return self.incomingBubbleImageView;
    }
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    JSQMessage *message = self.messages[indexPath.item];
    if ([message.senderId isEqualToString:self.senderId]) {
        cell.textView.textColor = [UIColor whiteColor];
    } else {
        cell.textView.textColor = [UIColor darkGrayColor];
    }
    cell.textView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:self.fontSizeBubble];
    return cell;
}

//установки аватаров напротив сообщений

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = self.messages[indexPath.item];
    if ([message.senderId isEqualToString:self.senderId]) {
        UIImage *userImage = nil;
        if (self.userAvatar) {
            userImage = self.userAvatar;
        } else {
            userImage = [UIImage imageNamed:@"placeholder_avarar"];
        }
        return [JSQMessagesAvatarImageFactory avatarImageWithImage:userImage
                                                          diameter:kDiameterAvatar];
    } else {
        UIImage *interlocutorImage = nil;
        if (self.interlocutorAvatar) {
            interlocutorImage = self.interlocutorAvatar;
        } else {
            interlocutorImage = [UIImage imageNamed:@"placeholder_message"];
        }
        return [JSQMessagesAvatarImageFactory avatarImageWithImage:interlocutorImage
                                                          diameter:kDiameterAvatar];
    }
}

//добавление пузырей в чат

- (void)setupBubbles
{
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.outgoingBubbleImageView = [bubbleFactory outgoingMessagesBubbleImageWithColor:
                                    DARK_GRAY_COLOR];
    self.incomingBubbleImageView = [bubbleFactory incomingMessagesBubbleImageWithColor:
                                    YELLOW_COLOR];
}

//добавление сообщение в массив для отображения в чате

- (void)addMessage:(NSString *)idString text:(NSString *)text
{
    JSQMessage * message = [JSQMessage messageWithSenderId:idString displayName:self.senderDisplayName text:text];
    [self.messages addObject:message];
}

//нажатие кнопки "отправить"

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    //если текст не введён, кнопка отправки не нажимается
    if (!([self.inputToolbar.contentView.textView.text length] == 0)) {
        FIRDatabaseReference *itemRefUser = [self.messageRefUser childByAutoId];
        FIRDatabaseReference *itemRefInterlocutor = [self.messageRefInterlocutor childByAutoId];
        
        NSDictionary *messageItem = @{@"text":text, @"senderId":senderId};
        [itemRefUser setValue:messageItem];
        [itemRefInterlocutor setValue:messageItem];
        [JSQSystemSoundPlayer jsq_playMessageSentSound];
        self.inputToolbar.contentView.textView.text = @"";
        [self.refChat removeObserverWithHandle:self.handle];
    }
}

//добавление наблюдателя за новыми сообщениями

- (void)observeMessages
{
    [self.messages removeAllObjects];
    FIRDatabaseQuery *messagesQuery = [self.messageRefUser queryLimitedToLast:20];
    [messagesQuery observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *messageData = snapshot.value;
        NSArray *allKeys = [messageData allKeys];
        NSString *firstKey = [allKeys firstObject];
        NSString *lastKey = [allKeys lastObject];
        NSString *ID = snapshot.value[@"senderId"];
        if ([firstKey isEqualToString:@"senderId"] && [lastKey isEqualToString:@"text"]) {
            NSString *text = snapshot.value[@"text"];
            JSQMessage *message = [self.messages lastObject];
            if (![message.text isEqualToString:text]) {
                [self addMessage:ID text:text];
            }
            [self finishReceivingMessageAnimated:YES];
        } else if ([firstKey isEqualToString:@"imageURL"] && [lastKey isEqualToString:@"senderId"]) {
            NSString *imageURL = snapshot.value[@"imageURL"];
            JSQPhotoMediaItem *mediaItem = [[JSQPhotoMediaItem alloc] initWithMaskAsOutgoing:YES];
            [self addPhotoMessage:ID key:snapshot.key mediaItem:mediaItem];
            if ([imageURL hasPrefix:@"https://"]) {
                [self fetchImageDataAtURL:imageURL forMediaItem:mediaItem
     clearsPhotoMessageMapOnSuccessForKey:nil];
            }
        }
    }];
}

#pragma mark - send image

- (NSString *)sendPhotoMessage
{
    FIRDatabaseReference *itemRef = [self.messageRefUser childByAutoId];
    NSDictionary *messageItem = @{@"imageURL":self.imageURLNotSetKey,
                                  @"senderId":self.fireUser.uid};
    [itemRef setValue:messageItem];
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    [self finishSendingMessage];
    return itemRef.key;
}

- (void)setImageURL:(NSString *)url forPhotoMessageWithKey:(NSString *)key
{
    FIRDatabaseReference *itemRef = [self.messageRefUser child:key];
    [itemRef updateChildValues:@{@"imageURL":url}];
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Выберите фото"
//                                                                             message:nil
//                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
//    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Камера"
//                                                     style:UIAlertActionStyleDefault
//                                                   handler:^(UIAlertAction * _Nonnull action) {
//                                                       [self makePhoto];
//                                                   }];
//    
//    UIAlertAction *galery = [UIAlertAction actionWithTitle:@"Галерея"
//                                                     style:UIAlertActionStyleDefault
//                                                   handler:^(UIAlertAction * _Nonnull action) {
//                                                       [self selectPhoto];
//                                                   }];
//    
//    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Отменить"
//                                                     style:UIAlertActionStyleDefault
//                                                   handler:nil];
//    
//    [alertController customizationAlertView:@"Выберите фото" byFont:20.f];
//    [alertController addAction:camera];
//    [alertController addAction:galery];
//    [alertController addAction:cancel];
//    [self presentViewController:alertController animated:YES completion:nil];
    
    [self selectPhoto];
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
    [picker dismissViewControllerAnimated:YES completion:NULL];
    NSString *key = [self sendPhotoMessage];
    UIImage *image = info[UIImagePickerControllerEditedImage];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    NSString *path = [NSString stringWithFormat:@"%@/sendImage/%lld.jpg", [FIRAuth auth].currentUser.uid,
                      (long long)([NSDate date].timeIntervalSince1970 * 1000.0)];
    FIRStorageReference *storageRef = [[FIRStorage storage] reference];
    FIRStorageReference *imagesRef = [storageRef child:path];
    FIRStorageMetadata *metadata = [FIRStorageMetadata new];
    metadata.contentType = @"image/jpeg";
    
    [[self.storageRef child:path] putData:imageData metadata:metadata
                          completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
                              if (!error) {
                                  [imagesRef downloadURLWithCompletion:^(NSURL * _Nullable URL, NSError * _Nullable error)
                                  {
                                      NSString *photoURL = [NSString stringWithFormat:@"%@", URL];
                                      if (!error) {
                                          [self setImageURL:photoURL forPhotoMessageWithKey:key];
                                      } else {
                                          NSLog(@"error %@", error.description);
                                      }
                                  }];
                              } else {
                                  NSLog(@"Error uploading: %@", error);
                              }
                          }];
}

- (void)addPhotoMessage:(NSString *)withId key:(NSString *)key mediaItem:(JSQPhotoMediaItem *)mediaItem
{
    JSQMessage * message = [JSQMessage messageWithSenderId:self.fireUser.uid displayName:self.fireUser.displayName
                                                     media:mediaItem];
    [self.messages addObject:message];
    if (mediaItem.image == nil) {
        mediaItem = [self photoMessageMap];
    }
    [self.collectionView reloadData];
}

- (void)fetchImageDataAtURL:(NSString *)imageUrl forMediaItem:(JSQPhotoMediaItem *)mediaItem
  clearsPhotoMessageMapOnSuccessForKey:(NSString *)key
{
    FIRStorageReference *storageRef = [[FIRStorage storage] referenceForURL:imageUrl];
    [storageRef dataWithMaxSize:INT64_MAX completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error downloading image data %@", error.description);
        }
        
        [storageRef metadataWithCompletion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
            if (!error) {
                mediaItem.image = [UIImage imageWithData:data];
            } else {
                NSLog(@"Error downloading metadata %@", error.description);
            }
            [self.collectionView reloadData];
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
