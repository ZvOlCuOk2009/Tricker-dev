//
//  TSPhotoZoomViewController.m
//  Tricker
//
//  Created by Mac on 06.01.17.
//  Copyright © 2017 Mac. All rights reserved.
//

#import "TSPhotoZoomViewController.h"

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
    
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * self.currentPage, 0.0) animated:YES];

}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self setupScroll];
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


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    self.pageControl.currentPage = self.scrollView.contentOffset.x / pageWidth;
}


- (IBAction)cancelButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)deleteButton:(id)sender
{

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
