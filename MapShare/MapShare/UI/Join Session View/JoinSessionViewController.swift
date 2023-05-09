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
        
        disableJoinSessionTextFields()
    }
    
    
    //MARK: - IB ACTIONS
    @IBAction func searchSessionButtonTapped(_ sender: Any) {
        tellTheGroupLabel.isHidden = true
        guard let codeEntry = codeEntryTextField.text else { return }
        if codeEntry.isEmpty || codeEntry.count != 6 {
            presentNeedsSixDigitsAlert()
        } else {
            joinSessionViewModel.searchFirebase(with: codeEntry)
            codeEntryTextField.resignFirstResponder()
        }
    }
    
    @IBAction func joinSessionButtonTapped(_ sender: Any) {
        
    }
    
    
    //MARK: - FUNCTIONS
    func disableJoinSessionTextFields() {
        tellTheGroupLabel.isHidden = true
        memberfirstNameTextField.isHidden = true
        memberLastNameTextField.isHidden = true
        memberScreenNameTextField.isHidden = true
        iconColorLabel.isHidden = true
        memberIconColorButton.isHidden = true
        joinSessionButton.isHidden = true
        waitingStatusLabel.isHidden = true
    }
    
    func enableJoinSessionTextFields() {
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
        let emptyFirstNameAlertController = UIAlertController(title: "Need First Name", message: "Please share your first name for the MapShare members to identify you.", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Okay", style: .cancel)
        emptyFirstNameAlertController.addAction(dismissAction)
        present(emptyFirstNameAlertController, animated: true)
    }
    
    func presentNeedsLastNameAlert() {
        let emptyLastNameAlertController = UIAlertController(title: "Need Last Name", message: "Please share your last name for the MapShare members to identify you.", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Okay", style: .cancel)
        emptyLastNameAlertController.addAction(dismissAction)
        present(emptyLastNameAlertController, animated: true)
    }
    

    /*
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    */
} //: CLASS


//MARK: - EXT: ViewModelDelegate
extension JoinSessionViewController: JoinSessionViewModelDelegate {
    func sessionExists() {
        guard let codeEntry = codeEntryTextField.text else { return }
        tellTheGroupLabel.text = """
                                    We found \"\(codeEntry)\"
                                    Share with the group:
                                 """
        enableJoinSessionTextFields()
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
        if let codeEntry = codeEntryTextField.text {
            if codeEntry.isEmpty || codeEntry.count != 6 {
                presentNeedsSixDigitsAlert()
            } else {
                joinSessionViewModel.searchFirebase(with: codeEntry)
                codeEntryTextField.resignFirstResponder()
            }
        }
        return true
    }
} //: TextFieldDelegate
