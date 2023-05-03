//
//  Session.swift
//  MapShare
//
//  Created by iMac Pro on 4/27/23.
//

import CoreLocation

class Session {
    
    enum SessionKey {
        static let sessionName = "sessionName"
        static let sessionUUID = "sessionUUID"
        static let members     = "members"
        static let destination = "destination"
        static let isActive    = "isActive"
    }
    
    var sessionName: String
    let sessionUUID: String
    var members: [Member]
    var destination: [MSDestination]?
    var isActive: Bool
    
    var sessionDictionaryRepresentation: [String : AnyHashable] {
        [
            SessionKey.sessionName : self.sessionName,
            SessionKey.sessionUUID : self.sessionUUID,
            SessionKey.members     : self.members.map { $0.memberDictionaryRepresentation },
            SessionKey.destination : self.destination?.map { $0.destinationDictionaryRepresentation },
            SessionKey.isActive    : self.isActive
        ]
    }
    
    init(sessionName: String, sessionUUID: String, members: [Member], destination: [MSDestination]? = nil, isActive: Bool) {
        self.sessionName = sessionName
        self.sessionUUID = sessionUUID
        self.members     = members
        self.destination = destination
        self.isActive    = isActive
    }
    
}

extension Session: Equatable {
    static func == (lhs: Session, rhs: Session) -> Bool {
        return lhs.sessionUUID == rhs.sessionUUID
    }
}
