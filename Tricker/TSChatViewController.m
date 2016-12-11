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
#import "TSSwipeView.h"
#import "TSTrickerPrefixHeader.pch"

@import Firebase;
@import FirebaseDatabase;

@interface TSChatViewController () <JSQMessagesCollectionViewDataSource>

@property (strong, nonatomic) FIRUser *user;
@property (strong, nonatomic) TSFireUser *fireUser;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) FIRDatabaseReference *messageRefUser;
@property (strong, nonatomic) FIRDatabaseReference *messageRefInterlocutor;
@property (strong, nonatomic) FIRDatabaseQuery *usersTypingQuery;

@property (strong, nonatomic) NSMutableArray <JSQMessage *> *messages;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageView;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageView;

@property (strong, nonatomic) NSString *interlocutorID;
@property (strong, nonatomic) UIImage *interlocutorAvatar;
@property (strong, nonatomic) UIImage *userAvatar;

@end

@implementation TSChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.inputToolbar.contentView.rightBarButtonItem setTitleColor:DARK_GRAY_COLOR forState:UIControlStateNormal];
    [self.inputToolbar.contentView.rightBarButtonItem setTitle:@"Отпр" forState:UIControlStateNormal];
    self.inputToolbar.contentView.textView.placeHolder = @"Новое сообщение";
    self.inputToolbar.contentView.textView.font = [UIFont fontWithName:@"System-light" size:18.0];
    
    self.ref = [[FIRDatabase database] reference];
    [self.ref keepSynced:NO];
    
    self.user = [FIRAuth auth].currentUser;
    self.messages = [NSMutableArray array];
    
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
    
    
    [self.ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        self.fireUser = [TSFireUser initWithSnapshot:snapshot];
        [self configureCurrentChat];
        
    }];
    
}


- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    [self observeMessages];
    [self.messages removeAllObjects];
    
}


- (void)configureCurrentChat
{
    
    NSURL *urlPhoto = [NSURL URLWithString:self.fireUser.photoURL];
    UIImage *imagePhoto = [UIImage imageWithData:[NSData dataWithContentsOfURL:urlPhoto]];
    
    if (urlPhoto && urlPhoto.scheme && urlPhoto.host) {
        self.userAvatar = imagePhoto;
    } else {
        NSData *data = [[NSData alloc] initWithBase64EncodedString:self.fireUser.photoURL
                                                           options:NSDataBase64DecodingIgnoreUnknownCharacters];
        self.userAvatar = [UIImage imageWithData:data];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(heandlerNotification:) name:TSSwipeViewInterlocutorNotification object:nil];
    
    [self setupBubbles];
    
}


- (void)heandlerNotification:(NSNotification *)notification
{
    
    self.interlocutorID = [[notification object] objectForKey:@"intelocID"];
    self.interlocutorAvatar = [[notification object] objectForKey:@"intelocAvatar"];
    
    if (self.interlocutorID != nil) {
        
        self.messageRefUser = [[[[[self.ref child:@"dataBase"] child:@"users"] child:self.user.uid] child:@"chat"] child:self.interlocutorID];
        self.messageRefInterlocutor = [[[[[self.ref child:@"dataBase"] child:@"users"] child:self.interlocutorID] child:@"chat"] child:self.user.uid];
    }
    
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
    
    cell.textView.font = [UIFont fontWithName:@"System-light" size:32.0];
    
    return cell;
    
}


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


- (void)setupBubbles
{
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.outgoingBubbleImageView = [bubbleFactory outgoingMessagesBubbleImageWithColor:
                                    DARK_GRAY_COLOR];
    self.incomingBubbleImageView = [bubbleFactory incomingMessagesBubbleImageWithColor:
                                    YELLOW_COLOR];
    
}


- (void)addMessage:(NSString *)idString text:(NSString *)text
{
    
    JSQMessage * message = [JSQMessage messageWithSenderId:idString displayName:self.senderDisplayName text:text];
    [self.messages addObject:message];
    
}


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


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


@end
