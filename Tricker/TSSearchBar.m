//
//  TSSearchBar.m
//  Tricker
//
//  Created by Mac on 12.11.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "TSSearchBar.h"
#import "TSTrickerPrefixHeader.pch"

@implementation TSSearchBar

- (instancetype)initWithView:(UIView *)view
{
    self = [super init];
    if (self) {
        self = [[TSSearchBar alloc] initWithFrame:CGRectMake(30, - 20,
                                                             view.bounds.size.width - 40, 44)];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    
    self.searchBarStyle = UISearchBarStyleMinimal;
    self.tintColor = LIGHT_YELLOW_COLOR;
    UITextField *txtSearchField = [self valueForKey:@"_searchField"];
    txtSearchField.textColor = DARK_GRAY_COLOR;
}

@end
