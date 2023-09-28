//
//  PopUpButton.swift
//  MapShare
//
//  Created by Chase on 5/16/23.
//

import UIKit

struct PopUpButton {
    
    static func setUpPopUpButton(for button: UIButton, withState state: UIMenuElement.State) {
        let defaultClosure = { (action: UIAction) in
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIColor.dodgerBlue()
        }
        
        let redClosure = { (action: UIAction) in
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIColor.mapShareRed()
            button.tintColor = .white
        }
        
        let pinkClosure = { (action: UIAction) in
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIColor.mapSharePink()
            button.tintColor = .white
        }
        
        let orangeClosure = { (action: UIAction) in
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIColor.mapShareOrange()
            button.tintColor = .white
        }
        
        let yellowClosure = { (action: UIAction) in
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIColor.mapShareYellow()
            button.tintColor = .white
        }
        
        let greenClosure = { (action: UIAction) in
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIColor.mapShareGreen()
            button.tintColor = .white
        }
        
        let cyanClosure = { (action: UIAction) in
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIColor.mapShareCyan()
            button.tintColor = .white
        }
        
        let blueClosure = { (action: UIAction) in
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIColor.mapShareBlue()
            button.tintColor = .white
        }
        
        let purpleClosure = { (action: UIAction) in
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIColor.mapSharePurple()
            button.tintColor = .white
        }
        
        button.menu = UIMenu(children: [
            UIAction(title: "↓", attributes: .hidden, state: state, handler: defaultClosure),
            UIAction(title: "Red",    image: UIImage(systemName: "circle.fill")?.withTintColor(UIColor.mapShareRed(), renderingMode: .alwaysOriginal), handler: redClosure),
            UIAction(title: "Pink",   image: UIImage(systemName: "circle.fill")?.withTintColor(UIColor.mapSharePink(), renderingMode: .alwaysOriginal), handler: pinkClosure),
            UIAction(title: "Orange", image: UIImage(systemName: "circle.fill")?.withTintColor(UIColor.mapShareOrange(), renderingMode: .alwaysOriginal), handler: orangeClosure),
            UIAction(title: "Yellow", image: UIImage(systemName: "circle.fill")?.withTintColor(UIColor.mapShareYellow(), renderingMode: .alwaysOriginal), handler: yellowClosure),
            UIAction(title: "Green",  image: UIImage(systemName: "circle.fill")?.withTintColor(UIColor.mapShareGreen(), renderingMode: .alwaysOriginal), handler: greenClosure),
            UIAction(title: "Cyan",   image: UIImage(systemName: "circle.fill")?.withTintColor(UIColor.mapShareCyan(), renderingMode: .alwaysOriginal), handler: cyanClosure),
            UIAction(title: "Blue",   image: UIImage(systemName: "circle.fill")?.withTintColor(UIColor.mapShareBlue(), renderingMode: .alwaysOriginal), handler: blueClosure),
            UIAction(title: "Purple", image: UIImage(systemName: "circle.fill")?.withTintColor(UIColor.mapSharePurple(), renderingMode: .alwaysOriginal), handler: purpleClosure)
        ])
        
        button.showsMenuAsPrimaryAction        = true
        button.changesSelectionAsPrimaryAction = true
        button.preferredMenuElementOrder       = .fixed
    }
}
