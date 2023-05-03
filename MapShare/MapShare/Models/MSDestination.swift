//
//  MSDestination.swift
//  MapShare
//
//  Created by iMac Pro on 4/27/23.
//

import CoreLocation

struct MSDestination {
    
    enum MSDestinationKey {
        static let name                 = "name"
        static let destinationLatitude  = "destinationLatitude"
        static let destinationLongitude = "destinationLongitude"
    }
    
    let name: String
    let destinationLatitude: Double
    let destinationLongitude: Double
    
    var destinationDictionaryRepresentation: [String : AnyHashable] {
        [
            MSDestinationKey.name                 : self.name,
            MSDestinationKey.destinationLatitude  : self.destinationLatitude,
            MSDestinationKey.destinationLongitude : self.destinationLongitude
        ]
    }
}
