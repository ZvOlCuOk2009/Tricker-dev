//
//  TSPhotoZoomViewController.h
//  Tricker
//
//  Created by Mac on 06.01.17.
//  Copyright © 2017 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSFireUser.h"

@interface TSPhotoZoomViewController : UIViewController

@property (strong, nonatomic) TSFireUser *fireUser;
@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) NSMutableArray *addPhotos;
@property (assign, nonatomic) NSInteger currentPage;
@property (assign, nonatomic) BOOL hiddenDeleteButton;

@end
