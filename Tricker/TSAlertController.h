//
//  TSAlertController.h
//  Tricker
//
//  Created by Mac on 16.01.17.
//  Copyright © 2017 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSAlertController : UIAlertController

+ (TSAlertController *)noInternetConnection:(NSString *)text;
+ (TSAlertController *)changeAvatarActionButton:(NSString *)text;


@end
