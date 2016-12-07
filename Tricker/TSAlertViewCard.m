//
//  TSAlertViewCard.m
//  Tricker
//
//  Created by Mac on 26.11.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "TSAlertViewCard.h"
#import "TSCardsViewController.h"

@implementation TSAlertViewCard

- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)setup {
    // Shadow
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.33;
    self.layer.shadowOffset = CGSizeMake(0, 1.5);
    self.layer.shadowRadius = 4.0;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    // Corner Radius
    self.layer.cornerRadius = 10.0;
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


+ (instancetype)initAlertViewCard
{
    
    TSAlertViewCard *view = nil;
    
    UINib *nib = [UINib nibWithNibName:@"TSAlertViewCard" bundle:nil];
    view = [nib instantiateWithOwner:self options:nil][0];
    view.frame = CGRectMake(47, -50, 225, 115);
    
    return view;
    
}


- (IBAction)buttonsAction:(UIButton *)sender
{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CardsStoryboard" bundle:[NSBundle mainBundle]];
    TSCardsViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"TSCardsViewController"];
    
    switch (sender.tag) {
        case 1:
            [controller changeActionAlertView];
            break;
        case 2:
            [controller repeatActionAlertView];
            break;
        default:
            break;
    }
    
}


@end
