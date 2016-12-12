//
//  TSChatViewController.h
//  Tricker
//
//  Created by Mac on 06.12.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSQMessagesViewController/JSQMessages.h>

@interface TSChatViewController : JSQMessagesViewController

@property (strong, nonatomic) NSString *interlocutorID;

@end
