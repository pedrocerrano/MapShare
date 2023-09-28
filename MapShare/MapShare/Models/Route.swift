//
//  RouteAnnotation.swift
//  MapShare
//
//  Created by Chase on 5/3/23.
//

import MapKit
import CoreLocation

class Route: NSObject, MKAnnotation {
    
    enum RouteKey {
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
    
    var routeDictionaryRepresentation: [String : AnyHashable] {
        [
            RouteKey.routeLatitude       : self.coordinate.latitude,
            RouteKey.routeLongitude      : self.coordinate.longitude,
            RouteKey.title               : self.title,
            RouteKey.isShowingDirections : self.isShowingDirections,
            RouteKey.isDriving           : self.isDriving
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
extension Route {
    convenience init?(fromRouteDictionary routeDictionary: [String : Any]) {
        guard let routeLatitude       = routeDictionary[RouteKey.routeLatitude] as? Double,
              let routeLongitude      = routeDictionary[RouteKey.routeLongitude] as? Double,
              let isShowingDirections = routeDictionary[RouteKey.isShowingDirections] as? Bool,
              let isDriving           = routeDictionary[RouteKey.isDriving] as? Bool
        else {
            print("Failed to initialize RouteAnnotation model object")
            return nil
        }
        
        let title = routeDictionary[RouteKey.title] as? String ?? "Route"
        
        self.init(coordinate: CLLocationCoordinate2D(latitude: routeLatitude, longitude: routeLongitude), title: title, isShowingDirections: isShowingDirections, isDriving: isDriving)
    }
}
