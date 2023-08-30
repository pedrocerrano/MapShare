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
    @IBOutlet weak var mapShareLogoImageView: UIImageView!
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
        setupNotifications()
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
              let markerColor        = userColorPopUpButton.backgroundColor,
              let organizerLatitude  = newSessionViewModel.locationManager.location?.coordinate.latitude,
              let organizerLongitude = newSessionViewModel.locationManager.location?.coordinate.longitude
        else { return }
    
        var optionalScreenName = ""
        if screenName.isEmpty {
            optionalScreenName = firstName
        } else {
            optionalScreenName = screenName
        }
        
        if sessionName.isEmpty {
            present(Alerts.needSessionName(), animated: true)
        } else if firstName.isEmpty {
            present(Alerts.needFirstName(), animated: true)
        } else if lastName.isEmpty {
            present(Alerts.needLastName(), animated: true)
        } else if userColorPopUpButton.titleLabel?.text == "↓" {
            present(Alerts.needColorChoice(), animated: true)
        } else {
            newSessionViewModel.createNewMapShareSession(sessionName: sessionName,
                                                         sessionCode: newSessionViewModel.sessionCode,
                                                         firstName: firstName,
                                                         lastName: lastName,
                                                         screenName: optionalScreenName,
                                                         markerColor: Member.convertColorToString(markerColor),
                                                         organizerLatitude: organizerLatitude,
                                                         organizerLongitude: organizerLongitude)
            [sessionNameTextField, firstNameTextField, lastNameTextField, screenNameTextField].forEach { textField in
                if let textField {
                    textField.resignFirstResponder()
                    textField.text = ""
                }
            }
            sheetPresentationController.animateChanges {
                sheetPresentationController.selectedDetentIdentifier = sheetPresentationController.detents[0].identifier
            }
            PopUpButton.setUpPopUpButton(for: userColorPopUpButton, withState: .off)
            userColorPopUpButton.backgroundColor = UIElements.Color.dodgerBlue
        }
    }
    
    
    //MARK: - FUNCTIONS
    private func configureSheetPresentationController() {
        let screenHeight = view.frame.height
        sheetPresentationController.detents = Detents.buildDetent(screenHeight: screenHeight)
        sheetPresentationController.prefersGrabberVisible = true
        sheetPresentationController.largestUndimmedDetentIdentifier = sheetPresentationController.detents[2].identifier
    }
    
    private func configureUI() {
        UIElements.configureFilledStyleButtonAttributes(for: newMapShareButton, withColor: UIElements.Color.dodgerBlue)
        UIElements.configureImageView(forImageView: mapShareLogoImageView)
        UIElements.configureFilledStyleButtonAttributes(for: joinMapShareButton, withColor: UIElements.Color.dodgerBlue)
        UIElements.configureTextFieldUI(forTextField: sessionNameTextField)
        UIElements.configureTextFieldUI(forTextField: firstNameTextField)
        UIElements.configureTextFieldUI(forTextField: lastNameTextField)
        UIElements.configureTextFieldUI(forTextField: screenNameTextField)
        PopUpButton.setUpPopUpButton(for: userColorPopUpButton, withState: .on)
        UIElements.configureTintedStylePopUpButton(for: userColorPopUpButton)
        UIElements.configureFilledStyleButtonAttributes(for: createSessionButton, withColor: UIElements.Color.dodgerBlue)
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(alertLocationAccessNeeded), name: Constants.Notifications.locationAccessNeeded, object: nil)
    }
    
    @objc func alertLocationAccessNeeded() {
        present(Alerts.needLocationAccess(), animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toActiveSessionVC" {
            guard let destinationVC   = segue.destination as? ActiveSessionViewController,
                  let mapHomeDelegate = newSessionViewModel.mapHomeDelegate,
                  let session         = newSessionViewModel.session else { return }
            destinationVC.activeSessionViewModel = ActiveSessionViewModel(session: session, delegate: destinationVC.self, mapHomeDelegate: mapHomeDelegate)
        } else if segue.identifier == "toJoinSessionVC" {
            guard let destinationVC = segue.destination as? JoinSessionViewController,
                  let delegate      = newSessionViewModel.mapHomeDelegate else { return }
            destinationVC.joinSessionViewModel = JoinSessionViewModel(delegate: destinationVC, mapHomeDelegate: delegate)
        }
    }
} //: CLASS

extension NewSessionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case sessionNameTextField:
            return firstNameTextField.becomeFirstResponder()
        case firstNameTextField:
            return lastNameTextField.becomeFirstResponder()
        case lastNameTextField:
            return screenNameTextField.becomeFirstResponder()
        case screenNameTextField:
            return textField.resignFirstResponder()
        default:
            return true
        }
    }
} //: TextFieldDelegate
