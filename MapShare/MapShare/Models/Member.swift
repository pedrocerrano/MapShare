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
        static let memberUUID          = "memberUUID"
        static let memberDeviceID      = "memberDeviceID"
        static let isOrganizer         = "isOrganizer"
        static let isActive            = "isActive"
        static let currentLocLatitude  = "currentLocLatitude"
        static let currentLocLongitude = "currentLocLongitude"
    }
    
    var firstName: String
    var lastName: String
    var screenName: String
    var mapMarkerColor: String
    var memberUUID: String
    var memberDeviceID: String
    var isOrganizer: Bool
    var isActive: Bool
    var currentLocLatitude: Double
    var currentLocLongitude: Double
    
    var memberDictionaryRepresentation: [String : AnyHashable] {
        [
            MemberKey.firstName           : self.firstName,
            MemberKey.lastName            : self.lastName,
            MemberKey.screenName          : self.screenName,
            MemberKey.mapMarkerColor      : self.mapMarkerColor,
            MemberKey.memberUUID          : self.memberUUID,
            MemberKey.memberDeviceID      : self.memberDeviceID,
            MemberKey.isOrganizer         : self.isOrganizer,
            MemberKey.isActive            : self.isActive,
            MemberKey.currentLocLatitude  : self.currentLocLatitude,
            MemberKey.currentLocLongitude : self.currentLocLongitude
        ]
    }
    
    init(firstName: String, lastName: String, screenName: String, mapMarkerColor: String, memberUUID: String, memberDeviceID: String, isOrganizer: Bool, isActive: Bool, currentLocLatitude: Double, currentLocLongitude: Double) {
        self.firstName           = firstName
        self.lastName            = lastName
        self.screenName          = screenName
        self.mapMarkerColor      = mapMarkerColor
        self.memberUUID          = memberUUID
        self.memberDeviceID      = memberDeviceID
        self.isOrganizer         = isOrganizer
        self.isActive            = isActive
        self.currentLocLatitude  = currentLocLatitude
        self.currentLocLongitude = currentLocLongitude
    }
}


//MARK: - EXT: Convenience Initializer
extension Member {
    convenience init?(fromMemberDictionary memberDictionary: [String : Any]) {
        guard let firstName           = memberDictionary[MemberKey.firstName] as? String,
              let lastName            = memberDictionary[MemberKey.lastName] as? String,
              let screenName          = memberDictionary[MemberKey.screenName] as? String,
              let mapMarkerColor      = memberDictionary[MemberKey.mapMarkerColor] as? String,
              let memberUUID          = memberDictionary[MemberKey.memberUUID] as? String,
              let memberDeviceID      = memberDictionary[MemberKey.memberDeviceID] as? String,
              let isOrganizer         = memberDictionary[MemberKey.isOrganizer] as? Bool,
              let isActive            = memberDictionary[MemberKey.isActive] as? Bool,
              let currentLocLatitude  = memberDictionary[MemberKey.currentLocLatitude] as? Double,
              let currentLocLongitude = memberDictionary[MemberKey.currentLocLongitude] as? Double else {
            print("Failed to initialize Member model object")
            return nil
        }
        
        self.init(firstName: firstName, lastName: lastName, screenName: screenName, mapMarkerColor: mapMarkerColor, memberUUID: memberUUID, memberDeviceID: memberDeviceID, isOrganizer: isOrganizer, isActive: isActive, currentLocLatitude: currentLocLatitude, currentLocLongitude: currentLocLongitude)
    }
}


//MARK: - EXT: EQUATABLE
extension Member: Equatable {
    static func == (lhs: Member, rhs: Member) -> Bool {
        return lhs.memberUUID == rhs.memberUUID
    }
}
