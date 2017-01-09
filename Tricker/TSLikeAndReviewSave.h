//
//  TSLikeSave.h
//  Tricker
//
//  Created by Mac on 08.01.17.
//  Copyright © 2017 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSLikeAndReviewSave : NSObject

+ (TSLikeAndReviewSave *)sharedLikeAndReviewSaveManager;

- (void)saveLikeInTheDatabase:(NSMutableDictionary *)likeUser;
- (void)saveReviewInTheDatabase:(NSMutableDictionary *)reviewsUserData reviews:(NSMutableArray *)reviews;

@end
