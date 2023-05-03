//
//  Member.swift
//  MapShare
//
//  Created by iMac Pro on 4/27/23.
//

import CoreLocation

struct Member {
    
    enum MemberKey {
        static let memberUUID          = "memberUUID"
        static let name                = "name"
        static let isOrganizer         = "isOrganizer"
        static let isActive            = "isActive"
        static let currentLocLatitude  = "currentLocLatitude"
        static let currentLocLongitude = "currentLocLongitude"
    }
    
    let memberUUID: String
    let name: String
    let isOrganizer: Bool
    var isActive: Bool
    var currentLocLatitude: Double
    var currentLocLongitude: Double
    
    var memberDictionaryRepresentation: [String : AnyHashable] {
        [
            MemberKey.memberUUID          : self.memberUUID,
            MemberKey.name                : self.name,
            MemberKey.isOrganizer         : self.isOrganizer,
            MemberKey.isActive            : self.isActive,
            MemberKey.currentLocLatitude  : self.currentLocLatitude,
            MemberKey.currentLocLongitude : self.currentLocLongitude
        ]
    }
    
    init(memberUUID: String, name: String, isOrganizer: Bool, isActive: Bool, currentLocLatitude: Double, currentLocLongitude: Double) {
        self.memberUUID = memberUUID
        self.name = name
        self.isOrganizer = isOrganizer
        self.isActive = isActive
        self.currentLocLatitude = currentLocLatitude
        self.currentLocLongitude = currentLocLongitude
    }
}
