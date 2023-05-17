//
//  Constants.swift
//  MapShare
//
//  Created by iMac Pro on 4/27/23.
//

import UIKit

struct Constants {
    
    struct MockData {
        static let dummySession = Session(sessionName: "Do Not Use", sessionCode: "ABCDEF", organizerDeviceID: "1", members: [], destination: [], isActive: false)
    }
    
    struct Notifications {
        static let newSessionActive = Notification.Name("newSessionActive")
    }
    
    struct Device {
        static let deviceID = UIDevice.current.identifierForVendor?.uuidString
    }
    
    struct AdmitDenyButtonUI {
        static let cornerRadius: CGFloat      = 6
        static let shadowColor                = UIColor.black.cgColor
        static let shadowOpacity: Float       = 0.4
        static let shadowRadius: CGFloat      = 2
        static let shadowOffset               = CGSize(width: 0, height: 2)
        static let titleShadowColor           = UIColor.black.cgColor
        static let titleShadowOpacity: Float  = 0.4
        static let titleShadowRadius: CGFloat = 1
        static let titleShadowOffset          = CGSize(width: 0, height: 1)
        static let masksToBounds: Bool        = false
    }
}
