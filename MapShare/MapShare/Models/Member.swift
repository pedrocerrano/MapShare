//
//  Member.swift
//  MapShare
//
//  Created by iMac Pro on 4/27/23.
//

import CoreLocation

struct Member {
    let name: String
    let isOrganizer: Bool
    var isActive: Bool
    var currentLocation: CLLocationCoordinate2D
}
