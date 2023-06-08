//
//  PopUpButton.swift
//  MapShare
//
//  Created by Chase on 5/16/23.
//

import UIKit

struct PopUpButton {
    
    static func setUpPopUpButton(for button: UIButton) {
        let defaultClosure = { (action: UIAction) in
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIElements.Color.dodgerBlue
        }
        
        let redClosure = { (action: UIAction) in
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIElements.Color.mapShareRed
            button.tintColor = .white
        }
        
        let pinkClosure = { (action: UIAction) in
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIElements.Color.mapSharePink
            button.tintColor = .white
        }
        
        let orangeClosure = { (action: UIAction) in
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIElements.Color.mapShareOrange
            button.tintColor = .white
        }
        
        let yellowClosure = { (action: UIAction) in
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIElements.Color.mapShareYellow
            button.tintColor = .white
        }
        
        let greenClosure = { (action: UIAction) in
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIElements.Color.mapShareGreen
            button.tintColor = .white
        }
        
        let cyanClosure = { (action: UIAction) in
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIElements.Color.mapShareCyan
            button.tintColor = .white
        }
        
        let blueClosure = { (action: UIAction) in
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIElements.Color.mapShareBlue
            button.tintColor = .white
        }
        
        let purpleClosure = { (action: UIAction) in
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIElements.Color.mapSharePurple
            button.tintColor = .white
        }
        
        button.menu = UIMenu(children: [
            UIAction(title: "↓", attributes: .hidden, state: .on, handler: defaultClosure),
            UIAction(title: "Red",    image: UIImage(systemName: "circle.fill")?.withTintColor(UIElements.Color.mapShareRed, renderingMode: .alwaysOriginal), handler: redClosure),
            UIAction(title: "Pink",   image: UIImage(systemName: "circle.fill")?.withTintColor(UIElements.Color.mapSharePink, renderingMode: .alwaysOriginal), handler: pinkClosure),
            UIAction(title: "Orange", image: UIImage(systemName: "circle.fill")?.withTintColor(UIElements.Color.mapShareOrange, renderingMode: .alwaysOriginal), handler: orangeClosure),
            UIAction(title: "Yellow", image: UIImage(systemName: "circle.fill")?.withTintColor(UIElements.Color.mapShareYellow, renderingMode: .alwaysOriginal), handler: yellowClosure),
            UIAction(title: "Green",  image: UIImage(systemName: "circle.fill")?.withTintColor(UIElements.Color.mapShareGreen, renderingMode: .alwaysOriginal), handler: greenClosure),
            UIAction(title: "Cyan",   image: UIImage(systemName: "circle.fill")?.withTintColor(UIElements.Color.mapShareCyan, renderingMode: .alwaysOriginal), handler: cyanClosure),
            UIAction(title: "Blue",   image: UIImage(systemName: "circle.fill")?.withTintColor(UIElements.Color.mapShareBlue, renderingMode: .alwaysOriginal), handler: blueClosure),
            UIAction(title: "Purple", image: UIImage(systemName: "circle.fill")?.withTintColor(UIElements.Color.mapSharePurple, renderingMode: .alwaysOriginal), handler: purpleClosure)
        ])
        
        button.showsMenuAsPrimaryAction        = true
        button.changesSelectionAsPrimaryAction = true
        button.preferredMenuElementOrder       = .fixed
    }
}
