//
//  TSChatTableViewCell.h
//  Tricker
//
//  Created by Mac on 07.12.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSChatTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *interlocutorAvatar;
@property (strong, nonatomic) IBOutlet UILabel *interlocutorNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *correspondenceLabel;

@end
