//
//  Constants.swift
//  MapShare
//
//  Created by iMac Pro on 4/27/23.
//

import UIKit

struct Constants {
    
    struct Device {
        static let deviceID = UIDevice.current.identifierForVendor?.uuidString
    }
    
    struct Ably {
        static let apiKey = "Zc6kCg.7jxCGw:XhXmrdgHtjpi7C1R6EeshzjgzmfWVZJBhcJnwD0Cw8M"
    }
    
    struct Notifications {
        static let locationAccessNeeded = Notification.Name("locationAccessNeeded")
        static let ablyRealtimeServer   = Notification.Name("ablyRealtimeServer")
    }
    
    struct AnnotationIdentifiers {
        static let forRoutes  = "Route"
        static let forMembers = "Member"
    }
}
