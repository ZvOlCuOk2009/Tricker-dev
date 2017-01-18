//
//  TSReachability.m
//  Tricker
//
//  Created by Mac on 16.01.17.
//  Copyright © 2017 Mac. All rights reserved.
//

#import "TSReachability.h"
#import "Reachability.h"
#import "TSAlertController.h"

@implementation TSReachability

+ (TSReachability *)sharedReachability
{
    static TSReachability *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TSReachability alloc] init];
    });
    return manager;
}


- (BOOL)verificationInternetConnection
{
    BOOL connected;
    
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        connected = NO;
    } else {
        connected = YES;
    }
    return connected;
}

@end
