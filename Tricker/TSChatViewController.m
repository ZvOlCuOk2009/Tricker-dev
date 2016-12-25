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
#import "TSTabBarViewController.h"
#import "TSTrickerPrefixHeader.pch"

#import <SVProgressHUD.h>

@import Firebase;
@import FirebaseDatabase;

@interface TSChatViewController () <JSQMessagesCollectionViewDataSource, UIGestureRecognizerDelegate>

@property (strong, nonatomic) FIRUser *user;
@property (strong, nonatomic) TSFireUser *fireUser;
@property (strong, nonatomic) TSFireInterlocutor *fireInterlocutor;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) FIRDatabaseReference *messageRefUser;
@property (strong, nonatomic) FIRDatabaseReference *messageRefInterlocutor;
@property (strong, nonatomic) FIRDatabaseQuery *usersTypingQuery;

@property (strong, nonatomic) NSMutableArray <JSQMessage *> *messages;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageView;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageView;

@property (strong, nonatomic) UIImage *userAvatar;

@property (strong, nonatomic) UIButton *interlocutorAvatarButtonNavBar;

@property (strong, nonatomic) NSDictionary *parametersInterlocutor;

@end

@implementation TSChatViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.ref = [[FIRDatabase database] reference];
    
    self.user = [FIRAuth auth].currentUser;
    self.messages = [NSMutableArray array];
    
    
    //проверяю есть ли ID собеседника если отсутствует, достаю из предварительно сохранившемуся в NSUserDefaults
    //вызывается метод заполнения данными
    
    if (self.interlocutorID) {
        
        [self setDataInterlocutorToCard:self.interlocutorID];
        
    } else {
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        self.interlocutorID = [userDefaults objectForKey:@"intelocID"];
        [self setDataInterlocutorToCard:self.interlocutorID];
        
    }
    
    
    self.senderId = self.user.uid;
    self.senderDisplayName = self.user.displayName;
    self.usersTypingQuery = [self.ref queryOrderedByKey];
    
    if ([self.senderId isEqual:nil]) {
        self.senderId = @"";
    }
    
    if (self.senderDisplayName == nil) {
        self.senderDisplayName = @"";
    }
    
    CGSize rect = CGSizeMake(35, 35);
    
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = rect;
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = rect;
    
    [self setupBubbles];
    
    [self.ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        self.fireUser = [TSFireUser initWithSnapshot:snapshot];
        [self configureCurrentChat];
        
    }];
    
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    [backItem setImage:[UIImage imageNamed:@"back"]];
    [backItem setTintColor:DARK_GRAY_COLOR];
    self.navigationItem.leftBarButtonItem = backItem;
    
    [backItem setTarget:self];
    [backItem setAction:@selector(cancelInteraction)];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    [self observeMessages];
    
}

//наполнение данными карточки собеседника


- (void)setDataInterlocutorToCard:(NSString *)identifier
{
    
    [self.ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        self.fireInterlocutor = [TSFireInterlocutor initWithSnapshot:snapshot
                                                        byIdentifier:identifier];
        
        self.interlocutorAvatar =
        [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.fireInterlocutor.photoURL]]];
        self.interlocName = self.fireInterlocutor.displayName;
        self.parametersInterlocutor = self.fireInterlocutor.parameters;
        
    }];
    
}


//очиста чата от сообщений в момент скрытия контроллера с экрана


- (void)viewDidDisappear:(BOOL)animated
{
    
    [super viewDidDisappear:animated];
    
    if ([self.messages count] > 0) {
        [self.messages removeAllObjects];
    }
    
    [self.navigationController popToViewController:[self.navigationController.viewControllers firstObject]
                                          animated:YES];
    
    [self.interlocutorAvatarButtonNavBar setImage:nil forState:UIControlStateNormal];
    
}


- (void)configureCurrentChat
{
    
    [self.inputToolbar.contentView.rightBarButtonItem setTitleColor:DARK_GRAY_COLOR forState:UIControlStateNormal];
    [self.inputToolbar.contentView.rightBarButtonItem setTitle:@"Отпр" forState:UIControlStateNormal];
    self.inputToolbar.contentView.textView.placeHolder = @"Новое сообщение";
    
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:DARK_GRAY_COLOR,
       NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.f]}];
    
    
    self.interlocutorAvatarButtonNavBar = [[UIButton alloc] initWithFrame:CGRectMake(60, 4, 35, 35)];
    self.interlocutorAvatarButtonNavBar.layer.cornerRadius = self.interlocutorAvatarButtonNavBar.frame.size.width / 2;
    self.interlocutorAvatarButtonNavBar.layer.masksToBounds = YES;
    [self.interlocutorAvatarButtonNavBar addTarget:self
                                            action:@selector(interlocutorButtonNavBarActoin)
                                  forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:self.interlocutorAvatarButtonNavBar];
    
    
//    NSURL *urlPhoto = [NSURL URLWithString:self.fireUser.photoURL];
//    UIImage *imagePhoto = [UIImage imageWithData:[NSData dataWithContentsOfURL:urlPhoto]];
//    
//    if (urlPhoto && urlPhoto.scheme && urlPhoto.host) {
//        self.userAvatar = imagePhoto;
//    } else {
//        NSData *data = [[NSData alloc] initWithBase64EncodedString:self.fireUser.photoURL
//                                                           options:NSDataBase64DecodingIgnoreUnknownCharacters];
//        self.userAvatar = [UIImage imageWithData:data];
//    }
    
    [self setMessageRef];

}


//селектор кнопки назад


- (void)cancelInteraction
{
    [self.navigationController popToViewController:[self.navigationController.viewControllers firstObject]
                                          animated:YES];
}


//создание ссылок для сохранения разговора пользователя и собеседника в базу


- (void)setMessageRef
{
    
    NSArray *namesComponent = [self.interlocName componentsSeparatedByString:@" "];
    
    if ([namesComponent count] > 1) {
        self.title = [namesComponent firstObject];
    } else {
        self.title = self.interlocName;
    }
    
    [self.interlocutorAvatarButtonNavBar setImage:self.interlocutorAvatar forState:UIControlStateNormal];
    
    if (self.interlocutorID) {
        
        self.messageRefUser = [[[[[self.ref child:@"dataBase"] child:@"users"] child:self.user.uid] child:@"chat"] child:self.interlocutorID];
        self.messageRefInterlocutor = [[[[[self.ref child:@"dataBase"] child:@"users"] child:self.interlocutorID] child:@"chat"] child:self.user.uid];
    }
    
}


#pragma mark - Action


- (void)interlocutorButtonNavBarActoin
{
    
    TSSwipeView *swipeView = [TSSwipeView initDetailView];
    swipeView.frame = CGRectMake(10, - 400, swipeView.frame.size.width, swipeView.frame.size.width);
    swipeView.nameLabel.text = self.interlocName;
    swipeView.ageLabel.text = self.fireInterlocutor.age;
    swipeView.avatarImageView.image = self.interlocutorAvatar;
    swipeView.backgroundImageView.image = self.interlocutorAvatar;
    swipeView.parameterUser = self.fireInterlocutor.parameters;
    
    [self.view addSubview:swipeView];
        
    [UIView animateWithDuration:0.35
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:1.2
                        options:0
                     animations:^{
                         swipeView.frame = CGRectMake(10, 72, 300, 352);
                     } completion:nil];
    
    recognizer = 2;
    
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
    
    cell.textView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.f];
    
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
                                                          diameter:60];
    } else {
        
        UIImage *interlocutorImage = nil;
        
        if (self.interlocutorAvatar) {
            interlocutorImage = self.interlocutorAvatar;
        } else {
            interlocutorImage = [UIImage imageNamed:@"placeholder_message"];
        }
        
        return [JSQMessagesAvatarImageFactory avatarImageWithImage:interlocutorImage
                                                          diameter:60];
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
    
    FIRDatabaseReference *itemRefUser = [self.messageRefUser childByAutoId];
    FIRDatabaseReference *itemRefInterlocutor = [self.messageRefInterlocutor childByAutoId];
    
    NSDictionary *messageItem = @{@"text":text, @"senderId":senderId};
    
    [itemRefUser setValue:messageItem];
    [itemRefInterlocutor setValue:messageItem];
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    JSQMessagesComposerTextView *textView = self.inputToolbar.contentView.textView;
    textView.text = @"";
}


//добавление наблюдателя за новыми сообщениями


- (void)observeMessages
{
    
    [self.messages removeAllObjects];
    
    FIRDatabaseQuery *messagesQuery = [self.messageRefUser queryLimitedToLast:20];
    [messagesQuery observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSString *ID = snapshot.value[@"senderId"];
        NSString *text = snapshot.value[@"text"];
        
        [self addMessage:ID text:text];
        [self finishReceivingMessageAnimated:YES];
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


@end
