//
//  RouteAnnotation.swift
//  MapShare
//
//  Created by Chase on 5/3/23.
//

import MapKit
import CoreLocation

class RouteAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?) {
        self.coordinate = coordinate
        self.title      = title
    }
}
