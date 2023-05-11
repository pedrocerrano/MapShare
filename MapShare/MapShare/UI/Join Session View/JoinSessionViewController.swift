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
    @IBOutlet weak var memberIconColorButton: UIButton!
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
        memberIconColorButton.isHidden = true
        joinSessionButton.isHidden = true
        waitingStatusLabel.isHidden = true
    }
    
    func revealJoinSessionTextFields() {
        tellTheGroupLabel.isHidden = false
        memberfirstNameTextField.isHidden = false
        memberLastNameTextField.isHidden = false
        memberScreenNameTextField.isHidden = false
        iconColorLabel.isHidden = false
        memberIconColorButton.isHidden = false
        joinSessionButton.isHidden = false
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
            destinationVC.activeSessionViewModel = ActiveSessionViewModel(session: session, delegate: destinationVC.self)
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
