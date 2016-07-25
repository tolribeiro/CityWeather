//
//  ViewController.m
//  CityWeather
//
//  Created by Tico on 7/21/16.
//  Copyright © 2016 Thiago Ribeiro. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MainViewController.h"
#import "WeatherAnnotation.h"
#import "AFNetworking.h"
#import "CityData.h"
#import "CityNamesViewController.h"
#import "Reachability.h"
#define _IN_LOCO_LATITUDE -8.08538950
#define _IN_LOCO_LONGITUDE -34.88618020
#define _SPAN 0.003f
#define _BASE_URL "http://api.openweathermap.org/data/2.5/find?"
#define _APP_ID "cbff5bd6991e55393d4f251ccac1892d"

@interface MainViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *addressActivityInd;
@property (strong, nonatomic) WeatherAnnotation *toAddPin;
@property (weak, nonatomic) NSString *openWeatherURL;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo"]];
    
    [_mapView setMapType:MKMapTypeStandard];
    [_mapView setZoomEnabled:YES];
    [_mapView setScrollEnabled:YES];

    [self settingInLocoPin];
    [self addGestureRecogniserToMapView];
}

-(BOOL) checkInternetConnection
{
    return [[Reachability reachabilityForInternetConnection]currentReachabilityStatus] == NotReachable ? NO : YES;
}

-(void)settingInLocoPin
{
    MKCoordinateRegion inLocoMedia = { {0.0, 0.0} , {0.0, 0.0} };
    
    inLocoMedia.center.latitude = _IN_LOCO_LATITUDE;
    inLocoMedia.center.longitude = _IN_LOCO_LONGITUDE;
    inLocoMedia.span.longitudeDelta = _SPAN;
    inLocoMedia.span.latitudeDelta = _SPAN;
    
    [_mapView setRegion:inLocoMedia animated:YES];
    
    WeatherAnnotation *inLocoAnnotattion = [[WeatherAnnotation alloc] init];
    inLocoAnnotattion.coordinate = inLocoMedia.center;
    
    [_mapView addAnnotation: inLocoAnnotattion];
    
    if([self checkInternetConnection]) {
        [self cleanTextFieldAndStartAnimatingAct];
        [self getAddressFrom:_IN_LOCO_LATITUDE And:_IN_LOCO_LONGITUDE];
    } else {
        _addressTextField.text = @"Sem conexão com a internet";
    }
}

-(void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    self.mapView.delegate = self;
}

-(MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    static NSString *reuseId = @"MainViewController";
    
    MKAnnotationView *myPinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
    
    myPinView.image = [UIImage imageNamed:@"customPin"];
    
    return myPinView;
}

- (void)addGestureRecogniserToMapView {
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(addPinToMap:)];
    longPressGesture.minimumPressDuration = 0.5;
    
    [self.mapView addGestureRecognizer:longPressGesture];
    
}

-(void) getAddressFrom:(double)lat And:(double)lon {
    
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:lat longitude:lon];
    
    [ceo reverseGeocodeLocation: loc completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] > 0) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            _addressTextField.text = placemark.name;
            [_addressActivityInd stopAnimating];
        } else {
            NSLog(@"%@", error.debugDescription);
        }
     }];
}

-(void)cleanTextFieldAndStartAnimatingAct
{
    _addressTextField.text = @"";
    [_addressActivityInd startAnimating];
}

- (void)addPinToMap:(UIGestureRecognizer *)gestureRecognizer
{
    
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    
    CLLocationCoordinate2D coordinateToBeAdded = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    _toAddPin = [[WeatherAnnotation alloc]init];
    
    _toAddPin.coordinate = coordinateToBeAdded;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView addAnnotation:_toAddPin];
    
    if([self checkInternetConnection]) {
        [self cleanTextFieldAndStartAnimatingAct];
        [self getAddressFrom:_toAddPin.coordinate.latitude And:_toAddPin.coordinate.longitude];
    } else {
        _addressTextField.text = @"Sem conexão com a internet";
    }
}

- (IBAction)searchForCities:(id)sender
{
    if (_toAddPin != nil) {
        _openWeatherURL = [NSString stringWithFormat:@"%slat=%f&lon=%f&=15&appid=%s", _BASE_URL, _toAddPin.coordinate.latitude, _toAddPin.coordinate.longitude, _APP_ID];
        [self startActivityAnimationDisableButtonAndDownload];
    } else {
        _openWeatherURL = [NSString stringWithFormat:@"%slat=%f&lon=%f&cnt=15&appid=%s", _BASE_URL, _IN_LOCO_LATITUDE, _IN_LOCO_LONGITUDE, _APP_ID];
        [self startActivityAnimationDisableButtonAndDownload];
    }
}

-(void) startActivityAnimationDisableButtonAndDownload
{
    [_activityIndicator startAnimating];
    [_searchButton setEnabled:NO];
    [self downloadCitiesJSON];
}

-(void) popsErrorAlertViewToTheUserWith:(NSString*)Message
{
    UIAlertController *errorWhenFecthingCities = [UIAlertController alertControllerWithTitle:@"Erro"
                                                                                     message:Message
                                                                              preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [errorWhenFecthingCities dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    [errorWhenFecthingCities addAction: ok];
    
    [self presentViewController:errorWhenFecthingCities animated:YES completion:nil];
}

-(void) downloadCitiesJSON
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:_openWeatherURL parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSDictionary *responseDict = responseObject;
        
        NSArray *listOfCities = [responseDict objectForKey:@"list"];
        
        NSMutableArray *resultArrayOfCities = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < [listOfCities count]; i++) {
            CityData *cityInfo = [[CityData alloc] init];
            cityInfo.cityName = [[listOfCities objectAtIndex:i] objectForKey:@"name"];
            cityInfo.minTemperature = [[[listOfCities objectAtIndex:i] objectForKey:@"main"] objectForKey:@"temp_min"];
            cityInfo.maxTemperature = [[[listOfCities objectAtIndex:i] objectForKey:@"main"] objectForKey:@"temp_max"];
            cityInfo.weatherIcon = [[[[listOfCities objectAtIndex:i] objectForKey:@"weather"] objectAtIndex:0] objectForKey:@"icon"];
            cityInfo.weatherDescription = [[[[listOfCities objectAtIndex:i] objectForKey:@"weather"] objectAtIndex:0] objectForKey:@"description"];
            [resultArrayOfCities addObject:cityInfo];
        }
        
        CityNamesViewController *cityNames = [self.storyboard instantiateViewControllerWithIdentifier:@"CityNames"];
        
        cityNames.cityNamesDict = resultArrayOfCities;
        
        [self.navigationController pushViewController:cityNames animated:YES];
        
        [_activityIndicator stopAnimating];
        
        [_searchButton setEnabled:YES];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
        [self checkInternetConnection] ? [self popsErrorAlertViewToTheUserWith:@"Falha ao buscar cidades"] : [self popsErrorAlertViewToTheUserWith:@"Favor verifique sua conexão"];
        
        [_activityIndicator stopAnimating];
        
        [_searchButton setEnabled:YES];
    }];
}


@end
