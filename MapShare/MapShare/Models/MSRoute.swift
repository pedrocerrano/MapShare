//
//  MSRoute.swift
//  MapShare
//
//  Created by iMac Pro on 4/27/23.
//

import CoreLocation

class MSRoute {
    
    enum MSRouteKey {
        static let routeName      = "routeName"
        static let routeUUID      = "routeUUID"
        static let routeLatitude  = "routeLatitude"
        static let routeLongitude = "routeLongitude"
        static let routeETA       = "routeETA"
    }
    
    let routeName: String
    let routeUUID: String
    let routeLatitude: Double
    let routeLongitude: Double
    let routeETA: Double
    
    var routeDictionaryRepresentation: [String : AnyHashable] {
        [
            MSRouteKey.routeName      : self.routeName,
            MSRouteKey.routeUUID      : self.routeUUID,
            MSRouteKey.routeLatitude  : self.routeLatitude,
            MSRouteKey.routeLongitude : self.routeLongitude,
            MSRouteKey.routeETA       : self.routeETA
        ]
    }
    
    init(routeName: String, routeUUID: String, routeLatitude: Double, routeLongitude: Double, routeETA: Double) {
        self.routeName      = routeName
        self.routeUUID      = routeUUID
        self.routeLatitude  = routeLatitude
        self.routeLongitude = routeLongitude
        self.routeETA       = routeETA
    }
}


//MARK: - EXT: Convenience Initializer
extension MSRoute {
    convenience init?(fromMSRouteDictionary routeDictionary: [String : Any]) {
        guard let routeName      = routeDictionary[MSRouteKey.routeName] as? String,
              let routeUUID      = routeDictionary[MSRouteKey.routeUUID] as? String,
              let routeLatitude  = routeDictionary[MSRouteKey.routeLatitude] as? Double,
              let routeLongitude = routeDictionary[MSRouteKey.routeLongitude] as? Double,
              let routeETA       = routeDictionary[MSRouteKey.routeETA] as? Double else {
            print("Failed to initialize MSRoute model object")
            return nil
        }
        
        self.init(routeName: routeName, routeUUID: routeUUID, routeLatitude: routeLatitude, routeLongitude: routeLongitude, routeETA: routeETA)
    }
}


//MARK: - EXT: EQUATABLE
extension MSRoute: Equatable {
    static func == (lhs: MSRoute, rhs: MSRoute) -> Bool {
        return lhs.routeUUID == rhs.routeUUID
    }
}
