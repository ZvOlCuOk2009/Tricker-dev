//
//  TSSwipeView.h
//  Tricker
//
//  Created by Mac on 24.11.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSInteger recognizerTransitionOnChatController;
extern NSInteger recognizerControllersCardsAndChat;

@interface TSSwipeView : UIView

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *countPhotoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIView *onlineView;
@property (weak, nonatomic) IBOutlet UIButton *nopeButton;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) IBOutlet UIImageView *chatImageView;

@property (strong, nonatomic) UIImage *interlocutorAvatar;
@property (strong, nonatomic) NSString *interlocutorAvatarUrl;
@property (strong, nonatomic) NSString *interlocutorUid;
@property (strong, nonatomic) NSString *interlocutorName;
@property (strong, nonatomic) NSDictionary *parameterUser;
@property (strong, nonatomic) NSMutableDictionary *interlocutorData;
@property (strong, nonatomic) NSMutableArray *interlocutorReviews;
@property (strong, nonatomic) NSMutableArray *photos;

+ (instancetype)initProfileView;
+ (instancetype)initDetailView;

@end
