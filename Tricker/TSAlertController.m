//
//  TSAlertController.m
//  Tricker
//
//  Created by Mac on 16.01.17.
//  Copyright © 2017 Mac. All rights reserved.
//

#import "TSAlertController.h"
#import "UIAlertController+TSAlertController.h"

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
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       
                                                   }];
    
    [alertController customizationAlertView:text byLength:[text length] byFont:20.f];
    
    [alertController addAction:cancel];
    
    return alertController;
}


+ (TSAlertController *)sharedAlertController:(NSString *)text
{
    TSAlertController *alertController = [TSAlertController alertControllerWithTitle:text
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController customizationAlertView:text byLength:[text length] byFont:20.f];
    
    return alertController;

}



@end
