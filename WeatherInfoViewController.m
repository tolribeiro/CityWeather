//
//  WeatherInfoViewController.m
//  CityWeather
//
//  Created by Tico on 7/22/16.
//  Copyright © 2016 Thiago Ribeiro. All rights reserved.
//

#import "WeatherInfoViewController.h"

#define _BASE_URL "http://openweathermap.org/img/w/"

@interface WeatherInfoViewController ()

@property (weak, nonatomic) IBOutlet UILabel *cityNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *weatherDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *minTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxTempLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeToFahButton;

@end

@implementation WeatherInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadInfoAboutCity];
}

-(void) loadInfoAboutCity
{
    _cityNameLabel.text = _cityData.cityName;
    
    _maxTempLabel.text = [NSString stringWithFormat:@"%@°", [self getStringTemperatureInCelsiusFrom:[_cityData.maxTemperature floatValue]]];
    
    _minTempLabel.text = [NSString stringWithFormat:@"%@°", [self getStringTemperatureInCelsiusFrom:[_cityData.minTemperature floatValue]]];
    
    _weatherDescriptionLabel.text = _cityData.weatherDescription;
    
    [self loadWeatherIcon];
}

-(void)loadWeatherIcon
{
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%s%@.png", _BASE_URL, _cityData.weatherIcon]]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                _iconImage.image = [UIImage imageWithData: data];
            }] resume];
}

-(NSString*)getStringTemperatureInCelsiusFrom:(float)numberInFloat
{
    numberInFloat -= 273;
    
    long temp_max_celsius_round = lroundf(numberInFloat);
    
    return [NSString stringWithFormat:@"%ld",temp_max_celsius_round];
}

-(NSString*)getTemperatureInFahrFromString:(NSString*)tempinCelsius
{
    int tempInF = [tempinCelsius intValue]*1.8 + 32;
    NSLog(@"%d", tempInF);
    return [NSString stringWithFormat:@"%d", tempInF];
}

- (IBAction)changeToFahrenheit:(id)sender
{
    _minTempLabel.text = [NSString stringWithFormat:@"%@°", [self getTemperatureInFahrFromString:_minTempLabel.text]];
    _maxTempLabel.text = [NSString stringWithFormat:@"%@°", [self getTemperatureInFahrFromString:_maxTempLabel.text]];
    
    [_changeToFahButton setEnabled:NO];
}

@end
