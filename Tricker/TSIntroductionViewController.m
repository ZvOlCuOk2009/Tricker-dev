//
//  TSIntroductionViewController.m
//  Tricker
//
//  Created by Mac on 21.01.17.
//  Copyright © 2017 Mac. All rights reserved.
//

#import "TSIntroductionViewController.h"
#import "TSTrickerPrefixHeader.pch"

@interface TSIntroductionViewController ()

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSArray *images;
@property (strong, nonatomic) NSArray *texts;
@property (strong, nonatomic) UILabel *textLabel;
@property (assign, nonatomic) NSInteger page;
@property (assign, nonatomic) NSInteger offsetHorizontalImageView;

@end

@implementation TSIntroductionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (IS_IPHONE_4) {
            self.scrollView.frame = CGRectMake(0, 0, 320, 480);
            self.offsetHorizontalImageView = 35;
        } else if (IS_IPHONE_5) {
            self.scrollView.frame = CGRectMake(0, 0, 320, 568);
            self.offsetHorizontalImageView = 30;
        } else if (IS_IPHONE_6) {
            self.scrollView.frame = CGRectMake(0, 0, 375, 667);
            self.offsetHorizontalImageView = 30;
        } else if (IS_IPHONE_6_PLUS) {
            self.scrollView.frame = CGRectMake(0, 0, 414, 736);
            self.offsetHorizontalImageView = 30;
        }
        
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (IS_IPAD_2) {
            self.scrollView.frame = CGRectMake(0, 0, 768, 1024);
            self.offsetHorizontalImageView = 30;
        }
    }
    
    UIImage *image_introduction_1 = [UIImage imageNamed:@"image_introduction_1"];
    UIImage *image_introduction_2 = [UIImage imageNamed:@"image_introduction_2"];
    UIImage *image_introduction_3 = [UIImage imageNamed:@"image_introduction_3"];
    UIImage *image_introduction_4 = [UIImage imageNamed:@"image_introduction_4"];
    UIImage *image_introduction_5 = [UIImage imageNamed:@"image_introduction_5"];
    
    UIImage *image_introduction_iphone4_1 = [UIImage imageNamed:@"image_introduction_iphone4_1"];
    UIImage *image_introduction_iphone4_2 = [UIImage imageNamed:@"image_introduction_iphone4_2"];
    UIImage *image_introduction_iphone4_3 = [UIImage imageNamed:@"image_introduction_iphone4_3"];
    UIImage *image_introduction_iphone4_4 = [UIImage imageNamed:@"image_introduction_iphone4_4"];
    UIImage *image_introduction_iphone4_5 = [UIImage imageNamed:@"image_introduction_iphone4_5"];
    
    UIImage *image_introduction_ipad_1 = [UIImage imageNamed:@"image_introduction_ipad_1"];
    UIImage *image_introduction_ipad_2 = [UIImage imageNamed:@"image_introduction_ipad_2"];
    UIImage *image_introduction_ipad_3 = [UIImage imageNamed:@"image_introduction_ipad_3"];
    UIImage *image_introduction_ipad_4 = [UIImage imageNamed:@"image_introduction_ipad_4"];
    UIImage *image_introduction_ipad_5 = [UIImage imageNamed:@"image_introduction_ipad_5"];
    
    NSString *textOnePage = @"Укажите свой пол и дату рождения, что бы другие пользователи могли увидеть Вас...";
    NSString *textTwoPage = @"...прокрутите вниз и сохраните внесенные изменения...";
    NSString *textThreePage = @"...а также на экране настроек, укажите пол и возраст пользователя которого ищите,";
    NSString *textForePage = @"и не забудьте сохранить добавленные даные...";
    NSString *textFivePage = @"Всех найденных пользователей Вы сможете посмотреть простым смахиванием";
    NSString *textSixPage = @"Так же двойным ксанием, Вы можете ставить лайки понравимшимся пользователям. О чем их уведомит приложение";
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (IS_IPHONE_4) {
            self.images = @[image_introduction_iphone4_1, image_introduction_iphone4_2, image_introduction_iphone4_3, image_introduction_iphone4_4, image_introduction_iphone4_5];
        } else if (IS_IPHONE_5) {
            self.images = @[image_introduction_1, image_introduction_2, image_introduction_3, image_introduction_4, image_introduction_5];
        } else if (IS_IPHONE_6) {
            self.images = @[image_introduction_1, image_introduction_2, image_introduction_3, image_introduction_4, image_introduction_5];
        } else if (IS_IPHONE_6_PLUS) {
            self.images = @[image_introduction_1, image_introduction_2, image_introduction_3, image_introduction_4, image_introduction_5];
        }
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (IS_IPAD_2) {
            self.images = @[image_introduction_ipad_1, image_introduction_ipad_2, image_introduction_ipad_3, image_introduction_ipad_4, image_introduction_ipad_5];
        } else if (IS_IPAD_AIR) {
            self.images = @[image_introduction_ipad_1, image_introduction_ipad_2, image_introduction_ipad_3, image_introduction_ipad_4, image_introduction_ipad_5];
        } else if (IS_IPAD_PRO) {
            self.images = @[image_introduction_ipad_1, image_introduction_ipad_2, image_introduction_ipad_3, image_introduction_ipad_4, image_introduction_ipad_5];
            
        }
    }
    
    self.texts = @[textOnePage, textTwoPage, textThreePage, textForePage, textFivePage];
    
    UIButton *cancelButton = [[UIButton alloc] init];
    cancelButton.frame = CGRectMake(self.view.frame.size.width - 50, 25, 25, 25);
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(pressedCancelButton)
           forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    
    UIButton *arrowBackButton = [[UIButton alloc] init];
    arrowBackButton.frame = CGRectMake(25, self.view.frame.size.height - 35, 25, 25);
    [arrowBackButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [arrowBackButton addTarget:self action:@selector(pressedArrowBackButton)
              forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:arrowBackButton];
    
    UIButton *arrowNextButton = [[UIButton alloc] init];
    arrowNextButton.frame = CGRectMake(self.view.frame.size.width - 50, self.view.frame.size.height - 35,25, 25);
    [arrowNextButton setBackgroundImage:[UIImage imageNamed:@"next_cell"] forState:UIControlStateNormal];
    [arrowNextButton addTarget:self action:@selector(pressedArrowNextButton)
              forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:arrowNextButton];
    
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.frame = CGRectMake(50, self.view.frame.size.height - 80, self.view.frame.size.width - 100, 100);
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.numberOfLines = 0;
    [self.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]];
    [self.textLabel setTextColor:DARK_GRAY_COLOR];
    [self.textLabel setText:[self.texts objectAtIndex:0]];
    [self.view addSubview:self.textLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollView

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self setupScroll];
}


- (void)setupScroll {
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * [self.images count], self.scrollView.bounds.size.height);
    
    for (int i = 0; i < [self.images count]; i++) {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(i * self.scrollView.bounds.size.width,
                                                                               0 * self.scrollView.bounds.size.height,
                                                                               self.scrollView.bounds.size.width,
                                                                               self.scrollView.bounds.size.height)];
        view.backgroundColor = [UIColor clearColor];
        
        view.contentMode = UIViewContentModeScaleAspectFill;
        view.clipsToBounds = YES;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.offsetHorizontalImageView, 53, view.frame.size.width - (self.offsetHorizontalImageView * 2), view.frame.size.height - 106)];
        [imageView setImage:[self.images objectAtIndex:i]];
        imageView.layer.cornerRadius = 10;
        imageView.layer.masksToBounds = YES;
        [view addSubview:imageView];
        [self.scrollView addSubview:view];
    }
}

- (void)setText
{
    NSString *text = [self.texts objectAtIndex:self.page];
    [self.textLabel setText:text];
}

- (void)pressedCancelButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)pressedArrowBackButton
{
    NSInteger currentPage = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    CGFloat weight = self.scrollView.frame.size.width;
    NSInteger backPage;
    if (currentPage > 0) {
        backPage = (weight * currentPage) - weight;
    } else {
        backPage = 0;
    }
    CGPoint point = CGPointMake(backPage, 0);
    [self.scrollView setContentOffset:point animated:YES];
    self.page = backPage / weight;
    [self setText];
}

- (void)pressedArrowNextButton
{
    NSInteger currentPage = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    CGFloat weight = self.scrollView.frame.size.width;
    NSInteger nextPage;
    if (currentPage < [self.texts count]) {
        nextPage = (weight * currentPage) + weight;
    } else {
        nextPage = currentPage * weight;
    }
    CGPoint point = CGPointMake(nextPage, 0);
    [self.scrollView setContentOffset:point animated:YES];
    self.page = nextPage / weight;
    [self setText];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger currentPage = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    self.page = currentPage;
    [self setText];
}

@end
