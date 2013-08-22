//
//  ViewController.m
//  speedCam
//
//  Created by David Dreval on 07.02.13.
//  Copyright (c) 2013 David Dreval. All rights reserved.
//

#import "Annotation.h"
#import "ViewController.h"
#import  <QuartzCore/QuartzCore.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    firstFound = NO;
    NSString *file = [[NSBundle mainBundle] pathForResource:@"SpeedCamOnline.ru_2013-02-07_iGo_77Mos" ofType:@"txt"];
    NSString *str = [NSString stringWithContentsOfFile:file
                                              encoding:NSUTF8StringEncoding error:NULL];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[str componentsSeparatedByString:@"\n"]];
    [array removeObjectAtIndex:0];
    [array removeObjectAtIndex:array.count - 1];
    
    camImg = [UIImage imageNamed:@"cam.png"];
    
    mapView = [[MKMapView alloc] init];
    [mapView setDelegate:self];
    [mapView setZoomEnabled:YES];
    [mapView setScrollEnabled:YES];
    [mapView setMapType:MKMapTypeStandard];
    [mapView setShowsUserLocation:YES];
    [self setView:mapView];
    
    navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
    [navBar setBarStyle:UIBarStyleBlack];
    [navBar setTranslucent:YES];
    [mapView addSubview:navBar];
    
    speed = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 320, 40)];
    [speed setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [speed setBackgroundColor:[UIColor clearColor]];
    [speed setTextAlignment:NSTextAlignmentCenter];
    [speed setTextColor:[UIColor colorWithWhite:1 alpha:1]];
    [speed setFont:[UIFont fontWithName:@"Helvetica-Light" size:24]];
    [speed setShadowColor:[UIColor colorWithWhite:0 alpha:1]];
    [speed setShadowOffset:CGSizeMake(0, 1)];
    [navBar addSubview:speed];
    
    results = [[NSMutableArray alloc] init];
    for (NSString *string in array) {
        NSArray *camArray = [string componentsSeparatedByString:@","];
        NSNumber *lat = [camArray objectAtIndex:2];
        NSNumber *lon = [camArray objectAtIndex:1];
        CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue);
        NSString *name = [NSString stringWithFormat:@"Камера"];
        NSString *country = [NSString stringWithFormat:@"Тип камеры - %@", [camArray objectAtIndex:3]];
        Annotation *annotation = [[Annotation alloc] initWithName:name address:country coordinate:coordinates];
        [results addObject:annotation];
    }
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
}
-(void) locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    [self updateSpeed:newLocation];
}
- (void) updateSpeed: (CLLocation *) location {
    NSLog(@"updated");
    float kmphSpeed = location.speed * 3.6;
    [speed setText:[NSString stringWithFormat:@"%0.1f kmph", kmphSpeed]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    CGRect screen = [[UIScreen mainScreen] bounds];
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        [UIView animateWithDuration:duration animations:^(void) {
            [navBar setFrame:CGRectMake(0, 0, screen.size.height, 60)];
        }];
    }
    else {
        [UIView animateWithDuration:duration animations:^(void) {
            [navBar setFrame:CGRectMake(0, 0, screen.size.width, 80)];
        }];
    }
}

#pragma mark MapKit methods

- (void) mapView:(MKMapView *)mapViewSup didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (firstFound == NO) {
        MKCoordinateRegion mapRegion;
        mapRegion.center = mapView.userLocation.coordinate;
        mapRegion.span.latitudeDelta = 0.15;
        mapRegion.span.longitudeDelta = 0.15;
        [mapView setRegion:mapRegion animated: YES];
        firstFound = YES;
    }
       // [mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading];
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapViewSup {

}

- (void)mapView: (MKMapView*)_mapView regionDidChangeAnimated: (BOOL)animated
{
    [self filterAnnotations:results];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapViewSup viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString *identifier = @"MyLocation";
    if ([annotation isKindOfClass:[Annotation class]]) {
        MKAnnotationView *annotationView = (MKAnnotationView *) [mapViewSup dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            annotationView.image = camImg;
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        } else {
            annotationView.annotation = annotation;
        }
        
        return annotationView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapViewSup annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {

    NSLog(@"Tapped %@", view.annotation.title);
}

-(void)filterAnnotations:(NSArray *)placesToFilter{
    float iphoneScaleFactorLatitude = mapView.frame.size.width/26;
    float iphoneScaleFactorLongitude = mapView.frame.size.height/40;
    float latDelta=mapView.region.span.latitudeDelta/iphoneScaleFactorLatitude;
    float longDelta=mapView.region.span.longitudeDelta/iphoneScaleFactorLongitude;
    
    NSMutableArray *shopsToShow=[[NSMutableArray alloc] initWithCapacity:0];
    
    for (int i=0; i<[placesToFilter count]; i++) {
        Annotation *checkingLocation=[placesToFilter objectAtIndex:i];
        CLLocationDegrees latitude = checkingLocation.coordinate.latitude;
        CLLocationDegrees longitude = checkingLocation.coordinate.longitude;
        
        bool found=FALSE;
        for (Annotation *tempPlacemark in shopsToShow) {
            if(fabs(tempPlacemark.coordinate.latitude-latitude) < latDelta &&
               fabs(tempPlacemark.coordinate.longitude-longitude) <longDelta ){
                [mapView removeAnnotation:checkingLocation];
                found=TRUE;
                break;
            }
        }
        if (!found) {
            [shopsToShow addObject:checkingLocation];
            [mapView addAnnotation:checkingLocation];
        }
        
    }
}

@end
