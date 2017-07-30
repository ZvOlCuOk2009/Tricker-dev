//
//  TSMapViewController.m
//  Tricker
//
//  Created by Admin on 30.07.17.
//  Copyright © 2017 Mac. All rights reserved.
//

#import "TSMapViewController.h"
#import "TSTrickerPrefixHeader.pch"
#import <GoogleMaps/GoogleMaps.h>
//#import <GooglePlaces/GooglePlaces.h>

@interface TSMapViewController ()

@property (strong, nonatomic) GMSMapView *mapView;

@end

@implementation TSMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setFrame:CGRectMake(0, 0, self.view.frame.size.width, 80.0)];
}

- (void)loadView {
    
    [super loadView];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:6];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    
    
//    GMSPlacesClient *placeClient = [GMSPlacesClient sharedClient];
//    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
//    filter.type = kGMSPlacesAutocompleteTypeFilterEstablishment;
//    
//    [placeClient autocompleteQuery:@"текст"
//                            bounds:nil
//                            filter:filter
//                          callback:^(NSArray *results, NSError *error) {
//                              if (error != nil) {
//                                  NSLog(@"Autocomplete error %@", [error localizedDescription]);
//                                  return;
//                              }
//                              
//                              for (GMSAutocompletePrediction* result in results) {
//                                  //NSLog(@"Result '%@'", result.attributedFullText.string);
////                                  [placeName addObject:[NSString stringWithFormat:@"%@",result.attributedFullText.string]];
////                                  [placeID addObject:[NSString stringWithFormat:@"%@",result.placeID]];
//                                  NSLog(@"result %@", result.attributedFullText.string);
//                                  NSLog(@"%@", result.placeID);
//                              }
//                              
//                          }];

    self.mapView.myLocationEnabled = YES;
    self.view = self.mapView;
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = self.mapView;
    
    
    

    NSArray *items = @[@"Станд", @"Гибр", @"Спутн"];

    UISegmentedControl *typeMapSegmentedControl = [[UISegmentedControl alloc] initWithItems:items];
    typeMapSegmentedControl.frame = CGRectMake(170, 398, 140, 28);
    typeMapSegmentedControl.tintColor = DARK_GRAY_COLOR;
    typeMapSegmentedControl.layer.masksToBounds = YES;
    typeMapSegmentedControl.selectedSegmentIndex = 0;
    [typeMapSegmentedControl addTarget:self
                                action:@selector(segmentedControlValueDidChange:)
                      forControlEvents:UIControlEventValueChanged];
    [self.mapView addSubview:typeMapSegmentedControl];
}

- (void)segmentedControlValueDidChange:(UISegmentedControl *)sender {
    
    NSInteger selectSegment = sender.selectedSegmentIndex;
    switch (selectSegment) {
        case 0:
            self.mapView.mapType = kGMSTypeNormal;
            break;
        case 1:
            self.mapView.mapType = kGMSTypeHybrid;
            break;
        case 2:
            self.mapView.mapType = kGMSTypeSatellite;
            break;
        default:
            break;
    }
}

- (void)addCustomNavBar {
    UIView *arrowNavBar = [[UIView alloc] initWithFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, self.view.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    arrowNavBar.backgroundColor = YELLOW_COLOR;
//    UIImage *backButtonBackgroundImage = [UIImage imageNamed:@"535x220.png"];
//    CGRect rect = CGRectMake(0,0,80,33);
//    CGSize newSize = CGSizeMake(80, 33);
//    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
//    [backButtonBackgroundImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
//    backButtonBackgroundImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    UIImageView *imV = [[UIImageView alloc] initWithImage:backButtonBackgroundImage];
//    
//    // The background should be pinned to the left and not stretch
//    backButtonBackgroundImage = [backButtonBackgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, -10, 0)];
//    UILabel *lt = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40.0f)];
//    lt.text = [self.dict objectForKey:@"name"];
//    lt.textColor = [UIColor whiteColor];
//    lt.font = [UIFont systemFontOfSize:22];
//    [arrowNavBar addSubview:imV];
//    [arrowNavBar addSubview:lt];
//    
//    self.navigationItem.titleView = lt;
//    UIButton * backButton = [[UIButton alloc] initWithFrame:rect];
//    [backButton setBackgroundImage:backButtonBackgroundImage forState:UIControlStateNormal];
//    [backButton addTarget:self action:@selector(toBack) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
//                                                                                    target:nil action:nil];
//    negativeSpacer.width = -8;
//    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, [[UIBarButtonItem alloc] initWithCustomView:backButton], nil] animated:NO];
//    rect = CGRectMake(0,0,33,33);
//    UIButton *changeNumberViewButton = [[UIButton alloc] initWithFrame:rect];
//    UIImage *changeNumberViewButtonBackgroundImage = [UIImage imageNamed:@"ic_action_streams_switcher.png"];
//    newSize = CGSizeMake(33, 33);
//    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
//    context = UIGraphicsGetCurrentContext();
//    [changeNumberViewButtonBackgroundImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
//    [changeNumberViewButton setBackgroundImage:changeNumberViewButtonBackgroundImage forState:UIControlStateNormal];
//    [changeNumberViewButton addTarget:self action:@selector(pressedSplitterItem) forControlEvents:UIControlEventTouchUpInside];
//    changeNumberViewButton.frame = rect;
//    UIBarButtonItem *rightSpacer = [[UIBarButtonItem alloc]
//                                    initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
//                                    target:nil
//                                    action:nil];
//    rightSpacer.width = 20;
//    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:changeNumberViewButton] , rightSpacer, nil] animated:NO];
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
