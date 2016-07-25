//
//  CityNamesViewController.m
//  CityWeather
//
//  Created by Tico on 7/22/16.
//  Copyright © 2016 Thiago Ribeiro. All rights reserved.
//

#import "CityNamesViewController.h"
#import "WeatherInfoViewController.h"

@interface CityNamesViewController ()

@end

@implementation CityNamesViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_cityNamesDict count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CityName"];

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text = [[_cityNamesDict objectAtIndex:indexPath.row] valueForKey:@"cityName"];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WeatherInfoViewController *detailsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InfoDetails"];
    
    detailsViewController.cityData = [_cityNamesDict objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:detailsViewController animated:YES];
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}


@end
