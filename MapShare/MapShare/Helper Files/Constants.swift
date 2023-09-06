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
    }
    
    struct AnnotationIdentifiers {
        static let forRoutes  = "Route"
        static let forMembers = "Member"
    }
    
    
    //MARK: - UI ATTRIBUTES
    struct LabelUI {
        static let shadowColor           = UIColor.black.cgColor
        static let shadowOpacity: Float  = 0.4
        static let shadowRadius: CGFloat = 2
        static let shadowOffset          = CGSize(width: 0, height: 2)
        static let masksToBounds: Bool   = false
    }
    
    struct ButtonUI {
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
    
    struct PopUpButtonUI {
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
    
    struct CircleButtonUI {
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
    
    struct TextFieldUI {
        static let shadowColor           = UIColor.black.cgColor
        static let shadowOpacity: Float  = 0.1
        static let shadowRadius: CGFloat = 2
        static let shadowOffset          = CGSize(width: 0, height: 2)
        static let cornerRadius: CGFloat = 6
        static let masksToBounds: Bool   = false
    }
}
