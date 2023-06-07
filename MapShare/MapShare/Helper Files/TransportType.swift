//
//  TransportType.swift
//  MapShare
//
//  Created by iMac Pro on 6/7/23.
//

import Foundation
import MapKit

enum TransportType {
    case automobile
    case walking
    
    var type: MKDirectionsTransportType {
        switch self {
        case .automobile:
            return .automobile
        case .walking:
            return .walking
        }
    }
    
    mutating func toggle() {
        switch self {
        case .automobile:
            self = .walking
            print("Enum: Walking selected")
        case .walking:
            self = .automobile
            print("Enum: Driving selected")
        }
    }
}
