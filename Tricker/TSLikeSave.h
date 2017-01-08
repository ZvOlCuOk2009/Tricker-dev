//
//  TSLikeSave.h
//  Tricker
//
//  Created by Mac on 08.01.17.
//  Copyright © 2017 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSLikeSave : NSObject

+ (TSLikeSave *)sharedLikeSaveManager;

- (void)saveLikeInTheDatabase:(NSDictionary *)likeUser;

@end
