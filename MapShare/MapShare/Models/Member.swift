//
//  Member.swift
//  MapShare
//
//  Created by iMac Pro on 4/27/23.
//

import MapKit
import CoreLocation

class Member: NSObject, MKAnnotation {
    
    enum MemberKey {
        static let firstName           = "firstName"
        static let lastName            = "lastName"
        static let color               = "color"
        static let deviceID            = "deviceID"
        static let isOrganizer         = "isOrganizer"
        static let isActive            = "isActive"
        static let expectedTravelTime  = "expectedTravelTime"
        static let memberLatitude      = "memberAnnoLatitude"
        static let memberLongitude     = "memberAnnoLongitude"
        static let title               = "title"
    }
    
    var firstName: String
    var lastName: String
    var color: String
    var deviceID: String
    var isOrganizer: Bool
    var isActive: Bool
    var expectedTravelTime: Double?
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    
    var memberDictionaryRepresentation: [String : AnyHashable] {
        [
            MemberKey.firstName          : self.firstName,
            MemberKey.lastName           : self.lastName,
            MemberKey.color              : self.color,
            MemberKey.deviceID           : self.deviceID,
            MemberKey.isOrganizer        : self.isOrganizer,
            MemberKey.isActive           : self.isActive,
            MemberKey.expectedTravelTime : self.expectedTravelTime,
            MemberKey.memberLatitude     : self.coordinate.latitude,
            MemberKey.memberLongitude    : self.coordinate.longitude,
            MemberKey.title              : self.title
        ]
    }
    
    init(firstName: String, lastName: String, color: String, deviceID: String, isOrganizer: Bool, isActive: Bool, expectedTravelTime: Double? = nil, coordinate: CLLocationCoordinate2D, title: String?) {
        self.firstName          = firstName
        self.lastName           = lastName
        self.color              = color
        self.deviceID           = deviceID
        self.isOrganizer        = isOrganizer
        self.isActive           = isActive
        self.expectedTravelTime = expectedTravelTime
        self.coordinate         = coordinate
        self.title              = title
    }
}


//MARK: - EXT: Convenience Initializer
extension Member {
    convenience init?(fromMemberDictionary memberDictionary: [String : Any]) {
        guard let firstName       = memberDictionary[MemberKey.firstName] as? String,
              let lastName        = memberDictionary[MemberKey.lastName] as? String,
              let color           = memberDictionary[MemberKey.color] as? String,
              let deviceID        = memberDictionary[MemberKey.deviceID] as? String,
              let isOrganizer     = memberDictionary[MemberKey.isOrganizer] as? Bool,
              let isActive        = memberDictionary[MemberKey.isActive] as? Bool,
              let memberLatitude  = memberDictionary[MemberKey.memberLatitude] as? Double,
              let memberLongitude = memberDictionary[MemberKey.memberLongitude] as? Double,
              let title           = memberDictionary[MemberKey.title] as? String
        else {
            print("Failed to initialize Member model object")
            return nil
        }
        
        let expectedTravelTime = memberDictionary[MemberKey.expectedTravelTime] as? Double ?? -1
        
        self.init(firstName: firstName, lastName: lastName, color: color, deviceID: deviceID, isOrganizer: isOrganizer, isActive: isActive, expectedTravelTime: expectedTravelTime, coordinate: CLLocationCoordinate2D(latitude: memberLatitude, longitude: memberLongitude), title: title)
    }
}
