//
//  UIAlertController+TSAlertController.m
//  Tricker
//
//  Created by Mac on 05.01.17.
//  Copyright © 2017 Mac. All rights reserved.
//

#import "UIAlertController+TSAlertController.h"
#import "TSTrickerPrefixHeader.pch"

@implementation UIAlertController (TSAlertController)

- (UIAlertController *)customizationAlertView:(NSString *)title byFont:(CGFloat)size
{
    UIView *subview = self.view.subviews.firstObject;
    UIView *alertContentView = subview.subviews.firstObject;
    alertContentView.backgroundColor = YELLOW_COLOR;
    alertContentView.layer.cornerRadius = 10;
    self.view.tintColor = DARK_GRAY_COLOR;
    
    NSMutableAttributedString *mutableAttrString = [[NSMutableAttributedString alloc] initWithString:title];
    [mutableAttrString addAttribute:NSFontAttributeName
                              value:[UIFont fontWithName:@"HelveticaNeue-Light" size:size]
                              range:NSMakeRange(0, [title length])];
    [self setValue:mutableAttrString forKey:@"attributedTitle"];
    return self;
}

@end
