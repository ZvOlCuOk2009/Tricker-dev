//
//  TSRegistrationViewController.h
//  Tricker
//
//  Created by Mac on 07.11.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSRegistrationViewController : UIViewController

@property (assign, nonatomic) NSInteger counter;

- (NSString *)checkAvailabilityAtAnEmail;

@end
