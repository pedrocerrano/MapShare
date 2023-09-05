//
//  Session.swift
//  MapShare
//
//  Created by iMac Pro on 4/27/23.
//

import CoreLocation

class Session {
    
    enum SessionKey {
        static let sessionName           = "sessionName"
        static let sessionCode           = "sessionCode"
        static let organizerDeviceID     = "organizerDeviceID"
        static let members               = "members"
        static let deletingMembers       = "deletingMembers"
        static let routes                = "routes"
        
        static let sessionCollectionType        = "mapShareSession"
        static let membersCollectionType        = "members"
        static let deletedMembersCollectionType = "deletedMembers"
        static let routeCollectionType          = "routeCollection"
        static let routeDocumentType            = "routeDocument"
    }
    
    var sessionName: String
    var sessionCode: String
    var organizerDeviceID: String
    var members: [Member]
    var deletedMembers: [DeletedMember]
    var routes: [Route]
    
    var sessionDictionaryRepresentation: [String : AnyHashable] {
        [
            SessionKey.sessionName       : self.sessionName,
            SessionKey.sessionCode       : self.sessionCode,
            SessionKey.organizerDeviceID : self.organizerDeviceID
        ]
    }
    
    init(sessionName: String, sessionCode: String, organizerDeviceID: String, members: [Member], deletedMembers: [DeletedMember], routes: [Route]) {
        self.sessionName       = sessionName
        self.sessionCode       = sessionCode
        self.organizerDeviceID = organizerDeviceID
        self.members           = members
        self.deletedMembers    = deletedMembers
        self.routes            = routes
    }
    
}


//MARK: - EXT: Convenience Initializer
extension Session {
    convenience init?(fromSessionDictionary sessionDictionary: [String : Any]) {
        guard let sessionName       = sessionDictionary[SessionKey.sessionName] as? String,
              let sessionCode       = sessionDictionary[SessionKey.sessionCode] as? String,
              let organizerDeviceID = sessionDictionary[SessionKey.organizerDeviceID] as? String
        else {
            print("Failed to initialize Session model object")
            return nil
        }
        
        self.init(sessionName: sessionName, sessionCode: sessionCode, organizerDeviceID: organizerDeviceID, members: [], deletedMembers: [], routes: [])
    }
}

