//
//  RouteAnnotation.swift
//  MapShare
//
//  Created by Chase on 5/3/23.
//

import MapKit
import CoreLocation

class RouteAnnotation: NSObject, MKAnnotation {
    
    enum RouteAnnotationKey {
        static let routeLatitude  = "routeLatitude"
        static let routeLongitude = "routeLongitude"
        static let title          = "title"
    }
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    var routeAnnotationDictionaryRepresentation: [String : AnyHashable] {
        [
            RouteAnnotationKey.routeLatitude  : self.coordinate.latitude,
            RouteAnnotationKey.routeLongitude : self.coordinate.longitude,
            RouteAnnotationKey.title          : self.title
        ]
    }
    
    init(coordinate: CLLocationCoordinate2D, title: String?) {
        self.coordinate = coordinate
        self.title      = title
    }
}


//MARK: - EXT: Convenience Initializer
extension RouteAnnotation {
    convenience init?(fromRouteAnnotationDictionary routeAnnotationDictionary: [String : Any]) {
        guard let routeLatitude  = routeAnnotationDictionary[RouteAnnotationKey.routeLatitude] as? Double,
              let routeLongitude = routeAnnotationDictionary[RouteAnnotationKey.routeLongitude] as? Double else {
            print("Failed to initialize RouteAnnotation model object")
            return nil
        }
        
        let title = routeAnnotationDictionary[RouteAnnotationKey.title] as? String ?? "Route"
        
        self.init(coordinate: CLLocationCoordinate2D(latitude: routeLatitude, longitude: routeLongitude), title: title)
    }
}
