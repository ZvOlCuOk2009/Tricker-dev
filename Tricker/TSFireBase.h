//
//  TSFireBase.h
//  Tricker
//
//  Created by Mac on 25.11.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@import FirebaseDatabase;

@interface TSFireBase : NSObject

+ (NSDictionary *)initWithSnapshot:(FIRDataSnapshot *)snapshot;

@end
