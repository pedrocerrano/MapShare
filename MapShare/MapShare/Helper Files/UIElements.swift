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
        static let mapShareRed    = UIColor(red: 255/255, green: 35/255, blue: 0/255, alpha: 1)
        static let mapSharePink   = UIColor(red: 255/255, green: 20/255, blue: 150/255, alpha: 1)
        static let mapShareOrange = UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 1)
        static let mapShareYellow = UIColor(red: 255/255, green: 233/255, blue: 0/255, alpha: 1)
        static let mapShareGreen  = UIColor(red: 10/255, green: 200/255, blue: 80/255, alpha: 1)
        static let mapShareCyan   = UIColor(red: 64/255, green: 224/255, blue: 208/255, alpha: 1)
        static let mapShareBlue   = UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1)
        static let mapSharePurple = UIColor(red: 160/255, green: 32/255, blue: 240/255, alpha: 1)
        static let dodgerBlue     = UIColor(red: 30/255, green: 144/255, blue: 255/255, alpha: 1)
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
    
    static func hideLocationRefreshButton(for button: UIButton) {
        button.configuration?.baseBackgroundColor = .clear
        button.configuration?.baseForegroundColor = .clear
    }
    
    static func showLocationRefreshButton(for button: UIButton) {
        button.configuration?.baseBackgroundColor = Color.mapShareGreen
        button.configuration?.baseForegroundColor = .white
    }
    
    static func configureLabelUI(for label: UILabel) {
        label.layer.shadowColor   = Constants.LabelUI.shadowColor
        label.layer.shadowOpacity = Constants.LabelUI.shadowOpacity
        label.layer.shadowRadius  = Constants.LabelUI.shadowRadius
        label.layer.shadowOffset  = Constants.LabelUI.shadowOffset
        label.layer.masksToBounds = Constants.LabelUI.masksToBounds
    }
    
    
    //MARK: - BUTTON ATTRIBUTES
    static func configureFilledStyleButtonAttributes(for button: UIButton, withColor color: UIColor) {
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
    
    static func configureCircleButtonAttributes(for button: UIButton, backgroundColor: UIColor, tintColor: UIColor) {
        button.backgroundColor                 = backgroundColor
        button.tintColor                       = tintColor
        button.layer.cornerRadius              = button.frame.height / 2
        button.layer.shadowColor               = Constants.CircleButtonUI.shadowColor
        button.layer.shadowOpacity             = Constants.CircleButtonUI.shadowOpacity
        button.layer.shadowRadius              = Constants.CircleButtonUI.shadowRadius
        button.layer.shadowOffset              = Constants.CircleButtonUI.shadowOffset
        button.titleLabel?.layer.shadowColor   = Constants.CircleButtonUI.titleShadowColor
        button.titleLabel?.layer.shadowOpacity = Constants.CircleButtonUI.titleShadowOpacity
        button.titleLabel?.layer.shadowRadius  = Constants.CircleButtonUI.titleShadowRadius
        button.titleLabel?.layer.shadowOffset  = Constants.CircleButtonUI.titleShadowOffset
        button.layer.masksToBounds             = Constants.CircleButtonUI.masksToBounds
    }
    
    static func configureTintedStyleButtonColor(for button: UIButton) {
        button.tintColor = Color.dodgerBlue
        button.setTitleColor(Color.dodgerBlue, for: .normal)
    }
    
    
    //MARK: - TextField UI
    static func configureTextFieldUI(forTextField textField: UITextField) {
        textField.layer.shadowColor   = Constants.TextFieldUI.shadowColor
        textField.layer.shadowOpacity = Constants.TextFieldUI.shadowOpacity
        textField.layer.shadowRadius  = Constants.TextFieldUI.shadowRadius
        textField.layer.shadowOffset  = Constants.TextFieldUI.shadowOffset
        textField.layer.cornerRadius  = Constants.TextFieldUI.cornerRadius
        textField.layer.masksToBounds = Constants.TextFieldUI.masksToBounds
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
