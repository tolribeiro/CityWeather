//
//  WeatherAnnotation.h
//  CityWeather
//
//  Created by Tico on 7/21/16.
//  Copyright © 2016 Thiago Ribeiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface WeatherAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
}

@property(nonatomic, assign) CLLocationCoordinate2D coordinate;

@end
