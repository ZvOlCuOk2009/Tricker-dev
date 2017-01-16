//
//  TSReachability.h
//  Tricker
//
//  Created by Mac on 16.01.17.
//  Copyright © 2017 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSReachability : NSObject

+ (TSReachability *)sharedReachability;
- (BOOL)verificationInternetConnection;

@end
