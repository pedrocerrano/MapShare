//
//  UIElements.swift
//  MapShare
//
//  Created by iMac Pro on 5/10/23.
//

import UIKit

struct UIElements {
    
    struct Color {
        static let mapShareRed    = UIColor(red: 255/255, green: 35/255, blue: 0/255, alpha: 1)
        static let mapSharePink   = UIColor(red: 255/255, green: 20/255, blue: 150/255, alpha: 1)
        static let mapShareOrange = UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 1)
        static let mapShareYellow = UIColor(red: 255/255, green: 233/255, blue: 0/255, alpha: 1)
        static let mapShareGreen  = UIColor(red: 10/255, green: 200/255, blue: 80/255, alpha: 1)
        static let mapShareCyan   = UIColor(red: 64/255, green: 224/255, blue: 208/255, alpha: 1)
        static let mapShareBlue   = UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1)
        static let mapSharePurple = UIColor(red: 160/255, green: 32/255, blue: 240/255, alpha: 1)
    }
    
    struct Tint {
        static let redTint        = UIColor(red: 255/255, green: 35/255, blue: 0/255, alpha: 1)
        static let pinkTint       = UIColor(red: 255/255, green: 20/255, blue: 150/255, alpha: 0.9)
        static let orangeTint     = UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 1)
        static let yellowTint     = UIColor(red: 210/255, green: 180/255, blue: 40/255, alpha: 0.9)
        static let greenTint      = UIColor(red: 10/255, green: 200/255, blue: 80/255, alpha: 1)
        static let cyanTint       = UIColor(red: 64/255, green: 224/255, blue: 208/255, alpha: 1)
        static let blueTint       = UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 0.6)
        static let purpleTint     = UIColor(red: 160/255, green: 32/255, blue: 240/255, alpha: 0.6)
    }
    
    static func configureButton(for button: UIButton, withColor color: UIColor) {
        button.layer.cornerRadius              = Constants.AdmitDenyButtonUI.cornerRadius
        button.layer.shadowColor               = Constants.AdmitDenyButtonUI.shadowColor
        button.layer.shadowOpacity             = Constants.AdmitDenyButtonUI.shadowOpacity
        button.layer.shadowRadius              = Constants.AdmitDenyButtonUI.shadowRadius
        button.layer.shadowOffset              = Constants.AdmitDenyButtonUI.shadowOffset
        button.titleLabel?.layer.shadowColor   = Constants.AdmitDenyButtonUI.titleShadowColor
        button.titleLabel?.layer.shadowOpacity = Constants.AdmitDenyButtonUI.titleShadowOpacity
        button.titleLabel?.layer.shadowRadius  = Constants.AdmitDenyButtonUI.titleShadowRadius
        button.titleLabel?.layer.shadowOffset  = Constants.AdmitDenyButtonUI.titleShadowOffset
        button.layer.backgroundColor           = color.cgColor
        button.layer.masksToBounds             = Constants.AdmitDenyButtonUI.masksToBounds
    }
}
