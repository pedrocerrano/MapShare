//
//  NewSessionViewController.swift
//  MapShare
//
//  Created by iMac Pro on 4/27/23.
//

import UIKit

class NewSessionViewController: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var newMapShareButton: UIButton!
    @IBOutlet weak var joinMapShareButton: UIButton!
    @IBOutlet weak var newMapShareTitleLabel: UILabel!
    @IBOutlet weak var sessionNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var screenNameTextField: UITextField!
    @IBOutlet weak var userColorPopUpButton: UIButton!
    @IBOutlet weak var createSessionButton: UIButton!
    
    //MARK: - PROPERTIES
    override var sheetPresentationController: UISheetPresentationController {
        presentationController as! UISheetPresentationController
    }
    
    var newSessionViewModel: NewSessionViewModel!

    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSheetPresentationController()
        configureUI()
    }
    
    
    //MARK: - IB ACTIONS
    @IBAction func mapShareButtonTapped(_ sender: Any) {
        sheetPresentationController.animateChanges {
            sheetPresentationController.selectedDetentIdentifier = sheetPresentationController.detents[2].identifier
        }
    }
    
    
    @IBAction func joinSessionButtonTapped(_ sender: Any) {
        sheetPresentationController.animateChanges {
            sheetPresentationController.selectedDetentIdentifier = sheetPresentationController.detents[0].identifier
        }
    }
    
    
    @IBAction func createSessionButtonTapped(_ sender: Any) {
        guard let sessionName        = sessionNameTextField.text,
              let firstName          = firstNameTextField.text,
              let lastName           = lastNameTextField.text,
              let screenName         = screenNameTextField.text,
              let markerColor        = userColorPopUpButton.titleLabel?.textColor.convertColorToString(),
              let organizerLatitude  = newSessionViewModel.locationManager.location?.coordinate.latitude,
              let organizerLongitude = newSessionViewModel.locationManager.location?.coordinate.longitude else { return }
        var optionalScreenName = ""
        if screenName.isEmpty {
            optionalScreenName = firstName
        } else {
            optionalScreenName = screenName
        }
        
        if sessionName.isEmpty {
            presentSessionNeedsNameAlert()
        } else if firstName.isEmpty {
            presentNeedsFirstNameAlert()
        } else if lastName.isEmpty {
            presentNeedsLastNameAlert()
        } else if userColorPopUpButton.titleLabel?.text == "↓" {
            presentChooseColorAlert()
        } else {
            newSessionViewModel.createNewMapShareSession(sessionName: sessionName, sessionCode: newSessionViewModel.sessionCode, firstName: firstName, lastName: lastName, screenName: optionalScreenName, markerColor: markerColor, organizerLatitude: organizerLatitude, organizerLongitude: organizerLongitude)
            [sessionNameTextField, firstNameTextField, lastNameTextField, screenNameTextField].forEach { textField in
                if let textField {
                    textField.resignFirstResponder()
                    textField.text = ""
                }
            }
            sheetPresentationController.animateChanges {
                sheetPresentationController.selectedDetentIdentifier = sheetPresentationController.detents[0].identifier
            }
            PopUpButton.setUpPopUpButton(for: userColorPopUpButton)
            UIElements.configureTintedStyleButtonColor(for: userColorPopUpButton)
        }
    }
    
    
    //MARK: - FUNCTIONS
    func configureSheetPresentationController() {
        let screenHeight = view.frame.height
        sheetPresentationController.detents = Detents.buildDetent(screenHeight: screenHeight)
        sheetPresentationController.prefersGrabberVisible = true
        sheetPresentationController.largestUndimmedDetentIdentifier = sheetPresentationController.detents[2].identifier
    }
    
    func configureUI() {
        UIElements.configureFilledStyleButtonAttributes(for: newMapShareButton, withColor: UIElements.Color.dodgerBlue)
        UIElements.configureFilledStyleButtonAttributes(for: joinMapShareButton, withColor: UIElements.Color.dodgerBlue)
        UIElements.configureFilledStyleButtonAttributes(for: createSessionButton, withColor: UIElements.Color.dodgerBlue)
        PopUpButton.setUpPopUpButton(for: userColorPopUpButton)
        UIElements.configureTintedStyleButtonColor(for: userColorPopUpButton)
    }
    
    
    //MARK: - ALERTS
    func presentSessionNeedsNameAlert() {
        let emptySessionNameAlertController = UIAlertController(title: "No Name Given", message: "Please name this MapShare session.", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Will do!", style: .cancel)
        emptySessionNameAlertController.addAction(dismissAction)
        present(emptySessionNameAlertController, animated: true)
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
    
    func presentChooseColorAlert() {
        let noColorSelectedAlertController = UIAlertController(title: "Select Color", message: "Please select your desired color so the MapShare members can identify you.", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Okay", style: .cancel)
        noColorSelectedAlertController.addAction(dismissAction)
        present(noColorSelectedAlertController, animated: true)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toActiveSessionVC" {
            guard let destinationVC = segue.destination as? ActiveSessionViewController,
                  let mapHomeDelegate = newSessionViewModel.mapHomeDelegate,
                  let session = newSessionViewModel.session else { return }
            destinationVC.activeSessionViewModel = ActiveSessionViewModel(session: session, delegate: destinationVC.self, mapHomeDelegate: mapHomeDelegate)
        } else if segue.identifier == "toJoinSessionVC" {
            guard let destinationVC = segue.destination as? JoinSessionViewController,
                  let delegate = newSessionViewModel.mapHomeDelegate else { return }
            destinationVC.joinSessionViewModel = JoinSessionViewModel(delegate: destinationVC, mapHomeDelegate: delegate)
        }
    }
} //: CLASS

extension NewSessionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        #warning("Come back to clean up into switch statements")
        if textField == sessionNameTextField {
            firstNameTextField.becomeFirstResponder()
        } else if textField == firstNameTextField {
            lastNameTextField.becomeFirstResponder()
        } else if textField == lastNameTextField {
            screenNameTextField.becomeFirstResponder()
        } else if textField == screenNameTextField {
            textField.resignFirstResponder()
        }
        return true
    }
} //: TextFieldDelegate
