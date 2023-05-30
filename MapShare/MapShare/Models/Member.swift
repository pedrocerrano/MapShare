//
//  Member.swift
//  MapShare
//
//  Created by iMac Pro on 4/27/23.
//

import CoreLocation

class Member {
    
    enum MemberKey {
        static let firstName           = "firstName"
        static let lastName            = "lastName"
        static let screenName          = "screenName"
        static let mapMarkerColor      = "mapMarkerColor"
        static let memberDeviceID      = "memberDeviceID"
        static let isOrganizer         = "isOrganizer"
        static let isActive            = "isActive"
        static let currentLocLatitude  = "currentLocLatitude"
        static let currentLocLongitude = "currentLocLongitude"
        static let expectedTravelTime  = "expectedTravelTime"
    }
    
    var firstName: String
    var lastName: String
    var screenName: String
    var mapMarkerColor: String
    var memberDeviceID: String
    var isOrganizer: Bool
    var isActive: Bool
    var currentLocLatitude: Double
    var currentLocLongitude: Double
    var expectedTravelTime: Double?
    
    var memberDictionaryRepresentation: [String : AnyHashable] {
        [
            MemberKey.firstName           : self.firstName,
            MemberKey.lastName            : self.lastName,
            MemberKey.screenName          : self.screenName,
            MemberKey.mapMarkerColor      : self.mapMarkerColor,
            MemberKey.memberDeviceID      : self.memberDeviceID,
            MemberKey.isOrganizer         : self.isOrganizer,
            MemberKey.isActive            : self.isActive,
            MemberKey.currentLocLatitude  : self.currentLocLatitude,
            MemberKey.currentLocLongitude : self.currentLocLongitude,
            MemberKey.expectedTravelTime  : self.expectedTravelTime
        ]
    }
    
    init(firstName: String, lastName: String, screenName: String, mapMarkerColor: String, memberDeviceID: String, isOrganizer: Bool, isActive: Bool, currentLocLatitude: Double, currentLocLongitude: Double, expectedTravelTime: Double? = nil) {
        self.firstName           = firstName
        self.lastName            = lastName
        self.screenName          = screenName
        self.mapMarkerColor      = mapMarkerColor
        self.memberDeviceID      = memberDeviceID
        self.isOrganizer         = isOrganizer
        self.isActive            = isActive
        self.currentLocLatitude  = currentLocLatitude
        self.currentLocLongitude = currentLocLongitude
        self.expectedTravelTime  = expectedTravelTime
    }
}


//MARK: - EXT: Convenience Initializer
extension Member {
    convenience init?(fromMemberDictionary memberDictionary: [String : Any]) {
        guard let firstName           = memberDictionary[MemberKey.firstName] as? String,
              let lastName            = memberDictionary[MemberKey.lastName] as? String,
              let screenName          = memberDictionary[MemberKey.screenName] as? String,
              let mapMarkerColor      = memberDictionary[MemberKey.mapMarkerColor] as? String,
              let memberDeviceID      = memberDictionary[MemberKey.memberDeviceID] as? String,
              let isOrganizer         = memberDictionary[MemberKey.isOrganizer] as? Bool,
              let isActive            = memberDictionary[MemberKey.isActive] as? Bool,
              let currentLocLatitude  = memberDictionary[MemberKey.currentLocLatitude] as? Double,
              let currentLocLongitude = memberDictionary[MemberKey.currentLocLongitude] as? Double else {
            print("Failed to initialize Member model object")
            return nil
        }
        
        let expectedTravelTime = memberDictionary[MemberKey.expectedTravelTime] as? Double ?? -1
        
        self.init(firstName: firstName, lastName: lastName, screenName: screenName, mapMarkerColor: mapMarkerColor, memberDeviceID: memberDeviceID, isOrganizer: isOrganizer, isActive: isActive, currentLocLatitude: currentLocLatitude, currentLocLongitude: currentLocLongitude, expectedTravelTime: expectedTravelTime)
    }
}
