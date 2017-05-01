//
//  TSSVProgressHUD.m
//  Tricker
//
//  Created by Mac on 10.04.17.
//  Copyright © 2017 Mac. All rights reserved.
//

#import "TSSVProgressHUD.h"
#import "TSTrickerPrefixHeader.pch"

#import <SVProgressHUD.h>

@implementation TSSVProgressHUD

+ (void)showProgressHud
{
    [SVProgressHUD show];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setBackgroundColor:YELLOW_COLOR];
    [SVProgressHUD setForegroundColor:DARK_GRAY_COLOR];
}

+ (void)dissmisProgressHud
{
    [SVProgressHUD dismiss];
}

@end
