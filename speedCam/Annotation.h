//
//  Annotation.h
//  anywayanyday test
//
//  Created by David Dreval on 28.01.13.
//  Copyright (c) 2013 David Dreval. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Annotation : NSObject <MKAnnotation>

- (id) initWithName:(NSString *)name address:(NSString *)address coordinate:(CLLocationCoordinate2D)coordinates;
- (MKMapItem *)mapItem;

@end
