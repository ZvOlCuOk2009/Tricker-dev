//
//  TSGetInterlocutorParameters.m
//  Tricker
//
//  Created by Mac on 11.01.17.
//  Copyright © 2017 Mac. All rights reserved.
//

#import "TSGetInterlocutorParameters.h"
#import "TSLikeAndReviewSave.h"
#import "TSFireBase.h"

@import FirebaseDatabase;

@interface TSGetInterlocutorParameters ()

@property (strong, nonatomic) NSDictionary *fireBase;
@property (strong, nonatomic) FIRDatabaseReference *ref;

@end

@implementation TSGetInterlocutorParameters

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.ref = [[FIRDatabase database] reference];
    }
    return self;
}

+ (TSGetInterlocutorParameters *)sharedGetInterlocutor
{
    static TSGetInterlocutorParameters *interlocutorSingle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        interlocutorSingle = [[TSGetInterlocutorParameters alloc] init];
    });
    return interlocutorSingle;
}


- (void)getInterlocutorFromDatabase:(NSString *)interlocutorUid respondent:(NSString *)respondent
{
    [self.ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.fireBase = [TSFireBase initWithSnapshot:snapshot];
        
        NSMutableDictionary *searchInterlocutor = [self.fireBase objectForKey:interlocutorUid];
        NSMutableArray *reviews = [searchInterlocutor objectForKey:@"reviews"];
        
        if ([respondent isEqualToString:@"ChatViewController"] && searchInterlocutor) {
            [[TSLikeAndReviewSave sharedLikeAndReviewSaveManager] saveLikeInTheDatabase:searchInterlocutor];
        } else if ([respondent isEqualToString:@"TSSwipeView"]) {
            [[TSLikeAndReviewSave sharedLikeAndReviewSaveManager] saveReviewInTheDatabase:searchInterlocutor reviews:reviews];
        }
    }];
}

@end
