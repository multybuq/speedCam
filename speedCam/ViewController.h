//
//  ViewController.h
//  speedCam
//
//  Created by David Dreval on 07.02.13.
//  Copyright (c) 2013 David Dreval. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate> {
    MKMapView *mapView;
    NSMutableArray *results;
    UIImage *camImg;
    BOOL firstFound;
    CLLocationManager *locationManager;
    UILabel *speed;
    UINavigationBar *navBar;
}

@end
