//
//  Session.swift
//  MapShare
//
//  Created by iMac Pro on 4/27/23.
//

import CoreLocation

class Session {
    
    enum SessionKey {
        static let sessionName    = "sessionName"
        static let sessionUUID    = "sessionUUID"
        static let sessionCode    = "sessionCode"
        static let members        = "members"
        static let destination    = "destination"
        static let isActive       = "isActive"
        
        static let collectionType = "mapShareSession"
    }
    
    var sessionName: String
    let sessionUUID: String
    let sessionCode: String
    var members: [Member]
    var destination: [MSDestination]?
    var isActive: Bool
    
    var sessionDictionaryRepresentation: [String : AnyHashable] {
        [
            SessionKey.sessionName : self.sessionName,
            SessionKey.sessionUUID : self.sessionUUID,
            SessionKey.sessionCode : self.sessionCode,
            SessionKey.members     : self.members.map { $0.memberDictionaryRepresentation },
            SessionKey.destination : self.destination?.map { $0.destinationDictionaryRepresentation },
            SessionKey.isActive    : self.isActive
        ]
    }
    
    init(sessionName: String, sessionUUID: String, sessionCode: String, members: [Member], destination: [MSDestination]? = nil, isActive: Bool) {
        self.sessionName = sessionName
        self.sessionUUID = sessionUUID
        self.sessionCode = sessionCode
        self.members     = members
        self.destination = destination
        self.isActive    = isActive
    }
    
}


//MARK: - EXT: Convenience Initializer
extension Session {
    convenience init?(fromSessionDictionary sessionDictionary: [String : Any]) {
        guard let sessionName       = sessionDictionary[SessionKey.sessionName] as? String,
              let sessionUUID       = sessionDictionary[SessionKey.sessionUUID] as? String,
              let sessionCode       = sessionDictionary[SessionKey.sessionCode] as? String,
              let membersDictionary = sessionDictionary[SessionKey.members] as? [[String : AnyHashable]],
              let isActive          = sessionDictionary[SessionKey.isActive] as? Bool else {
            print("Failed to initialize Session model object")
            return nil
        }
        
        let membersArray = membersDictionary.compactMap { Member(fromMemberDictionary: $0) }
        let destinationDictionary = sessionDictionary[SessionKey.destination] as? [[String : AnyHashable]]          // Does this need to be unwrapped?
        let destinationArray      = destinationDictionary?.compactMap { MSDestination(fromMSDestinationDictionary: $0) }
        #warning("Because the object on line 23 is optional, the destination object on line 59 might have issues")
        
        self.init(sessionName: sessionName, sessionUUID: sessionUUID, sessionCode: sessionCode, members: membersArray, destination: destinationArray, isActive: isActive)
    }
}


//MARK: - EXT: EQUATABLE
extension Session: Equatable {
    static func == (lhs: Session, rhs: Session) -> Bool {
        return lhs.sessionUUID == rhs.sessionUUID
    }
}
