//
//  MSDestination.swift
//  MapShare
//
//  Created by iMac Pro on 4/27/23.
//

import CoreLocation

class MSDestination {
    
    enum MSDestinationKey {
        static let destinationName      = "destinationName"
        static let destinationUUID      = "destinationUUID"
        static let destinationLatitude  = "destinationLatitude"
        static let destinationLongitude = "destinationLongitude"
    }
    
    let destinationName: String
    let destinationUUID: String
    let destinationLatitude: Double
    let destinationLongitude: Double
    
    var destinationDictionaryRepresentation: [String : AnyHashable] {
        [
            MSDestinationKey.destinationName      : self.destinationName,
            MSDestinationKey.destinationUUID      : self.destinationUUID,
            MSDestinationKey.destinationLatitude  : self.destinationLatitude,
            MSDestinationKey.destinationLongitude : self.destinationLongitude
        ]
    }
    
    init(destinationName: String, destinationUUID: String, destinationLatitude: Double, destinationLongitude: Double) {
        self.destinationName      = destinationName
        self.destinationUUID      = destinationUUID
        self.destinationLatitude  = destinationLatitude
        self.destinationLongitude = destinationLongitude
    }
}


//MARK: - EXT: Convenience Initializer
extension MSDestination {
    convenience init?(fromMSDestinationDictionary msDestinationDictionary: [String : Any]) {
        guard let destinationName      = msDestinationDictionary[MSDestinationKey.destinationName] as? String,
              let destinationUUID      = msDestinationDictionary[MSDestinationKey.destinationUUID] as? String,
              let destinationLatitude  = msDestinationDictionary[MSDestinationKey.destinationLatitude] as? Double,
              let destinationLongitude = msDestinationDictionary[MSDestinationKey.destinationLongitude] as? Double else {
            print("Failed to initialize MSDEstination model object")
            return nil
        }
        
        self.init(destinationName: destinationName, destinationUUID: destinationUUID, destinationLatitude: destinationLatitude, destinationLongitude: destinationLongitude)
    }
}


//MARK: - EXT: EQUATABLE
extension MSDestination: Equatable {
    static func == (lhs: MSDestination, rhs: MSDestination) -> Bool {
        return lhs.destinationUUID == rhs.destinationUUID
    }
}
