//
//  TSFireSaveImage.m
//  Tricker
//
//  Created by Mac on 25.12.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "TSFireImage.h"

@import FirebaseAuth;
@import FirebaseStorage;

@interface TSFireImage ()

//@property (strong, nonatomic) FIRStorageReference *storageRef;

@end

@implementation TSFireImage

+ (void)saveImage:(NSData *)imageData byKey:(NSString *)key byPath:(NSString *)path
{
    
    FIRStorageReference *storageRef = [[FIRStorage storage] reference];
    FIRStorageMetadata *metadata = [FIRStorageMetadata new];
    metadata.contentType = @"image/jpeg";
    
    [[storageRef child:path] putData:imageData metadata:metadata
                               completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
                                   
                                   if (error) {
                                       NSLog(@"Error uploading: %@", error);
                                   }
                                   
                                   [[NSUserDefaults standardUserDefaults] setObject:path forKey:key];
                                   [[NSUserDefaults standardUserDefaults] synchronize];
                                    
                                }];
}


+ (UIImage *)downloadImage:(NSString *)byKey byPath:(NSString *)path
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *filePath = [NSString stringWithFormat:@"file:%@/myimage.jpg", documentsDirectory];
    NSURL *fileURL = [NSURL URLWithString:filePath];
    NSString *storagePath = [[NSUserDefaults standardUserDefaults] objectForKey:path];
    
    __block UIImage *image = nil;
    
    FIRStorageReference *storageRef = [[FIRStorage storage] reference];
    
    [[storageRef child:storagePath] writeToFile:fileURL completion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"Error downloading: %@", error);
            return;
        } else if (URL) {
            
           image = [UIImage imageWithContentsOfFile:URL.path];
        }
    }];
    
    return image;
}

@end
