//
//  TSFireBase.m
//  Tricker
//
//  Created by Mac on 25.11.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "TSFireBase.h"

@implementation TSFireBase

+ (NSDictionary *)initWithSnapshot:(FIRDataSnapshot *)snapshot
{
    
    NSDictionary *base = [NSDictionary dictionary];
    NSString *key = @"dataBase";
    FIRDataSnapshot *fireBase = [snapshot childSnapshotForPath:key];
    FIRDataSnapshot *users = fireBase.value[@"users"];
    base = (NSDictionary *)users;
    
    return base;
    
}

@end
