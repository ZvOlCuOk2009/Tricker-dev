//
//  TSSitysViewController.m
//  Tricker
//
//  Created by Mac on 10.11.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "TSSitysViewController.h"
#import "TSProfileTableViewController.h"
#import "TSSearchBar.h"
#import "TSTableViewCell.h"
#import "TSTrickerPrefixHeader.pch"

#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>

@interface TSSitysViewController () <UISearchBarDelegate>

@property (strong, nonatomic) GMSPlacesClient *placesClient;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *searchCityes;

@end

@implementation TSSitysViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureController];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    [backItem setImage:[UIImage imageNamed:@"back"]];
    [backItem setTintColor:DARK_GRAY_COLOR];
    self.navigationItem.leftBarButtonItem = backItem;
    
    [backItem setTarget:self];
    [backItem setAction:@selector(cancelInteraction)];
}


- (void)cancelInteraction
{
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0]
                                          animated:YES];
}


#pragma mark - configure the controller


- (void)configureController
{
    
    UIImage *imageBack = [UIImage imageNamed:@"back"];
    [self.navigationItem.leftBarButtonItem setBackButtonBackgroundImage:imageBack forState:UIControlStateNormal barMetrics:0];
    
    [self.tableView setSeparatorColor:DARK_GRAY_COLOR];
    self.placesClient = [[GMSPlacesClient alloc] init];
    
    TSSearchBar *searchBar = [[TSSearchBar alloc] initWithView:self.view];
    self.navigationItem.titleView = searchBar;
    searchBar.autocorrectionType = NO;
    searchBar.delegate = self;

    
}


-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self placeAutocomplete:searchText];
}


#pragma mark -  UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchCityes count];
}

- (TSTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    TSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[TSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


- (void)configureCell:(TSTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray *location = [self parsingJSONAutocompletePrediction:indexPath];
    NSString *city = [location objectAtIndex:0];
    NSString *region = [location objectAtIndex:1];
    
    cell.cityLabel.textColor = DARK_GRAY_COLOR;
    cell.cityLabel.text = [NSString stringWithFormat:@"%@, %@", city, region];
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray *location = [self parsingJSONAutocompletePrediction:indexPath];
    NSString *city = [location objectAtIndex:0];
    TSProfileTableViewController *controller = [self.navigationController.viewControllers objectAtIndex:0];
    controller.selectCity = city;
    [self.navigationController popToViewController:controller animated:YES];
    
}


- (NSArray *)parsingJSONAutocompletePrediction:(NSIndexPath *)indexPath
{
    
    GMSAutocompletePrediction *autocompletePrediction = [self.searchCityes objectAtIndex:indexPath.row];
    NSAttributedString *attributedStringCity = autocompletePrediction.attributedPrimaryText;
    NSAttributedString *attributedStringRegion = autocompletePrediction.attributedSecondaryText;
    NSString *city = [attributedStringCity string];
    NSString *region = [attributedStringRegion string];
    NSArray *location = @[city, region];
    return location;
    
}


- (void)placeAutocomplete:(NSString *)searchText
{
    
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.type = kGMSPlacesAutocompleteTypeFilterCity;
    
    
    [self.placesClient autocompleteQuery:searchText
                              bounds:nil
                              filter:filter
                            callback:^(NSArray *results, NSError *error) {
                                if (error != nil) {
                                    NSLog(@"Autocomplete error %@", [error localizedDescription]);
                                    return;
                                }
                                
                                for (GMSAutocompletePrediction* result in results) {
                                    NSLog(@"Result '%@' with placeID %@", result.attributedFullText.string, result.placeID);
                                }
                                
                                self.searchCityes = results;
                                [self.tableView reloadData];
                            }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


@end
