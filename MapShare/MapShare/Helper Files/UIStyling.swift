//
//  UIElements.swift
//  MapShare
//
//  Created by iMac Pro on 5/10/23.
//

import UIKit

struct UIStyling {   
    
    //MARK: - Map Home UI
    static func styleLabel(for label: UILabel) {
        label.layer.shadowColor   = UIColor.black.cgColor
        label.layer.shadowOpacity = 0.4
        label.layer.shadowRadius  = 2
        label.layer.shadowOffset  = CGSize(width: 0, height: 2)
        label.layer.masksToBounds = false
    }
    
    
    //MARK: - Button Attributes
    static func styleFilledButton(for button: UIButton, withColor color: UIColor) {
        button.configuration?.baseBackgroundColor = color
        button.layer.shadowColor                  = UIColor.black.cgColor
        button.layer.shadowOpacity                = 0.4
        button.layer.shadowRadius                 = 2
        button.layer.shadowOffset                 = CGSize(width: 0, height: 2)
        button.titleLabel?.layer.shadowColor      = UIColor.black.cgColor
        button.titleLabel?.layer.shadowOpacity    = 0.4
        button.titleLabel?.layer.shadowRadius     = 1
        button.titleLabel?.layer.shadowOffset     = CGSize(width: 0, height: 1)
        button.layer.masksToBounds                = false
    }
    
    static func stylePopUpButton(for button: UIButton) {
        button.layer.cornerRadius                 = 6
        button.layer.shadowColor                  = UIColor.black.cgColor
        button.layer.shadowOpacity                = 0.4
        button.layer.shadowRadius                 = 2
        button.layer.shadowOffset                 = CGSize(width: 0, height: 2)
        button.titleLabel?.layer.shadowColor      = UIColor.black.cgColor
        button.titleLabel?.layer.shadowOpacity    = 0.4
        button.titleLabel?.layer.shadowRadius     = 1
        button.titleLabel?.layer.shadowOffset     = CGSize(width: 0, height: 1)
        button.layer.masksToBounds                = false
        
    }
    
    static func styleWaitingRoomButton(for button: UIButton, withColor color: UIColor) {
        button.layer.backgroundColor           = color.cgColor
        button.layer.cornerRadius              = 6
        button.layer.shadowColor               = UIColor.black.cgColor
        button.layer.shadowOpacity             = 0.4
        button.layer.shadowRadius              = 2
        button.layer.shadowOffset              = CGSize(width: 0, height: 2)
        button.titleLabel?.layer.shadowColor   = UIColor.black.cgColor
        button.titleLabel?.layer.shadowOpacity = 0.4
        button.titleLabel?.layer.shadowRadius  = 1
        button.titleLabel?.layer.shadowOffset  = CGSize(width: 0, height: 1)
        button.layer.masksToBounds             = false
    }
    
    static func styleCircleButton(for button: UIButton, backgroundColor: UIColor, tintColor: UIColor) {
        button.backgroundColor                 = backgroundColor
        button.tintColor                       = tintColor
        button.layer.cornerRadius              = button.frame.height / 2
        button.layer.shadowColor               = UIColor.black.cgColor
        button.layer.shadowOpacity             = 0.4
        button.layer.shadowRadius              = 2
        button.layer.shadowOffset              = CGSize(width: 0, height: 2)
        button.titleLabel?.layer.shadowColor   = UIColor.black.cgColor
        button.titleLabel?.layer.shadowOpacity = 0.4
        button.titleLabel?.layer.shadowRadius  = 1
        button.titleLabel?.layer.shadowOffset  = CGSize(width: 0, height: 1)
        button.layer.masksToBounds             = false
    }
    
    
    //MARK: - TextField UI
    static func styleTextField(forTextField textField: UITextField) {
        textField.layer.shadowColor   = UIColor.black.cgColor
        textField.layer.shadowOpacity = 0.1
        textField.layer.shadowRadius  = 2
        textField.layer.shadowOffset  = CGSize(width: 0, height: 2)
        textField.layer.cornerRadius  = 6
        textField.layer.masksToBounds = false
    }
    
    static func styleLogo(forImageView imageView: UIImageView) {
        imageView.layer.shadowColor   = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.4
        imageView.layer.shadowRadius  = 2
        imageView.layer.shadowOffset  = CGSize(width: 0, height: 1)
        imageView.layer.masksToBounds = true
    }
}
