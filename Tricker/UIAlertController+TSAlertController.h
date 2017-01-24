//
//  UIAlertController+TSAlertController.h
//  Tricker
//
//  Created by Mac on 05.01.17.
//  Copyright © 2017 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (TSAlertController)

- (UIAlertController *)customizationAlertView:(NSString *)title byFont:(CGFloat)size;

@end
