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
#import "TSFireUser.h"
#import "TSFireBase.h"

@import Firebase;
@import FirebaseDatabase;

@interface TSChatsTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) FIRUser *user;
@property (strong, nonatomic) TSFireUser *fireUser;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSDictionary *fireBase;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *interlocutors;
@property (strong, nonatomic) NSMutableArray *lastPosts;

@end

@implementation TSChatsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.ref = [[FIRDatabase database] reference];
    
    [self.ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        self.fireUser = [TSFireUser initWithSnapshot:snapshot];
        self.fireBase = [TSFireBase initWithSnapshot:snapshot];
        
        [self configureController];
        
    }];
}


- (void)configureController
{
    
    NSDictionary *chats = self.fireUser.chats;
    NSArray *allKeys = nil;
    
    if (chats) {
        allKeys = [self.fireUser.chats allKeys];
        self.interlocutors = [NSMutableArray array];
        self.lastPosts = [NSMutableArray array];
    }
    
    for (int i = 0; i < [chats count]; i++) {
        
        NSDictionary *chat = [chats objectForKey:[allKeys objectAtIndex:i]];
        NSArray *chatKeys = [chat allKeys];
        NSString *lastKey = [chatKeys lastObject];
        
        NSDictionary *lastDict = [chat objectForKey:lastKey];
        NSString *lastPost = [lastDict objectForKey:@"text"];
        
        [self.lastPosts addObject:lastPost];
        
        TSFireUser *interlocutor = [self.fireBase objectForKey:[allKeys objectAtIndex:i]];
        
        [self.interlocutors addObject:interlocutor];
    }
    
    [self.tableView reloadData];
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
    
    NSDictionary *interlocutor = [self.interlocutors objectAtIndex:indexPath.row];
    
    NSDictionary *interlocutorData = [interlocutor objectForKey:@"userData"];
    
    NSString *interlocutorName = [interlocutorData objectForKey:@"displayName"];
    NSString *interlocStringAvatar = [interlocutorData objectForKey:@"photoURL"];
    
    NSURL *urlPhoto = [NSURL URLWithString:interlocStringAvatar];
    UIImage *imagePhoto = [UIImage imageWithData:[NSData dataWithContentsOfURL:urlPhoto]];
    UIImage *interlocutorAvatar = nil;
    
    if (urlPhoto && urlPhoto.scheme && urlPhoto.host) {
        interlocutorAvatar = imagePhoto;
    } else {
        NSData *data = [[NSData alloc] initWithBase64EncodedString:interlocStringAvatar
                                                           options:NSDataBase64DecodingIgnoreUnknownCharacters];
        interlocutorAvatar = [UIImage imageWithData:data];
    }
    
    cell.interlocutorAvatar.image = interlocutorAvatar;
    cell.interlocutorNameLabel.text = interlocutorName;
    cell.correspondenceLabel.text = [self.lastPosts objectAtIndex:indexPath.row];
    
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
    
    NSDictionary *interlocutor = [self.interlocutors objectAtIndex:indexPath.row];
    NSDictionary *interlocutorData = [interlocutor objectForKey:@"userData"];
    NSString *interlocutorID = [interlocutorData objectForKey:@"userID"];
    
    [self.navigationController pushViewController:chatController animated:YES];
    chatController.interlocutorID = interlocutorID;

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
