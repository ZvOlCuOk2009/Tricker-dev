//
//  TSFireSaveImage.h
//  Tricker
//
//  Created by Mac on 25.12.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol TSFireImageDalegate <NSObject>

@required;

- (void)openTabBarcontroller;

@end

@interface TSFireImage : NSObject

@property (weak, nonatomic) id <TSFireImageDalegate> delegate;

- (void)saveAvatarInTheDatabase:(NSData *)avatarDataByPath byPath:(NSString *)path
                      dictParam:(NSMutableDictionary *)params;
- (void)savePhotos:(NSData *)imageDataByPath byPath:(NSString *)path photos:(NSMutableArray *)photos;

@end
