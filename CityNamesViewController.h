//
//  CityNamesViewController.h
//  CityWeather
//
//  Created by Tico on 7/22/16.
//  Copyright © 2016 Thiago Ribeiro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CityNamesViewController : UIViewController <UITableViewDataSource>

@property NSMutableArray *cityNamesDict;
@property NSArray *cityNamesValues;

@end
