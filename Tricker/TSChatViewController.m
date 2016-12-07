//
//  TSChatViewController.m
//  Tricker
//
//  Created by Mac on 06.12.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "TSChatViewController.h"
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
    
    [self configureCurrentChat];
}


- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    [self observeMessages];
    
}


- (void)configureCurrentChat
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(heandlerNotification:) name:TSSwipeViewInterlocutorNotification object:nil];
    
//    [self.ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
//        
////        self.friends = [TSRetriveFriendsFBDatabase retriveFriendsDatabase:snapshot];
//        self.fireUser = [TSFireUser initWithSnapshot:snapshot];
//        
//        NSURL *url = [NSURL URLWithString:self.fireUser.photoURL];
//        NSData *dataImage = [NSData dataWithContentsOfURL:url];
//        self.userAvatar = [UIImage imageWithData:dataImage];
//        
//        
//        if (!self.interlocutorID) {
    
//            if (self.friends.count > 0) {
            
//                NSDictionary *temporaryDict = [self.friends objectAtIndex:0];
//                NSString * temporaryID = [temporaryDict objectForKey:@"fireUserID"];
//                self.interlocutor = temporaryID;
//            }
//            else {
//                self.interlocutor = @"";
//            }
        
//        }
        
//        [self getImageInterlocutor:self.friends];
        
    
        
//    }];
    
    
    
}


- (void)heandlerNotification:(NSNotification *)notification
{
    
    self.interlocutorID = [[notification object] objectForKey:@"intelocID"];
    self.interlocutorAvatar = [[notification object] objectForKey:@"intelocAvatar"];
    
    
    if (self.interlocutorID != nil) {
        
        self.messageRefUser = [[[[[self.ref child:@"dataBase"] child:@"users"] child:self.fireUser.uid] child:@"chat"] child:self.interlocutorID];
        self.messageRefInterlocutor = [[[[[self.ref child:@"dataBase"] child:@"users"] child:self.interlocutorID] child:@"chat"] child:self.user.uid];
    }
    
}


- (void)getImageInterlocutor:(NSMutableArray *)friends
{
    for (NSDictionary *data in friends) {
        
        NSString *ID = [data objectForKey:@"fireUserID"];
        if ([ID isEqualToString:self.interlocutorID]) {
            
            NSString *urlString = [data objectForKey:@"photoURL"];
            NSURL *url = [NSURL URLWithString:urlString];
            NSData *dataImage = [NSData dataWithContentsOfURL:url];
            self.interlocutorAvatar = [UIImage imageWithData:dataImage];
        }
    }
}


- (void)getImageUser
{
    
    [self.ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        self.fireUser = [TSFireUser initWithSnapshot:snapshot];
        NSURL *url = [NSURL URLWithString:self.fireUser.photoURL];
        NSData *dataImage = [NSData dataWithContentsOfURL:url];
        self.userAvatar = [UIImage imageWithData:dataImage];
    }];
    
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
            userImage = [UIImage imageNamed:@"placeholder_message"];
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
    
    FIRDatabaseQuery *messagesQuery = [self.messageRefUser queryLimitedToLast:20];
    [messagesQuery observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSString *ID = snapshot.value[@"senderId"];
        NSString *text = snapshot.value[@"text"];
        
        [self addMessage:ID text:text];
        [self finishReceivingMessageAnimated:YES];
    }];
    
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


@end
