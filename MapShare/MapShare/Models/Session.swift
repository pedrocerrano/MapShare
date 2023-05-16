//
//  Session.swift
//  MapShare
//
//  Created by iMac Pro on 4/27/23.
//

import CoreLocation

class Session {
    
    enum SessionKey {
        static let sessionName              = "sessionName"
        static let sessionUUID              = "sessionUUID"
        static let sessionCode              = "sessionCode"
        static let organizerDeviceID        = "organizerDeviceID"
        static let members                  = "members"
        static let destination              = "destination"
        static let isActive                 = "isActive"
        
        static let sessionCollectionType    = "mapShareSession"
        static let membersCollectionType    = "mapShareMembers"
        static let directionsCollectionType = "mapShareMembers"
    }
    
    var sessionName: String
    var sessionUUID: String
    var sessionCode: String
    var organizerDeviceID: String
    var members: [Member]
    var destination: [MSDestination]
    var isActive: Bool
    
    var sessionDictionaryRepresentation: [String : AnyHashable] {
        [
            SessionKey.sessionName       : self.sessionName,
            SessionKey.sessionUUID       : self.sessionUUID,
            SessionKey.sessionCode       : self.sessionCode,
            SessionKey.organizerDeviceID : self.organizerDeviceID,
            SessionKey.isActive          : self.isActive
        ]
    }
    
    init(sessionName: String, sessionUUID: String, sessionCode: String, organizerDeviceID: String, members: [Member], destination: [MSDestination], isActive: Bool) {
        self.sessionName       = sessionName
        self.sessionUUID       = sessionUUID
        self.sessionCode       = sessionCode
        self.organizerDeviceID = organizerDeviceID
        self.members           = members
        self.destination       = destination
        self.isActive          = isActive
    }
    
}


//MARK: - EXT: Convenience Initializer
extension Session {
    convenience init?(fromSessionDictionary sessionDictionary: [String : Any]) {
        guard let sessionName           = sessionDictionary[SessionKey.sessionName] as? String,
              let sessionUUID           = sessionDictionary[SessionKey.sessionUUID] as? String,
              let sessionCode           = sessionDictionary[SessionKey.sessionCode] as? String,
              let organizerDeviceID     = sessionDictionary[SessionKey.organizerDeviceID] as? String,
              let isActive              = sessionDictionary[SessionKey.isActive] as? Bool else {
            print("Failed to initialize Session model object")
            return nil
        }
        
        self.init(sessionName: sessionName, sessionUUID: sessionUUID, sessionCode: sessionCode, organizerDeviceID: organizerDeviceID, members: [], destination: [], isActive: isActive)
    }
}


//MARK: - EXT: EQUATABLE
extension Session: Equatable {
    static func == (lhs: Session, rhs: Session) -> Bool {
        return lhs.sessionUUID == rhs.sessionUUID
    }
}
