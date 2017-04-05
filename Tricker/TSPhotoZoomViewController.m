//
//  TSPhotoZoomViewController.m
//  Tricker
//
//  Created by Mac on 06.01.17.
//  Copyright © 2017 Mac. All rights reserved.
//

#import "TSPhotoZoomViewController.h"
#import "UIAlertController+TSAlertController.h"

NSInteger clearArrayMessageChat;

@import Firebase;
@import FirebaseAuth;
@import FirebaseStorage;

@interface TSPhotoZoomViewController ()

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;

@end

@implementation TSPhotoZoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.deleteButton.hidden = self.hiddenDeleteButton;
    self.pageControl.numberOfPages = [self.photos count];
    self.pageControl.currentPage = self.currentPage;
    self.scrollView.pagingEnabled = YES;

    clearArrayMessageChat = 1;
}

#pragma mark - UIScrollView

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self setupScroll];
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * self.currentPage, 0.0) animated:NO];
}


- (void)setupScroll {
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * [self.photos count], self.scrollView.bounds.size.height);
    
    for (int i = 0; i < [self.photos count]; i++) {
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * self.scrollView.bounds.size.width,
                                                                               0 * self.scrollView.bounds.size.height,
                                                                               self.scrollView.bounds.size.width,
                                                                               self.scrollView.bounds.size.height)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [imageView setImage:[self.photos objectAtIndex:i]];
        [self.scrollView addSubview:imageView];
    }
}

#pragma mark - page controll

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    self.pageControl.currentPage = self.scrollView.contentOffset.x / pageWidth;
}

#pragma mark - Actions

- (IBAction)cancelButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)deleteButton:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Удалить фото?"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertActiionYes = [UIAlertAction actionWithTitle:@"Да"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self deletePhoto];
                                                         }];
    
    UIAlertAction *alertActiionNo = [UIAlertAction actionWithTitle:@"Нет"
                                                              style:UIAlertActionStyleDefault
                                                            handler:nil];
    
    [alertController customizationAlertView:@"Удалить фото?" byFont:20.f];
    
    [alertController addAction:alertActiionYes];
    [alertController addAction:alertActiionNo];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)deletePhoto
{
    NSInteger page = self.pageControl.currentPage;
    if ([self.addPhotos count] == 0) {
        [self.photos removeObjectAtIndex:page];
        FIRDatabaseReference *ref = [[FIRDatabase database]reference];
        NSMutableArray *updatePhotos = self.fireUser.photos;
        [updatePhotos removeObjectAtIndex:page + 1];
        [[[[[ref child:@"dataBase"] child:@"users"] child:self.fireUser.uid] child:@"photos"] setValue:updatePhotos];
    } else {
        [self.photos removeObjectAtIndex:page];
    }
    [self setupScroll];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
