//
//  UIElements.swift
//  MapShare
//
//  Created by iMac Pro on 5/10/23.
//

import UIKit

struct UIElements {
    
    struct Color {
        static let mapShareGreen = UIColor(red: 10/255, green: 200/255, blue: 80/255, alpha: 1)
        static let mapShareRed = UIColor(red: 255/255, green: 36/255, blue: 0/255, alpha: 1)
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
