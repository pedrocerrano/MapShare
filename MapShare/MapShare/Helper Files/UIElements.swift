//
//  UIElements.swift
//  MapShare
//
//  Created by iMac Pro on 5/10/23.
//

import UIKit

struct UIElements {
    
    //MARK: - COLORS
    struct Color {
        static let mapShareRed      = UIColor(red: 255/255, green: 35/255, blue: 0/255, alpha: 1)
        static let mapSharePink     = UIColor(red: 255/255, green: 20/255, blue: 150/255, alpha: 1)
        static let mapShareOrange   = UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 1)
        static let mapShareYellow   = UIColor(red: 255/255, green: 233/255, blue: 0/255, alpha: 1)
        static let mapShareGreen    = UIColor(red: 10/255, green: 200/255, blue: 80/255, alpha: 1)
        static let mapShareCyan     = UIColor(red: 64/255, green: 224/255, blue: 208/255, alpha: 1)
        static let mapShareBlue     = UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1)
        static let mapSharePurple   = UIColor(red: 160/255, green: 32/255, blue: 240/255, alpha: 1)
        static let buttonDodgerBlue = UIColor(red: 30/255, green: 144/255, blue: 255/255, alpha: 1)
    }
    
    struct Tint {
        static let redTint    = UIColor(red: 255/255, green: 35/255, blue: 0/255, alpha: 1)
        static let pinkTint   = UIColor(red: 255/255, green: 20/255, blue: 150/255, alpha: 0.9)
        static let orangeTint = UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 1)
        static let yellowTint = UIColor(red: 210/255, green: 180/255, blue: 40/255, alpha: 0.9)
        static let greenTint  = UIColor(red: 10/255, green: 200/255, blue: 80/255, alpha: 1)
        static let cyanTint   = UIColor(red: 64/255, green: 224/255, blue: 208/255, alpha: 1)
        static let blueTint   = UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 0.6)
        static let purpleTint = UIColor(red: 160/255, green: 32/255, blue: 240/255, alpha: 0.6)
    }
    
    
    //MARK: - MAP HOME UI
    static func hideRouteAnnotationButton(for button: UIButton) {
        button.configuration?.baseBackgroundColor = .clear
        button.configuration?.baseForegroundColor = .clear
    }
    
    static func showRouteAnnotationButton(for button: UIButton) {
        button.configuration?.baseBackgroundColor = .lightGray
        button.configuration?.baseForegroundColor = .black
    }
    
    
    //MARK: - FILLED and TINTED BUTTON COLORS
    static func configureFilledStyleButtonColor(for button: UIButton, withColor color: UIColor) {
        button.configuration?.baseBackgroundColor = color
        button.layer.shadowColor                  = Constants.ButtonUI.shadowColor
        button.layer.shadowOpacity                = Constants.ButtonUI.shadowOpacity
        button.layer.shadowRadius                 = Constants.ButtonUI.shadowRadius
        button.layer.shadowOffset                 = Constants.ButtonUI.shadowOffset
        button.titleLabel?.layer.shadowColor      = Constants.ButtonUI.titleShadowColor
        button.titleLabel?.layer.shadowOpacity    = Constants.ButtonUI.titleShadowOpacity
        button.titleLabel?.layer.shadowRadius     = Constants.ButtonUI.titleShadowRadius
        button.titleLabel?.layer.shadowOffset     = Constants.ButtonUI.titleShadowOffset
        button.layer.masksToBounds                = Constants.ButtonUI.masksToBounds
    }
    
    static func configureTintedStyleButtonColor(for button: UIButton) {
        button.tintColor = Color.buttonDodgerBlue
        button.setTitleColor(Color.buttonDodgerBlue, for: .normal)
    }
    
    
    //MARK: - ACTIVE SESSION UI
    static func configureActiveSessionTableViewButton(for button: UIButton, withColor color: UIColor) {
        button.layer.cornerRadius              = Constants.ButtonUI.cornerRadius
        button.layer.shadowColor               = Constants.ButtonUI.shadowColor
        button.layer.shadowOpacity             = Constants.ButtonUI.shadowOpacity
        button.layer.shadowRadius              = Constants.ButtonUI.shadowRadius
        button.layer.shadowOffset              = Constants.ButtonUI.shadowOffset
        button.titleLabel?.layer.shadowColor   = Constants.ButtonUI.titleShadowColor
        button.titleLabel?.layer.shadowOpacity = Constants.ButtonUI.titleShadowOpacity
        button.titleLabel?.layer.shadowRadius  = Constants.ButtonUI.titleShadowRadius
        button.titleLabel?.layer.shadowOffset  = Constants.ButtonUI.titleShadowOffset
        button.layer.backgroundColor           = color.cgColor
        button.layer.masksToBounds             = Constants.ButtonUI.masksToBounds
    }
    
    
}
