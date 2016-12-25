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

+ (void)saveImage:(NSData *)imageData byKey:(NSString *)key byPath:(NSString *)path;
+ (UIImage *)downloadImage:(NSString *)byKey byPath:(NSString *)path;

@end
