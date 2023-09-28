//
//  NewSessionViewController.swift
//  MapShare
//
//  Created by iMac Pro on 4/27/23.
//

import UIKit

class NewSessionViewController: UIViewController {
    
    //MARK: - Outlets
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
    
    //MARK: - Properties
    override var sheetPresentationController: UISheetPresentationController {
        presentationController as! UISheetPresentationController
    }
    
    var newSessionViewModel: NewSessionViewModel!
  
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSheetPresentationController()
        configureUI()
        setupNotifications()
    }
    
    
    //MARK: - IB Actions
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
            present(AlertControllers.needSessionName(), animated: true)
        } else if firstName.isEmpty {
            present(AlertControllers.needFirstName(), animated: true)
        } else if lastName.isEmpty {
            present(AlertControllers.needLastName(), animated: true)
        } else if userColorPopUpButton.titleLabel?.text == "↓" {
            present(AlertControllers.needColorChoice(), animated: true)
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
            userColorPopUpButton.backgroundColor = UIColor.dodgerBlue()
        }
    }
    
    
    //MARK: - Functions
    private func configureSheetPresentationController() {
        let screenHeight = view.frame.height
        sheetPresentationController.detents = Detents.buildDetent(screenHeight: screenHeight)
        sheetPresentationController.prefersGrabberVisible = true
        sheetPresentationController.largestUndimmedDetentIdentifier = sheetPresentationController.detents[2].identifier
    }
    
    private func configureUI() {
        UIStyling.styleLogo(forImageView: mapShareLogoImageView)
        [newMapShareButton, joinMapShareButton, createSessionButton].forEach { button in
            if let button { UIStyling.styleFilledButton(for: button, withColor: UIColor.dodgerBlue()) }
        }
        [sessionNameTextField, firstNameTextField, lastNameTextField, screenNameTextField].forEach { textField in
            if let textField { UIStyling.styleTextField(forTextField: textField) }
        }
        PopUpButton.setUpPopUpButton(for: userColorPopUpButton, withState: .on)
        UIStyling.stylePopUpButton(for: userColorPopUpButton)
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(alertLocationAccessNeeded), name: Constants.Notifications.locationAccessNeeded, object: nil)
    }
    
    @objc func alertLocationAccessNeeded() {
        present(AlertControllers.needLocationAccess(), animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toActiveSessionVC" {
            guard let destinationVC = segue.destination as? ActiveSessionViewController,
                  let mapDelegate   = newSessionViewModel.mapDelegate,
                  let session       = newSessionViewModel.session else { return }
            destinationVC.activeSessionViewModel = ActiveSessionViewModel(session: session, delegate: destinationVC.self, mapDelegate: mapDelegate)
        } else if segue.identifier == "toJoinSessionVC" {
            guard let destinationVC = segue.destination as? JoinSessionViewController,
                  let delegate      = newSessionViewModel.mapDelegate else { return }
            destinationVC.joinSessionViewModel = JoinSessionViewModel(delegate: destinationVC, mapDelegate: delegate)
        }
    }
} //: CLASS


//MARK: - TextFieldDelegate
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
