//
//  Session.swift
//  MapShare
//
//  Created by iMac Pro on 4/27/23.
//

import CoreLocation

struct Session {
    var sessionName: String
    var sessionUUID: String
    var members: [Member]
    var destination: MSDestination?
    var isActive: Bool
}

extension Session: Equatable {
    static func == (lhs: Session, rhs: Session) -> Bool {
        return lhs.sessionUUID == rhs.sessionUUID
    }
}
