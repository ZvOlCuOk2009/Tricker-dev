//
//  TSChatsTableViewController.m
//  Tricker
//
//  Created by Mac on 09.12.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "TSChatsTableViewController.h"
#import "TSChatTableViewCell.h"
#import "TSChatViewController.h"
#import "TSFireInterlocutor.h"
#import "TSFireUser.h"
#import "TSFireBase.h"
#import "TSSwipeView.h"
#import "TSReachability.h"
#import "TSAlertController.h"
#import "TSTrickerPrefixHeader.pch"

#import <SVProgressHUD.h>

@import Firebase;
@import FirebaseDatabase;

@interface TSChatsTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) FIRUser *user;
@property (strong, nonatomic) TSFireUser *fireUser;
@property (strong, nonatomic) FIRDatabaseReference *refChat;
@property (strong, nonatomic) FIRDatabaseReference *refForUpdateChat;
@property (strong, nonatomic) NSDictionary *fireBase;

@property (strong, nonatomic) IBOutlet UIButton *navAvatarInterlocutorButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *interlocutors;
//@property (strong, nonatomic) NSMutableArray *lastPosts;

@property (strong, nonatomic) NSMutableArray *interlocAvatar;
@property (strong, nonatomic) NSMutableDictionary *chats;

@property (assign, nonatomic) NSInteger count;

@end

@implementation TSChatsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"TSChatsTableViewController");
    self.refChat = [[FIRDatabase database] reference];
    self.refForUpdateChat = [[FIRDatabase database] reference];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[TSReachability sharedReachability] verificationInternetConnection]) {
        //проверка откуда вызван контроллер из чат тейблвью контроллера или свайп вью
        if (recognizerTransitionOnChatController == 1) {
            [self transitionToChatViewController];
        } else {
            [self.refChat observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                self.fireUser = [TSFireUser initWithSnapshot:snapshot];
                self.fireBase = [TSFireBase initWithSnapshot:snapshot];
                [self configureController];
            }];
        }
    } else {
        TSAlertController *alertController =
        [TSAlertController noInternetConnection:@"Проверьте интернет соединение..."];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.refChat removeAllObservers];
}

- (void)configureController
{
    if (!self.interlocutors && recognizerTransitionOnChatController == 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.chats = (NSMutableDictionary *)self.fireUser.chats;
            NSArray *allKeys = nil;
            
            if (self.chats) {
                [SVProgressHUD show];
                [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
                [SVProgressHUD setBackgroundColor:YELLOW_COLOR];
                [SVProgressHUD setForegroundColor:DARK_GRAY_COLOR];
                
                allKeys = [self.fireUser.chats allKeys];
                self.interlocutors = [NSMutableArray array];
//                self.lastPosts = [NSMutableArray array];
                self.interlocAvatar = [NSMutableArray array];
            }
            
            for (int i = 0; i < [allKeys count]; i++) {
                /*
                NSDictionary *chat = [self.chats objectForKey:[allKeys objectAtIndex:i]];
                NSArray *chatKeys = [chat allKeys];
                NSString *lastKey = [chatKeys lastObject];
                NSDictionary *lastDict = [chat objectForKey:lastKey];
                NSString *lastPost = [lastDict objectForKey:@"text"];
                
                if (!lastPost) {
                    lastPost = @"";
                }
                
                [self.lastPosts addObject:lastPost];
                 */
                
                NSString *interlocetorIdent = [allKeys objectAtIndex:i];
                [self.refChat observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                    NSLog(@"TSFireInterlocutor %ld", (long)self.count);
                    TSFireInterlocutor *fireInterlocutor = [TSFireInterlocutor initWithSnapshot:snapshot
                                                                                   byIdentifier:interlocetorIdent];
                    [self.interlocutors addObject:fireInterlocutor];
                    [self.interlocAvatar addObject:[self setInterlocutorsAvatarByUrl:fireInterlocutor.photoURL]];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                        [SVProgressHUD dismiss];
                    });
                    [self.refChat removeAllObservers];
                    ++self.count;
                }];
            }
        });
    }
    
    if ([self.fireUser.chats count] == 0) {
        TSAlertController *alertController =
        [TSAlertController noInternetConnection:@"В данный момент у Вас нету диалогов с другими пользователями"];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)transitionToChatViewController
{
    UIStoryboard *storyboard =
    [UIStoryboard storyboardWithName:@"ChatStoryboard" bundle:[NSBundle mainBundle]];
    
    TSChatViewController *controller =
    [storyboard instantiateViewControllerWithIdentifier:@"TSChatViewController"];
    [self.navigationController pushViewController:controller animated:NO];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.interlocutors count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    TSChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[TSChatTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(TSChatTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    TSFireInterlocutor *fireInterlocutor = [self.interlocutors objectAtIndex:indexPath.row];
    cell.interlocutorAvatar.image = [self.interlocAvatar objectAtIndex:indexPath.row];
    cell.interlocutorNameLabel.text = fireInterlocutor.displayName;
    cell.correspondenceLabel.text = fireInterlocutor.age;
}

- (UIImage *)setInterlocutorsAvatarByUrl:(NSString *)url
{
    UIImage *avatar = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    return avatar;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatStoryboard" bundle:[NSBundle mainBundle]];
    TSChatViewController *chatController =
    [storyboard instantiateViewControllerWithIdentifier:@"TSChatViewController"];
    [self.navigationController pushViewController:chatController animated:YES];
    
    TSFireInterlocutor *fireInterlocutor = [self.interlocutors objectAtIndex:indexPath.row];
    chatController.interlocutorID = fireInterlocutor.uid;
    chatController.interlocName = fireInterlocutor.displayName;
    chatController.interlocutorAvatar = [self.interlocAvatar objectAtIndex:indexPath.row];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteChatByUid:indexPath.row];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Удалить";
}

- (void)deleteChatByUid:(NSInteger)uid
{
//    TSFireInterlocutor *fireInterlocutor = [self.interlocutors objectAtIndex:uid];
//    NSString *uidUserChat = fireInterlocutor.uid;
//    [self.chats removeObjectForKey:uidUserChat];
//    [self.interlocutors removeObjectAtIndex:uid];
//    [self.interlocAvatar removeObjectAtIndex:uid];
//    [self.tableView reloadData];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [[[[[self.refForUpdateChat child:@"dataBase"] child:@"users"] child:self.fireUser.uid]
//          child:@"chat"] setValue:self.chats];
//    });
//    [self.refForUpdateChat removeAllObservers];

    
    TSFireInterlocutor *fireInterlocutor = [self.interlocutors objectAtIndex:uid];
    NSString *uidUserChat = fireInterlocutor.uid;
    [self.chats removeObjectForKey:uidUserChat];
    [self.interlocutors removeObjectAtIndex:uid];
    [self.interlocAvatar removeObjectAtIndex:uid];
    [self.tableView reloadData];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[[[[self.refChat child:@"dataBase"] child:@"chats"] child:self.fireUser.uid]
          child:@"chat"] setValue:self.chats];
    });
    [self.refChat removeAllObservers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
