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
        
        let blueClosure = { (action: UIAction) in
            button.setTitleColor(UIElements.Color.mapShareBlue, for: .normal)
            button.tintColor = UIElements.Tint.blueTint
        }
        
        let greenClosure = { (action: UIAction) in
            button.setTitleColor(UIElements.Color.mapShareGreen, for: .normal)
            button.tintColor = UIElements.Tint.greenTint
        }
        
        let purpleClosure = { (action: UIAction) in
            button.setTitleColor(UIElements.Color.mapSharePurple, for: .normal)
            button.tintColor = UIElements.Tint.purpleTint
        }
        
        let pinkClosure = { (action: UIAction) in
            button.setTitleColor(UIElements.Color.mapSharePink, for: .normal)
            button.tintColor = UIElements.Tint.pinkTint
        }
        
        let cyanClosure = { (action: UIAction) in
            button.setTitleColor(UIElements.Color.mapShareCyan, for: .normal)
            button.tintColor = UIElements.Tint.cyanTint
        }
        
        let yellowClosure = { (action: UIAction) in
            button.setTitleColor(UIElements.Color.mapShareYellow, for: .normal)
            button.tintColor = UIElements.Tint.yellowTint
        }
        
        let orangeClosure = { (action: UIAction) in
            button.setTitleColor(UIElements.Color.mapShareOrange, for: .normal)
            button.tintColor = UIElements.Tint.orangeTint
        }
        
        button.menu = UIMenu(children: [
            UIAction(title: "↓", attributes: .hidden, state: .on, handler: closure),
            UIAction(title: "● Red", handler: redClosure),
            UIAction(title: "● Orange", handler: orangeClosure),
            UIAction(title: "● Yellow", handler: yellowClosure),
            UIAction(title: "● Green", handler: greenClosure),
            UIAction(title: "● Blue", handler: blueClosure),
            UIAction(title: "● Purple", handler: purpleClosure),
            UIAction(title: "● Pink", handler: pinkClosure),
            UIAction(title: "● Cyan", handler: cyanClosure)
        ])
        button.showsMenuAsPrimaryAction = true
        button.changesSelectionAsPrimaryAction = true
    }
}
