//
//  PopUpButton.swift
//  MapShare
//
//  Created by Chase on 5/16/23.
//

import UIKit

struct PopUpButton {
    
    static func setUpPopUpButton(for button: UIButton) {
        let closure = { (action: UIAction) in
            print(action.title)
        }
        
        let redClosure = { (action: UIAction) in
            button.setTitleColor(UIElements.Color.mapShareRed, for: .normal)
            button.tintColor = UIElements.Tint.redTint
        }
        
        let pinkClosure = { (action: UIAction) in
            button.setTitleColor(UIElements.Color.mapSharePink, for: .normal)
            button.tintColor = UIElements.Tint.pinkTint
        }
        
        let orangeClosure = { (action: UIAction) in
            button.setTitleColor(UIElements.Color.mapShareOrange, for: .normal)
            button.tintColor = UIElements.Tint.orangeTint
        }
        
        let yellowClosure = { (action: UIAction) in
            button.setTitleColor(UIElements.Color.mapShareYellow, for: .normal)
            button.tintColor = .label
        }
        
        let greenClosure = { (action: UIAction) in
            button.setTitleColor(UIElements.Color.mapShareGreen, for: .normal)
            button.tintColor = UIElements.Tint.greenTint
        }
        
        let cyanClosure = { (action: UIAction) in
            button.setTitleColor(UIElements.Color.mapShareCyan, for: .normal)
            button.tintColor = UIElements.Tint.cyanTint
        }
        
        let blueClosure = { (action: UIAction) in
            button.setTitleColor(UIElements.Color.mapShareBlue, for: .normal)
            button.tintColor = UIElements.Tint.blueTint
        }
        
        let purpleClosure = { (action: UIAction) in
            button.setTitleColor(UIElements.Color.mapSharePurple, for: .normal)
            button.tintColor = UIElements.Tint.purpleTint
        }
        
        button.menu = UIMenu(children: [
            UIAction(title: "↓", attributes: .hidden, state: .on, handler: closure),
            UIAction(title: "Red",    image: UIImage(systemName: "circle.fill")?.withTintColor(UIElements.Color.mapShareRed, renderingMode: .alwaysOriginal), handler: redClosure),
            UIAction(title: "Pink",   image: UIImage(systemName: "circle.fill")?.withTintColor(UIElements.Color.mapSharePink, renderingMode: .alwaysOriginal), handler: pinkClosure),
            UIAction(title: "Orange", image: UIImage(systemName: "circle.fill")?.withTintColor(UIElements.Color.mapShareOrange, renderingMode: .alwaysOriginal), handler: orangeClosure),
            UIAction(title: "Yellow", image: UIImage(systemName: "circle.fill")?.withTintColor(UIElements.Color.mapShareYellow, renderingMode: .alwaysOriginal), handler: yellowClosure),
            UIAction(title: "Green",  image: UIImage(systemName: "circle.fill")?.withTintColor(UIElements.Color.mapShareGreen, renderingMode: .alwaysOriginal), handler: greenClosure),
            UIAction(title: "Cyan",   image: UIImage(systemName: "circle.fill")?.withTintColor(UIElements.Color.mapShareCyan, renderingMode: .alwaysOriginal), handler: cyanClosure),
            UIAction(title: "Blue",   image: UIImage(systemName: "circle.fill")?.withTintColor(UIElements.Color.mapShareBlue, renderingMode: .alwaysOriginal), handler: blueClosure),
            UIAction(title: "Purple", image: UIImage(systemName: "circle.fill")?.withTintColor(UIElements.Color.mapSharePurple, renderingMode: .alwaysOriginal), handler: purpleClosure)
        ])
        
        button.showsMenuAsPrimaryAction = true
        button.changesSelectionAsPrimaryAction = true
        button.preferredMenuElementOrder = .fixed
    }
}
