//
//  Session.swift
//  MapShare
//
//  Created by iMac Pro on 4/27/23.
//

import CoreLocation

struct Session {
    let sessionName: String
    let sessionUUID: String
    var members: [Member]
    var destination: MSDestination
    var isActive: Bool
}
