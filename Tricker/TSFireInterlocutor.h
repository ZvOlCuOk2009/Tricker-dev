//
//  TSFireInterlocutor.h
//  Tricker
//
//  Created by Mac on 17.12.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@import FirebaseAuth;
@import FirebaseDatabase;

@interface TSFireInterlocutor : NSObject

@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *photoURL;
@property (strong, nonatomic) NSString *dateOfBirth;
@property (strong, nonatomic) NSString *age;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *online;
@property (strong, nonatomic) NSString *blocked;
@property (strong, nonatomic) NSMutableDictionary *userData;
@property (strong, nonatomic) NSMutableDictionary *parameters;
@property (strong, nonatomic) NSMutableArray *photos;

+ (TSFireInterlocutor *)initWithSnapshot:(FIRDataSnapshot *)snapshot byIdentifier:(NSString *)identifier;

@end
