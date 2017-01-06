//
//  TSPhotoView.m
//  Tricker
//
//  Created by Mac on 01.12.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "TSPhotoView.h"
#import "TSSwipeView.h"
#import "TSCollCell.h"
#import "TSPhotoZoomViewController.h"
#import "TSCardsViewController.h"
#import "TSTrickerPrefixHeader.pch"

#import <SVProgressHUD.h>

@interface TSPhotoView () <UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) UIImageView *zoomImage;
@property (strong, nonatomic) NSMutableArray *convertPhotos;
@property (assign, nonatomic) CGRect rectButton;
@property (assign, nonatomic) CGSize cellSize;

@end

static NSString * const reuseIdntifier = @"cell";

@implementation TSPhotoView


- (void)drawRect:(CGRect)rect {
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (IS_IPHONE_4) {
            
            self.cellSize = kTSCollCellSize;
            self.rectButton = kTSPhotoViewButtonCancelRect;
            
        } else if (IS_IPHONE_5) {
            
            
        } else if (IS_IPHONE_6) {
            
            
        } else if (IS_IPHONE_6_PLUS) {
            
            self.cellSize = kTSCollCellSize_6_Plus;
            self.rectButton = kTSPhotoViewButtonCancelRect_6_Plus;
        }
    }
    
    self.convertPhotos = [NSMutableArray array];
    
    [self showProgressHud];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        for (NSString *imageUrl in self.photos) {
            if (![imageUrl isEqual:[NSNull null]]) {
                if ([imageUrl length] > 1) {
                    UIImage *photo = [self convertPhotoByUrl:imageUrl];
                    [self.convertPhotos addObject:photo];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.collectionView reloadData];
            [self dissmisProgressHud];
            
        });
        
    });
    
    if ([self.photos count] == 0 && self.photos == nil) {
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake((self.frame.size.width / 2) - 60, (self.frame.size.height / 2) - 11, 120, 22);
        label.text = @"Альбом пуст";
        label.textColor = [UIColor darkGrayColor];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.f];
        [self addSubview:label];
    }
    
}


- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"TSCollCell" bundle:nil] forCellWithReuseIdentifier:reuseIdntifier];
    
}


- (UIImage *)convertPhotoByUrl:(NSString *)url
{
    UIImage *photo = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    return photo;
}


- (IBAction)cancelPhotoViewAction:(id)sender
{
    [self setFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height)];
    [UIView beginAnimations:@"animateView" context:nil];
    [UIView setAnimationDuration:0.3];
    [self setFrame:CGRectMake(0.0f, self.frame.size.height, self.frame.size.width, self.frame.size.height)];
    [UIView commitAnimations];
}


#pragma mark - UICollectionViewDataSource


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.convertPhotos.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TSCollCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdntifier
                                                                           forIndexPath:indexPath];
    
    cell.imageView.image = [self.convertPhotos objectAtIndex:indexPath.item];
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIStoryboard *stotyboard = [UIStoryboard storyboardWithName:@"CardsStoryboard" bundle:[NSBundle mainBundle]];
    TSPhotoZoomViewController *controller =
    [stotyboard instantiateViewControllerWithIdentifier:@"TSPhotoZoomViewController"];

    UIViewController *currentTopVC = [self currentTopViewController];
    controller.photos = self.convertPhotos;
    controller.hiddenDeleteButton = YES;
    controller.currentPage = indexPath.item;
    
    [currentTopVC presentViewController:controller animated:YES completion:nil];

}

- (UIViewController *)currentTopViewController {
    UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}


#pragma mark - UICollectionViewDelegate


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellSize;
}


#pragma mark - ProgressHUD


- (void)showProgressHud
{
    [SVProgressHUD show];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setBackgroundColor:YELLOW_COLOR];
    [SVProgressHUD setForegroundColor:DARK_GRAY_COLOR];
}


- (void)dissmisProgressHud
{
    [SVProgressHUD dismiss];
}


@end
