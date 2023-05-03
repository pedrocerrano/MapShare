//
//  Member.swift
//  MapShare
//
//  Created by iMac Pro on 4/27/23.
//

import CoreLocation

class Member {
    
    enum MemberKey {
        static let memberName          = "memberName"
        static let memberUUID          = "memberUUID"
        static let isOrganizer         = "isOrganizer"
        static let isActive            = "isActive"
        static let currentLocLatitude  = "currentLocLatitude"
        static let currentLocLongitude = "currentLocLongitude"
    }
    
    let memberName: String
    let memberUUID: String
    let isOrganizer: Bool
    var isActive: Bool
    var currentLocLatitude: Double
    var currentLocLongitude: Double
    
    var memberDictionaryRepresentation: [String : AnyHashable] {
        [
            MemberKey.memberName          : self.memberName,
            MemberKey.memberUUID          : self.memberUUID,
            MemberKey.isOrganizer         : self.isOrganizer,
            MemberKey.isActive            : self.isActive,
            MemberKey.currentLocLatitude  : self.currentLocLatitude,
            MemberKey.currentLocLongitude : self.currentLocLongitude
        ]
    }
    
    init(memberName: String, memberUUID: String, isOrganizer: Bool, isActive: Bool, currentLocLatitude: Double, currentLocLongitude: Double) {
        self.memberName          = memberName
        self.memberUUID          = memberUUID
        self.isOrganizer         = isOrganizer
        self.isActive            = isActive
        self.currentLocLatitude  = currentLocLatitude
        self.currentLocLongitude = currentLocLongitude
    }
}


//MARK: - EXT: Convenience Initializer
extension Member {
    convenience init?(fromMemberDictionary memberDictionary: [String : Any]) {
        guard let memberName = memberDictionary[MemberKey.memberName] as? String,
              let memberUUID = memberDictionary[MemberKey.memberUUID] as? String,
              let isOrganizer = memberDictionary[MemberKey.isOrganizer] as? Bool,
              let isActive = memberDictionary[MemberKey.isActive] as? Bool,
              let currentLocLatitude = memberDictionary[MemberKey.currentLocLatitude] as? Double,
              let currentLocLongitude = memberDictionary[MemberKey.currentLocLongitude] as? Double else {
            print("Failed to initialize Member model object")
            return nil
        }
        
        self.init(memberName: memberName, memberUUID: memberUUID, isOrganizer: isOrganizer, isActive: isActive, currentLocLatitude: currentLocLatitude, currentLocLongitude: currentLocLongitude)
    }
}


//MARK: - EXT: EQUATABLE
extension Member: Equatable {
    static func == (lhs: Member, rhs: Member) -> Bool {
        return lhs.memberUUID == rhs.memberUUID
    }
}
