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
        static let routeLatitude       = "routeLatitude"
        static let routeLongitude      = "routeLongitude"
        static let title               = "title"
        static let isShowingDirections = "isShowingDirections"
        static let isDriving           = "isDriving"
    }
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var isShowingDirections: Bool
    var isDriving: Bool
    
    var routeAnnotationDictionaryRepresentation: [String : AnyHashable] {
        [
            RouteAnnotationKey.routeLatitude       : self.coordinate.latitude,
            RouteAnnotationKey.routeLongitude      : self.coordinate.longitude,
            RouteAnnotationKey.title               : self.title,
            RouteAnnotationKey.isShowingDirections : self.isShowingDirections,
            RouteAnnotationKey.isDriving           : self.isDriving
        ]
    }
    
    init(coordinate: CLLocationCoordinate2D, title: String?, isShowingDirections: Bool, isDriving: Bool) {
        self.coordinate          = coordinate
        self.title               = title
        self.isShowingDirections = isShowingDirections
        self.isDriving           = isDriving
    }
}


//MARK: - EXT: Convenience Initializer
extension RouteAnnotation {
    convenience init?(fromRouteAnnotationDictionary routeAnnotationDictionary: [String : Any]) {
        guard let routeLatitude       = routeAnnotationDictionary[RouteAnnotationKey.routeLatitude] as? Double,
              let routeLongitude      = routeAnnotationDictionary[RouteAnnotationKey.routeLongitude] as? Double,
              let isShowingDirections = routeAnnotationDictionary[RouteAnnotationKey.isShowingDirections] as? Bool,
              let isDriving           = routeAnnotationDictionary[RouteAnnotationKey.isDriving] as? Bool
        else {
            print("Failed to initialize RouteAnnotation model object")
            return nil
        }
        
        let title = routeAnnotationDictionary[RouteAnnotationKey.title] as? String ?? "Route"
        
        self.init(coordinate: CLLocationCoordinate2D(latitude: routeLatitude, longitude: routeLongitude), title: title, isShowingDirections: isShowingDirections, isDriving: isDriving)
    }
}
