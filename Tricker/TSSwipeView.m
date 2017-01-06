
//  TSSwipeView.m
//  Tricker
//
//  Created by Mac on 24.11.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "TSSwipeView.h"
#import "TSCardsViewController.h"
#import "TSChatViewController.h"
#import "TSChatsTableViewController.h"
#import "TSTabBarViewController.h"
#import "TSViewCell.h"
#import "TSPhotoView.h"
#import "TSTrickerPrefixHeader.pch"

NSString *const TSSwipeViewInterlocutorNotification = @"TSSwipeViewInterlocutorNotification";
NSInteger recognizer;

@interface TSSwipeView () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSArray *allKeys;

@property (strong, nonatomic) NSMutableArray *updateDataSource;
@property (strong, nonatomic) NSMutableArray *getParameters;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *backgroundTableView;

@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@property (strong, nonatomic) TSPhotoView *photoView;
@property (strong, nonatomic) NSString *photosView;

@property (assign, nonatomic) NSInteger counter;

@end

@implementation TSSwipeView

- (void)drawRect:(CGRect)rect {
    
    [self awakeFromNib];
    
    self.dataSource = @[@"Ищу", @"Возраст", @"С целью", @"Рост", @"Вес", @"Фигура", @"Глаза", @"Волосы", @"Отношения", @"Дети", @"Доход", @"Образование", @"Жильё", @"Автомобиль", @"Отношение к курению", @"Алкоголь"];
    self.counter = 0;
    
    self.updateDataSource = [NSMutableArray array];
    self.getParameters = [NSMutableArray array];
    
    NSMutableArray *tempArrayDataSource = [NSMutableArray array];
    NSMutableArray *tempArrayGetParameters = [NSMutableArray array];
    
    for (int i = 0; i < 16; i++) {
        NSString *cap = @"";
        [tempArrayDataSource addObject:cap];
        [tempArrayGetParameters addObject:cap];
    }
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(handleSingleTap:)];
    self.tapGesture.delegate = self;
    self.tapGesture.enabled = NO;
    [self addGestureRecognizer:self.tapGesture];
    
    self.tableView.allowsSelection = NO;
    [self.tableView setShowsVerticalScrollIndicator:NO];
    
    self.allKeys = [self.parameterUser allKeys];
    
    //наполнение массивов заголовками и данными
    
    [tempArrayDataSource insertObject:@"Анкета" atIndex:0];
    [tempArrayGetParameters addObject:@""];
    
    for (int i = 0; i < [self.parameterUser count]; i++) {
        
        NSString *key = [self.allKeys objectAtIndex:i];
        NSString *shortKey = [key substringFromIndex:3];
        NSInteger index = [shortKey integerValue];
        
        NSString *parameter = [self.parameterUser objectForKey:key];
        
        if ([parameter isEqualToString:@"man"]) {
            parameter = @"Парня";
        } else if ([parameter isEqualToString:@"woman"]) {
            parameter = @"Девушку";
        } else if ([parameter isEqualToString:@"man woman"]) {
            parameter = @"Парня и девушку";
        }
        
        //добавление тайтлов и параметров в промежуточные массивы
        
        NSString *title = [self.dataSource objectAtIndex:index - 1];
        
        [tempArrayDataSource insertObject:title atIndex:index];
        [tempArrayGetParameters insertObject:parameter atIndex:index];
        
    }

    //добавление тайтлов и параметров в массивы по пордковым номера
    
    NSInteger counterDSArray = 0;
    NSInteger counterParamArray = 0;
    
    for (NSString *title in tempArrayDataSource) {
        if (![title isEqualToString:@""]) {
            [self.updateDataSource addObject:title];
        }
        counterDSArray++;
    }
    
    for (NSString *parameter in tempArrayGetParameters) {
        if (![parameter isEqualToString:@""] || counterParamArray == 0) {
            [self.getParameters addObject:parameter];
        }
        counterParamArray++;
    }
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (IS_IPHONE_4) {
            
            self.photosView = kTSPhotoView;
            
        } else if (IS_IPHONE_5) {
            
            
        } else if (IS_IPHONE_6) {
            
            
        } else if (IS_IPHONE_6_PLUS) {
            
            self.photosView = kTSPhotoView_6_Plus;
        }
    }
    
}


- (void)setup {
   
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.33;
    self.layer.shadowOffset = CGSizeMake(0, 1.5);
    self.layer.shadowRadius = 7.0;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}


+ (instancetype)initProfileView
{
    
    TSSwipeView *view = nil;
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (IS_IPHONE_4) {
            
            UINib *nib = [UINib nibWithNibName:@"TSSwipeView" bundle:nil];
            view = [nib instantiateWithOwner:self options:nil][0];
            view.frame = kTSSwipeViewFrame
            
        } else if (IS_IPHONE_5) {
            

            
        } else if (IS_IPHONE_6) {

            
            
        } else if (IS_IPHONE_6_PLUS) {
            
            UINib *nib = [UINib nibWithNibName:@"TSSwipeView6plus" bundle:nil];
            view = [nib instantiateWithOwner:self options:nil][0];
            view.frame = kTSSwipeView6PlusFrame
        }
    }
    
    return view;
    
}


+ (instancetype)initDetailView
{
    
    TSSwipeView *view = nil;
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (IS_IPHONE_4) {
            
            UINib *nib = [UINib nibWithNibName:@"TSDetailView" bundle:nil];
            view = [nib instantiateWithOwner:self options:nil][0];
            view.frame = CGRectMake(10, 74, 300, 352);
            
        } else if (IS_IPHONE_5) {
            
            
            
        } else if (IS_IPHONE_6) {
            
            
            
        } else if (IS_IPHONE_6_PLUS) {
            
        }
    }
    
    return view;
    
}



- (IBAction)photoActionButton:(id)sender
{
    self.photoView = [[[NSBundle mainBundle] loadNibNamed:self.photosView
                                                    owner:self options:nil] firstObject];
    
    [self addSubview:self.photoView];
    [self.photoView setFrame:CGRectMake(0.0f, self.photoView.frame.size.height,
                                   self.photoView.frame.size.width, self.photoView.frame.size.height)];
    [UIView beginAnimations:@"animateView" context:nil];
    [UIView setAnimationDuration:0.3];
    [self.photoView setFrame:CGRectMake(0.0f, 0.0f, self.photoView.frame.size.width, self.photoView.frame.size.height)];
    [UIView commitAnimations];

    self.photoView.photos = self.photos;
}


- (IBAction)chatActionButton:(id)sender
{
    
    if (recognizer == 2) {
        
        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:0.7
              initialSpringVelocity:0.6
                            options:0
                         animations:^{
                             self.frame = CGRectMake(10, 480, self.frame.size.width, self.frame.size.height);
                         } completion:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removeFromSuperview];
        });
        
        recognizer = 0;
        
    } else {
        
        TSTabBarViewController *tabBarController = (TSTabBarViewController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
        tabBarController.selectedIndex = 3;
        
        recognizer = 1;
        
        CGSize newSize = CGSizeMake(100, 100);
        
        UIGraphicsBeginImageContext(newSize);
        [self.interlocutorAvatar drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage *miniAvatar = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData *dataAvatar = UIImagePNGRepresentation(miniAvatar);
        NSString *stringAvatar = [dataAvatar base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        [userDefault setObject:stringAvatar forKey:@"intelocAvatar"];
        [userDefault setObject:self.interlocutorUid forKey:@"intelocID"];
        [userDefault setObject:self.interlocutorName forKey:@"interlocName"];
        [userDefault synchronize];
        
    }
    
}


//разворот карточки на 180 градусов

- (IBAction)parametersActionButton:(id)sender
{
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromRight forView:self cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    [UIView commitAnimations];
    
    [self.tableView reloadData];
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.backgroundTableView.alpha = 1;
                         self.tableView.alpha = 1;
                     }];
    
    self.tapGesture.enabled = YES;
    
}


//возвращение карточки в исходное положение


- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromLeft forView:self cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    [UIView commitAnimations];
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.backgroundTableView.alpha = 0;
                         self.tableView.alpha = 0;
                     }];

    self.tapGesture.enabled = NO;
    
}


#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.getParameters count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *identifier = @"cell";
    
    TSViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TSViewCell" owner:self options:nil] firstObject];
    }
    
    NSInteger index = indexPath.row;
    NSString *title = [self.updateDataSource objectAtIndex:index];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@", title];
    
    if (indexPath.row == 0) {
        cell.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.f];
        cell.parameterLabel.text = @"";
    } else {
        
        NSString *parameter = [self.getParameters objectAtIndex:index];
        cell.parameterLabel.text = [NSString stringWithFormat:@"%@", parameter];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
