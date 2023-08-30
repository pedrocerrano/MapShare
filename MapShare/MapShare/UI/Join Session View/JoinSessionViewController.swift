//
//  JoinSessionViewController.swift
//  MapShare
//
//  Created by iMac Pro on 5/8/23.
//

import UIKit
import MapKit
import CoreLocation
import CoreLocationUI

class JoinSessionViewController: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var closeJoinSessionSheetButton: UIButton!
    @IBOutlet weak var codeEntryTextField: UITextField!
    @IBOutlet weak var searchSessionButton: UIButton!
    @IBOutlet weak var tellTheGroupLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var memberFirstNameTextField: UITextField!
    @IBOutlet weak var memberLastNameTextField: UITextField!
    @IBOutlet weak var memberScreenNameTextField: UITextField!
    @IBOutlet weak var iconColorLabel: UILabel!
    @IBOutlet weak var userColorPopUpButton: UIButton!
    @IBOutlet weak var joinSessionButton: UIButton!
    
    
    //MARK: - PROPERTIES
    override var sheetPresentationController: UISheetPresentationController {
        presentationController as! UISheetPresentationController
    }
    
    var joinSessionViewModel: JoinSessionViewModel!
    var activityIndicator = UIActivityIndicatorView()
    
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        codeEntryTextField.delegate = self
        configureSheetPresentationController()
        sheetPresentationController.animateChanges {
            sheetPresentationController.selectedDetentIdentifier = sheetPresentationController.detents[2].identifier
        }
        hideJoinSessionTextFields()
        configureUI()
    }
    
    //MARK: - IB ACTIONS
    @IBAction func closeJoinSessionSheetButtonTapped(_ sender: Any) {
        sheetPresentationController.presentedViewController.isModalInPresentation = false
        sheetPresentationController.animateChanges {
            sheetPresentationController.dismissalTransitionWillBegin()
        }
        [codeEntryTextField, memberFirstNameTextField, memberLastNameTextField, memberScreenNameTextField].forEach { textField in
            if let textField {
                textField.resignFirstResponder()
                textField.text = ""
            }
        }
    }
    
    @IBAction func searchSessionButtonTapped(_ sender: Any) {
        tellTheGroupLabel.isHidden = true
        guard let codeEntry = codeEntryTextField.text else { return }
        confirmValidCode(with: codeEntry)
    }
    
    @IBAction func joinSessionButtonTapped(_ sender: Any) {
        guard let firstName       = memberFirstNameTextField.text,
              let lastName        = memberLastNameTextField.text,
              let screenName      = memberScreenNameTextField.text,
              let markerColor     = userColorPopUpButton.backgroundColor,
              let memberLatitude  = joinSessionViewModel.locationManager.location?.coordinate.latitude,
              let memberLongitude = joinSessionViewModel.locationManager.location?.coordinate.longitude else { return }
        var optionalScreenName    = ""
        if screenName.isEmpty {
            optionalScreenName = firstName
        } else {
            optionalScreenName = screenName
        }
        
        if firstName.isEmpty {
            present(Alerts.needFirstName(), animated: true)
        } else if lastName.isEmpty {
            present(Alerts.needLastName(), animated: true)
        } else if userColorPopUpButton.titleLabel?.text == "↓" {
            present(Alerts.needColorChoice(), animated: true)
        } else {
            joinSessionViewModel.addNewMemberToActiveSession(withCode: joinSessionViewModel.validSessionCode,
                                                             firstName: firstName,
                                                             lastName: lastName,
                                                             screenName: optionalScreenName,
                                                             markerColor: Member.convertColorToString(markerColor),
                                                             memberLatitude: memberLatitude,
                                                             memberLongitude: memberLongitude)
            [memberFirstNameTextField, memberLastNameTextField, memberScreenNameTextField].forEach { textField in
                if let textField {
                    textField.resignFirstResponder()
                    textField.text = ""
                }
            }
            sheetPresentationController.dismissalTransitionWillBegin()
            PopUpButton.setUpPopUpButton(for: userColorPopUpButton, withState: .off)
            userColorPopUpButton.backgroundColor = UIElements.Color.dodgerBlue
            logoImageView.isHidden = false
        }
    }
    
    
    //MARK: - FUNCTIONS
    private func configureSheetPresentationController() {
        let screenHeight = view.frame.height
        sheetPresentationController.detents = Detents.buildDetent(screenHeight: screenHeight)
        sheetPresentationController.prefersGrabberVisible = true
        sheetPresentationController.largestUndimmedDetentIdentifier = sheetPresentationController.detents[2].identifier
        sheetPresentationController.presentedViewController.isModalInPresentation = true
    }
    
    private func configureUI() {
        UIElements.configureCircleButtonAttributes(for: closeJoinSessionSheetButton, backgroundColor: UIElements.Color.dodgerBlue, tintColor: .white)
        UIElements.configureTextFieldUI(forTextField: codeEntryTextField)
        UIElements.configureFilledStyleButtonAttributes(for: searchSessionButton, withColor: UIElements.Color.dodgerBlue)
        UIElements.configureImageView(forImageView: logoImageView)
        logoImageView.isHidden = false
        UIElements.configureTextFieldUI(forTextField: memberFirstNameTextField)
        UIElements.configureTextFieldUI(forTextField: memberLastNameTextField)
        UIElements.configureTextFieldUI(forTextField: memberScreenNameTextField)
        PopUpButton.setUpPopUpButton(for: userColorPopUpButton, withState: .on)
        UIElements.configureTintedStylePopUpButton(for: userColorPopUpButton)
        UIElements.configureFilledStyleButtonAttributes(for: joinSessionButton, withColor: UIElements.Color.dodgerBlue)
    }
    
    private func hideJoinSessionTextFields() {
        tellTheGroupLabel.isHidden         = true
        memberFirstNameTextField.isHidden  = true
        memberLastNameTextField.isHidden   = true
        memberScreenNameTextField.isHidden = true
        iconColorLabel.isHidden            = true
        userColorPopUpButton.isHidden      = true
        joinSessionButton.isHidden         = true
    }
    
    private func revealJoinSessionTextFields() {
        tellTheGroupLabel.isHidden         = false
        memberFirstNameTextField.isHidden  = false
        memberLastNameTextField.isHidden   = false
        memberScreenNameTextField.isHidden = false
        iconColorLabel.isHidden            = false
        userColorPopUpButton.isHidden      = false
        joinSessionButton.isHidden         = false
    }
    
    private func confirmValidCode(with codeEntry: String) {
        if codeEntry.isEmpty || codeEntry.count != 6 {
            hideJoinSessionTextFields()
            present(Alerts.onlySixDigits(), animated: true)
        } else {
            joinSessionViewModel.searchFirebase(with: codeEntry)
        }
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toJoinActiveSessionVC" {
            guard let destinationVC = segue.destination as? ActiveSessionViewController,
                  let mapHomeDelegate = joinSessionViewModel.mapHomeDelegate,
                  let session = joinSessionViewModel.searchedSession else { return }
            destinationVC.activeSessionViewModel = ActiveSessionViewModel(session: session, delegate: destinationVC.self, mapHomeDelegate: mapHomeDelegate)
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
        logoImageView.isHidden = true
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
        switch textField {
        case codeEntryTextField:
            tellTheGroupLabel.isHidden = true
            guard let codeEntry = codeEntryTextField.text else { return false }
            confirmValidCode(with: codeEntry)
            memberFirstNameTextField.becomeFirstResponder()
            return true
        case memberFirstNameTextField:
            return memberLastNameTextField.becomeFirstResponder()
        case memberLastNameTextField:
            return memberScreenNameTextField.becomeFirstResponder()
        case memberScreenNameTextField:
            return textField.resignFirstResponder()
        default:
            return true
        }
    }
} //: TextFieldDelegate
