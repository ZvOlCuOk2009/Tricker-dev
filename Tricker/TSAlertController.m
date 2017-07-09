//
//  TSAlertController.m
//  Tricker
//
//  Created by Mac on 16.01.17.
//  Copyright © 2017 Mac. All rights reserved.
//

#import "TSAlertController.h"
#import "TSTrickerPrefixHeader.pch"

@interface TSAlertController ()

@end

@implementation TSAlertController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

+ (TSAlertController *)noInternetConnection:(NSString *)text
{
    TSAlertController *alertController = [TSAlertController alertControllerWithTitle:text
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Ок"
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
    
    UIView *subView = alertController.view.subviews.lastObject;
    UIView *alertContentView = subView.subviews.lastObject;
    [alertContentView setBackgroundColor:YELLOW_COLOR];
    alertContentView.layer.cornerRadius = 14;
    
    NSMutableAttributedString *ttributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [ttributedString addAttribute:NSFontAttributeName
                            value:[UIFont fontWithName:@"HelveticaNeue-Light" size:20]
                            range:NSMakeRange(0, [text length])];
    [alertController setValue:ttributedString forKey:@"attributedTitle"];
    [alertController addAction:cancel];
    return alertController;
}

+ (TSAlertController *)sharedAlertController:(NSString *)text size:(NSInteger)size
{
    TSAlertController *alertController = [TSAlertController alertControllerWithTitle:text
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIView *subView = alertController.view.subviews.lastObject; 
    UIView *alertContentView = subView.subviews.lastObject;
    [alertContentView setBackgroundColor:YELLOW_COLOR];
    alertContentView.layer.cornerRadius = 14;
    alertContentView.tintColor = DARK_GRAY_COLOR;

    NSMutableAttributedString *ttributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [ttributedString addAttribute:NSFontAttributeName
                  value:[UIFont fontWithName:@"HelveticaNeue-Light" size:size]
                  range:NSMakeRange(0, [text length])];
    [alertController setValue:ttributedString forKey:@"attributedTitle"];
    return alertController;
}

@end
