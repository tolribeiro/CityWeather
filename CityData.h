//
//  CityData.h
//  CityWeather
//
//  Created by Tico on 7/22/16.
//  Copyright © 2016 Thiago Ribeiro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CityData : NSObject

@property (nonatomic, strong) NSString *cityName;
@property (nonatomic, strong) NSString *maxTemperature;
@property (nonatomic, strong) NSString *minTemperature;
@property (nonatomic, strong) NSString *weatherIcon;
@property (nonatomic, strong) NSString *weatherDescription;

@end
