//
//  TSFireSaveImage.h
//  Tricker
//
//  Created by Mac on 25.12.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TSFireImage : NSObject

+ (TSFireImage *) sharedManager;
+ (void)saveAvatarInTheDatabase:(NSData *)avatarDataByPath byPath:(NSString *)path
                      dictParam:(NSMutableDictionary *)params;
+ (void)savePhotos:(NSData *)imageDataByPath byPath:(NSString *)path photos:(NSMutableArray *)photos;

//- (void)savePhotosInTheDatabase:(NSData *)photoDataByPath byPath:(NSString *)path
//                         photos:(void(^)(NSMutableArray *photos))success;

@end
