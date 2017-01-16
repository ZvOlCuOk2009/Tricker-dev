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


+ (TSAlertController *)changeAvatarActionButton:(NSString *)text
{
    TSAlertController *alertController = [TSAlertController alertControllerWithTitle:@"Выберите фото"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Камера"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       
                                                   }];
    
    UIAlertAction *galery = [UIAlertAction actionWithTitle:@"Галерея"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       
                                                   }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Отменить"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       
                                                   }];
    
    [alertController customizationAlertView:@"Выберите фото" byLength:13 byFont:20.f];
    
    [alertController addAction:camera];
    [alertController addAction:galery];
    [alertController addAction:cancel];
    
    return alertController;

}



@end
