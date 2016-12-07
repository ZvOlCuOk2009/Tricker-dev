//
//  TSPhotoAndNameViewController.h
//  Tricker
//
//  Created by Mac on 08.11.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSPhotoAndNameViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;

//@property (strong, nonatomic) IBOutlet UIImagePickerController *picker;
//
//- (void)makePhoto;
//- (void)selectPhoto;

@end
