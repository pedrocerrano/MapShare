//
//  Alerts.swift
//  MapShare
//
//  Created by iMac Pro on 8/30/23.
//

import UIKit

struct Alerts {
    
    static func needLocationAccess() -> UIAlertController {
        guard let settingsAppURL          = URL(string: UIApplication.openSettingsURLString) else { return UIAlertController() }
        let locationAccessAlertController = UIAlertController(title: "Permission Has Been Denied Or Restricted",
                                                              message: "In order to utilize MapShare, we need access to your location.",
                                                              preferredStyle: .alert)
        let dismissAction      = UIAlertAction(title: "Cancel", style: .cancel)
        let goToSettingsAction = UIAlertAction(title: "Go To Settings", style: .default) { _ in
            UIApplication.shared.open(settingsAppURL)
        }
        
        locationAccessAlertController.addAction(dismissAction)
        locationAccessAlertController.addAction(goToSettingsAction)
        
        return locationAccessAlertController
    }
    
    static func needSessionName() -> UIAlertController {
        let needSessionNameAlertController = UIAlertController(title: "Need Session Name",
                                                               message: "Please name this MapShare Session.",
                                                               preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Will do!", style: .cancel)
        needSessionNameAlertController.addAction(dismissAction)
        
        return needSessionNameAlertController
    }
    
    static func needFirstName() -> UIAlertController {
        let needFirstNameAlertController = UIAlertController(title: "Need First Name",
                                                             message: "Please share your first name for others to identify you.",
                                                             preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Okay", style: .cancel)
        needFirstNameAlertController.addAction(dismissAction)
        
        return needFirstNameAlertController
    }
    
    static func needLastName() -> UIAlertController {
        let needLastNameAlertController = UIAlertController(title: "Need Last Name",
                                                            message: "Please share your last name for others to identify you.",
                                                            preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Okay", style: .cancel)
        needLastNameAlertController.addAction(dismissAction)
        
        return needLastNameAlertController
    }
    
    static func needColorChoice() -> UIAlertController {
        let needColorChoiceAlertController = UIAlertController(title: "Select Color",
                                                               message: "Please select your marker color to join.",
                                                               preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Okay", style: .cancel)
        needColorChoiceAlertController.addAction(dismissAction)
        
        return needColorChoiceAlertController
    }
    
    static func onlySixDigits() -> UIAlertController {
        let onlySixDigitsAlertController = UIAlertController(title: "Invalid Session Code",
                                                             message: "Please retype a valid six-digit session code.",
                                                             preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Okay", style: .cancel)
        onlySixDigitsAlertController.addAction(dismissAction)
        
        return onlySixDigitsAlertController
    }
}
