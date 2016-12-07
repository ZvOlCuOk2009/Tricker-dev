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

@interface TSPhotoView () <UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) UIImageView *zoomImage;
@property (assign, nonatomic) CGRect prevFrame;
@property (assign, nonatomic) BOOL zoomPhotoState;

@end

static NSString * const reuseIdntifier = @"cell";

@implementation TSPhotoView


- (void)drawRect:(CGRect)rect {
    
    //добавление кнопки
    
    self.cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(265, 9, 20, 20)];
    [self.cancelButton setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelPhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationView addSubview:self.cancelButton];
    self.cancelButton.hidden = YES;
    
    self.zoomPhotoState = NO;
    
    if ([self.photos count] == 0 && self.photos == nil) {
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake((self.frame.size.width / 2) - 60, (self.frame.size.height / 2) - 11, 120, 22);
        label.text = @"Альбом пуст";
        label.textColor = [UIColor darkGrayColor];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.f];
        [self addSubview:label];
    }
}


- (void) awakeFromNib {
    
    [super awakeFromNib];
    [self.collectionView registerNib:[UINib nibWithNibName:@"TSCollCell" bundle:nil] forCellWithReuseIdentifier:reuseIdntifier];
    
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
    return self.photos.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TSCollCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdntifier
                                                                           forIndexPath:indexPath];
    
    cell.imageView.image = [self decodingImage:indexPath];
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredVertically];
    [self zoomToSelectedImage:indexPath];

}


- (void)zoomToSelectedImage:(NSIndexPath *)indexPath
{
    
    UICollectionViewLayoutAttributes * theAttributes =
    [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
    
    CGRect cellFrameInSuperview =
    [self.collectionView convertRect:theAttributes.frame toView:[self.collectionView superview]];
    self.prevFrame = cellFrameInSuperview;
    
    self.zoomImage = [[UIImageView alloc] initWithImage:[self decodingImage:indexPath]];
    self.zoomImage.contentMode = UIViewContentModeScaleAspectFit;
    
    CGRect zoomFrameTo = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    UICollectionView *collectionView = (UICollectionView *)[self viewWithTag:66];
    
    UICollectionViewCell *cellToZoom = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    CGRect zoomFrameFrom = cellToZoom.frame;
    [self addSubview:self.zoomImage];
    
    self.zoomImage.frame = zoomFrameFrom;
    self.zoomImage.alpha = 0.3;
    
    self.cancelButton.hidden = NO;
    self.collectionView.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.3
                     animations:^{
        
        self.zoomImage.frame = zoomFrameTo;
        self.zoomImage.alpha = 1;
        
    } completion:nil];
    
}


//раскодирование изображение


- (UIImage *)decodingImage:(NSIndexPath *)indexPath
{
    NSString *photo = [self.photos objectAtIndex:indexPath.item];
    NSData *data = [[NSData alloc] initWithBase64EncodedString:photo
                                                       options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *convertImage = [UIImage imageWithData:data];
    return convertImage;
}


- (void)cancelPhoto
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.zoomImage.hidden = YES;
                         self.zoomImage = nil;
                     }];
    
    self.cancelButton.hidden = YES;
    self.collectionView.userInteractionEnabled = YES;
}



#pragma mark - UICollectionViewDelegate


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(74, 74);
}


@end
