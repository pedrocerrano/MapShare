//
//  JoinSessionViewController.swift
//  MapShare
//
//  Created by iMac Pro on 5/8/23.
//

import UIKit

class JoinSessionViewController: UIViewController {

    //MARK: - OUTLETS
    @IBOutlet weak var codeEntryTextField: UITextField!
    @IBOutlet weak var searchSessionButton: UIButton!
    @IBOutlet weak var tellTheGroupLabel: UILabel!
    @IBOutlet weak var memberfirstNameTextField: UITextField!
    @IBOutlet weak var memberLastNameTextField: UITextField!
    @IBOutlet weak var memberScreenNameTextField: UITextField!
    @IBOutlet weak var iconColorLabel: UILabel!
    @IBOutlet weak var userColorPopUpButton: UIButton!
    @IBOutlet weak var joinSessionButton: UIButton!
    @IBOutlet weak var waitingStatusLabel: UILabel!
    
    
    //MARK: - PROPERTIES
    var joinSessionViewModel: JoinSessionViewModel!
    
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        joinSessionViewModel = JoinSessionViewModel(delegate: self)
        codeEntryTextField.delegate = self
        
        hideJoinSessionTextFields()
        setUpPopUpButton()
    }
    
    
    //MARK: - IB ACTIONS
    @IBAction func searchSessionButtonTapped(_ sender: Any) {
        tellTheGroupLabel.isHidden = true
        guard let codeEntry = codeEntryTextField.text else { return }
        if codeEntry.isEmpty || codeEntry.count != 6 {
            hideJoinSessionTextFields()
            presentNeedsSixDigitsAlert()
        } else {
            joinSessionViewModel.searchFirebase(with: codeEntry)
            codeEntryTextField.resignFirstResponder()
        }
    }
    
    @IBAction func joinSessionButtonTapped(_ sender: Any) {
        guard let firstName = memberfirstNameTextField.text,
              let lastName = memberLastNameTextField.text,
              let screenName = memberScreenNameTextField.text else { return }
        let markerColor = "RED"
        let dallasLat: Double = 32.779167
        let dallasLon: Double = -96.808891
        var optionalScreenName = ""
        if screenName.isEmpty {
            optionalScreenName = firstName
        } else {
            optionalScreenName = screenName
        }
        
        if firstName.isEmpty {
            presentNeedsFirstNameAlert()
        } else if lastName.isEmpty {
            presentNeedsLastNameAlert()
        } else {
            joinSessionViewModel.addNewMemberToActiveSession(withCode: joinSessionViewModel.validSessionCode, firstName: firstName, lastName: lastName, screenName: optionalScreenName, markerColor: markerColor, memberLatitude: dallasLat, memberLongitude: dallasLon)
            memberfirstNameTextField.resignFirstResponder()
            memberfirstNameTextField.text?.removeAll()
            memberLastNameTextField.resignFirstResponder()
            memberLastNameTextField.text?.removeAll()
            memberScreenNameTextField.resignFirstResponder()
            memberScreenNameTextField.text?.removeAll()
            waitingStatusLabel.isHidden = false
            NotificationCenter.default.post(name: Constants.Notifications.newMemberWaitingToJoin, object: nil)
            
            waitingStatusLabel.text = "Waiting for admission"
            #warning("Setup Activity Indicator")
        }
        
    }
    
    
    //MARK: - FUNCTIONS
    func hideJoinSessionTextFields() {
        tellTheGroupLabel.isHidden = true
        memberfirstNameTextField.isHidden = true
        memberLastNameTextField.isHidden = true
        memberScreenNameTextField.isHidden = true
        iconColorLabel.isHidden = true
        userColorPopUpButton.isHidden = true
        joinSessionButton.isHidden = true
        waitingStatusLabel.isHidden = true
    }
    
    func revealJoinSessionTextFields() {
        tellTheGroupLabel.isHidden = false
        memberfirstNameTextField.isHidden = false
        memberLastNameTextField.isHidden = false
        memberScreenNameTextField.isHidden = false
        iconColorLabel.isHidden = false
        userColorPopUpButton.isHidden = false
        joinSessionButton.isHidden = false
    }
    
    func setUpPopUpButton() {
//        let closure = { (action: UIAction) in
//            print(action.title)
//            guard let titleLabel = self.userColorPopUpButton.titleLabel?.text else { return }
//            if titleLabel == "Red" {
//                self.userColorPopUpButton.tintColor = .red
//            } else if titleLabel == "Blue" {
//                self.userColorPopUpButton.tintColor = .blue
//            } else if titleLabel == "Green" {
//                self.userColorPopUpButton.tintColor = .green
//            } else if titleLabel == "Purple" {
//                self.userColorPopUpButton.tintColor = .purple
//            } else if titleLabel == "Pink" {
//                self.userColorPopUpButton.tintColor = .systemPink
//            } else if titleLabel == "Cyan" {
//                self.userColorPopUpButton.tintColor = .cyan
//            } else if titleLabel == "Yellow" {
//                self.userColorPopUpButton.tintColor = .yellow
//            } else if titleLabel == "Brown" {
//                self.userColorPopUpButton.tintColor = .brown
//            }
//        }
        let closure = { (action: UIAction) in
            print(action.title)
        }
        
        let redClosure = { (action: UIAction) in
            let red = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
            let redTint = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.6)
            self.userColorPopUpButton.setTitleColor(red, for: .normal)
            self.userColorPopUpButton.tintColor = redTint
        }
        
        let blueClosure = { (action: UIAction) in
            let blue = UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1)
            let blueTint = UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 0.6)
            self.userColorPopUpButton.setTitleColor(blue, for: .normal)
            self.userColorPopUpButton.tintColor = blueTint
        }
        
        let greenClosure = { (action: UIAction) in
            let green = UIColor(red: 30/255, green: 180/255, blue: 35/255, alpha: 1)
            let greenTint = UIColor(red: 0/255, green: 255/255, blue: 0/255, alpha: 0.6)
            self.userColorPopUpButton.setTitleColor(green, for: .normal)
            self.userColorPopUpButton.tintColor = greenTint
        }
        
        let purpleClosure = { (action: UIAction) in
            let purple = UIColor(red: 160/255, green: 32/255, blue: 240/255, alpha: 1)
            let purpleTint = UIColor(red: 160/255, green: 32/255, blue: 240/255, alpha: 0.6)
            self.userColorPopUpButton.setTitleColor(purple, for: .normal)
            self.userColorPopUpButton.tintColor = purpleTint
        }
        
        let pinkClosure = { (action: UIAction) in
            let pink = UIColor(red: 255/255, green: 20/255, blue: 147/255, alpha: 1)
            let pinkTint = UIColor(red: 255/255, green: 192/255, blue: 203/255, alpha: 0.9)
            self.userColorPopUpButton.setTitleColor(pink, for: .normal)
            self.userColorPopUpButton.tintColor = pinkTint
        }
        
        let cyanClosure = { (action: UIAction) in
            let cyan = UIColor(red: 64/255, green: 224/255, blue: 208/255, alpha: 1)
            let cyanTint = UIColor(red: 64/255, green: 224/255, blue: 208/255, alpha: 0.8)
            self.userColorPopUpButton.setTitleColor(cyan, for: .normal)
            self.userColorPopUpButton.tintColor = cyanTint
        }
        
        let yellowClosure = { (action: UIAction) in
            let yellow = UIColor(red: 215/255, green: 180/255, blue: 0/255, alpha: 1)
            let yellowTint = UIColor(red: 210/255, green: 180/255, blue: 40/255, alpha: 1)
            self.userColorPopUpButton.setTitleColor(yellow, for: .normal)
            self.userColorPopUpButton.tintColor = yellowTint
        }
        
        let brownClosure = { (action: UIAction) in
            let brown = UIColor(red: 139/255, green: 69/255, blue: 19/255, alpha: 1)
            let brownTint = UIColor(red: 139/255, green: 69/255, blue: 19/255, alpha: 0.6)
            self.userColorPopUpButton.setTitleColor(brown, for: .normal)
            self.userColorPopUpButton.tintColor = brownTint
        }
        
        let orangeClosure = { (action: UIAction) in
            let orange = UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 1)
            let orangeTint = UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 0.8)
            self.userColorPopUpButton.setTitleColor(orange, for: .normal)
            self.userColorPopUpButton.tintColor = orangeTint
        }
        
        userColorPopUpButton.menu = UIMenu(children: [
            UIAction(title: "↓", attributes: .hidden, state: .on, handler: closure),
            UIAction(title: "● Brown", handler: brownClosure),
            UIAction(title: "● Red", handler: redClosure),
            UIAction(title: "● Orange", handler: orangeClosure),
            UIAction(title: "● Yellow", handler: yellowClosure),
            UIAction(title: "● Green", handler: greenClosure),
            UIAction(title: "● Blue", handler: blueClosure),
            UIAction(title: "● Purple", handler: purpleClosure),
            UIAction(title: "● Pink", handler: pinkClosure),
            UIAction(title: "● Cyan", handler: cyanClosure)
        ])
        userColorPopUpButton.showsMenuAsPrimaryAction = true
        userColorPopUpButton.changesSelectionAsPrimaryAction = true
    }
    
    //MARK: - ALERTS
    func presentNeedsSixDigitsAlert() {
        let needsSixDigitsAlertController = UIAlertController(title: "Invalid Session Code", message: "Please retype a six-digit session code.", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Okay", style: .cancel)
        needsSixDigitsAlertController.addAction(dismissAction)
        present(needsSixDigitsAlertController, animated: true)
    }
    
    func presentNeedsFirstNameAlert() {
        let emptyFirstNameAlertController = UIAlertController(title: "Need First Name", message: "Please share your first name for others to identify you.", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Okay", style: .cancel)
        emptyFirstNameAlertController.addAction(dismissAction)
        present(emptyFirstNameAlertController, animated: true)
    }
    
    func presentNeedsLastNameAlert() {
        let emptyLastNameAlertController = UIAlertController(title: "Need Last Name", message: "Please share your last name for others to identify you.", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Okay", style: .cancel)
        emptyLastNameAlertController.addAction(dismissAction)
        present(emptyLastNameAlertController, animated: true)
    }
    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toJoinActiveSessionVC" {
            guard let destinationVC = segue.destination as? ActiveSessionViewController,
                  let session = joinSessionViewModel.searchedSession else { return }
            destinationVC.activeSessionViewModel = ActiveSessionViewModel(session: session)
        }
    }
} //: CLASS


//MARK: - EXT: ViewModelDelegate
extension JoinSessionViewController: JoinSessionViewModelDelegate {
    func sessionExists() {
        guard let codeEntry = codeEntryTextField.text else { return }
        tellTheGroupLabel.text = """
                                    We found \"\(codeEntry)\"
                                    Share with the group:
                                 """
        joinSessionViewModel.validSessionCode = codeEntry
        revealJoinSessionTextFields()
    }
    
    func noSessionFoundWithCode() {
        tellTheGroupLabel.isHidden = false
        tellTheGroupLabel.text     = """
                                        No session found.
                                        Please try another code.
                                     """
    }
} //: ViewModelDelegate


//MARK: - EXT: TextFieldDelegate
extension JoinSessionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.codeEntryTextField {
            if let codeEntry = codeEntryTextField.text {
                if codeEntry.isEmpty || codeEntry.count != 6 {
                    presentNeedsSixDigitsAlert()
                } else {
                    joinSessionViewModel.searchFirebase(with: codeEntry)
                    joinSessionViewModel.validSessionCode = codeEntry
                    codeEntryTextField.resignFirstResponder()
                }
            }
        } else {
            #warning("Need to configure the keyboard to advance to the next textfield when return is pressed")
            if textField == self.memberfirstNameTextField {
                if let firstName = memberfirstNameTextField.text {
                    if firstName.isEmpty == true {
                        print("Booyah")
                    }
                }
            }
        }
        return true
    }
} //: TextFieldDelegate
