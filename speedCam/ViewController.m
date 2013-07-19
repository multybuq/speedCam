//
//  ViewController.m
//  speedCam
//
//  Created by David Dreval on 07.02.13.
//  Copyright (c) 2013 David Dreval. All rights reserved.
//

#import "Annotation.h"
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *file = [[NSBundle mainBundle] pathForResource:@"SpeedCamOnline.ru_2013-02-07_iGo_77Mos" ofType:@"txt"];
    NSString *str = [NSString stringWithContentsOfFile:file
                                              encoding:NSUTF8StringEncoding error:NULL];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[str componentsSeparatedByString:@"\n"]];
    NSLog(@"%@", [array objectAtIndex:0]);
    NSLog(@"str: %@", array);
    [array removeObjectAtIndex:0];
    [array removeObjectAtIndex:array.count - 1];
    
    mapView = [[MKMapView alloc] init];
    [mapView setDelegate:self];
    [mapView setZoomEnabled:YES];
    [mapView setScrollEnabled:YES];
    [mapView setMapType:MKMapTypeStandard];
    [mapView setShowsUserLocation:YES];
    [self setView:mapView];
    
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
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark MapKit methods

- (void) mapView:(MKMapView *)mapViewSup didUpdateUserLocation:(MKUserLocation *)userLocation {
        MKCoordinateRegion mapRegion;
        mapRegion.center = mapView.userLocation.coordinate;
        mapRegion.span.latitudeDelta = 0.05;
        mapRegion.span.longitudeDelta = 0.05;
        [mapView setRegion:mapRegion animated: NO];
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapViewSup {
    NSLog(@"did load map - %@", results);
    for (Annotation *annotation in mapView.annotations) {
        [mapView removeAnnotation:annotation];
    }
    
    for (Annotation *resAnnotation in results) {
        [mapView addAnnotation:resAnnotation];
    }
}

- (void) mapView:(MKMapView *)mapViewSup regionDidChangeAnimated:(BOOL)animated {

}

- (MKAnnotationView *)mapView:(MKMapView *)mapViewSup viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString *identifier = @"MyLocation";
    if ([annotation isKindOfClass:[Annotation class]]) {
        
        MKAnnotationView *annotationView = (MKAnnotationView *) [mapViewSup dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            annotationView.image = [UIImage imageNamed:@"cam.png"];
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

@end
