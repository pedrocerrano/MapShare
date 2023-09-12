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
    
    //MARK: - Outlets
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
    
    
    //MARK: - Properties
    override var sheetPresentationController: UISheetPresentationController {
        presentationController as! UISheetPresentationController
    }
    
    var joinSessionViewModel: JoinSessionViewModel!
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        codeEntryTextField.delegate = self
        configureSheetPresentationController()
        sheetPresentationController.animateChanges {
            sheetPresentationController.selectedDetentIdentifier = sheetPresentationController.detents[2].identifier
        }
        hideJoinSessionTextFields(true)
        configureUI()
    }
    
    //MARK: - IB Actions
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
            present(AlertControllers.needFirstName(), animated: true)
        } else if lastName.isEmpty {
            present(AlertControllers.needLastName(), animated: true)
        } else if userColorPopUpButton.titleLabel?.text == "↓" {
            present(AlertControllers.needColorChoice(), animated: true)
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
            userColorPopUpButton.backgroundColor = UIColor.dodgerBlue()
            logoImageView.isHidden = false
        }
    }
    
    
    //MARK: - Functions
    private func configureSheetPresentationController() {
        let screenHeight = view.frame.height
        sheetPresentationController.detents = Detents.buildDetent(screenHeight: screenHeight)
        sheetPresentationController.prefersGrabberVisible = true
        sheetPresentationController.largestUndimmedDetentIdentifier = sheetPresentationController.detents[2].identifier
        sheetPresentationController.presentedViewController.isModalInPresentation = true
    }
    
    private func configureUI() {
        UIStyling.styleCircleButton(for: closeJoinSessionSheetButton, backgroundColor: UIColor.dodgerBlue(), tintColor: .white)
        UIStyling.styleFilledButton(for: searchSessionButton, withColor: UIColor.dodgerBlue())
        UIStyling.styleFilledButton(for: joinSessionButton, withColor: UIColor.dodgerBlue())
        UIStyling.styleLogo(forImageView: logoImageView)
        logoImageView.isHidden = false
        [codeEntryTextField, memberFirstNameTextField, memberLastNameTextField, memberScreenNameTextField].forEach { textField in
            if let textField { UIStyling.styleTextField(forTextField: textField) }
        }
        PopUpButton.setUpPopUpButton(for: userColorPopUpButton, withState: .on)
        UIStyling.stylePopUpButton(for: userColorPopUpButton)
    }
    
    private func hideJoinSessionTextFields(_ bool: Bool) {
        tellTheGroupLabel.isHidden         = bool
        memberFirstNameTextField.isHidden  = bool
        memberLastNameTextField.isHidden   = bool
        memberScreenNameTextField.isHidden = bool
        iconColorLabel.isHidden            = bool
        userColorPopUpButton.isHidden      = bool
        joinSessionButton.isHidden         = bool
    }
    
    private func confirmValidCode(with codeEntry: String) {
        if codeEntry.isEmpty || codeEntry.count != 6 {
            hideJoinSessionTextFields(true)
            present(AlertControllers.onlySixDigits(), animated: true)
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
        hideJoinSessionTextFields(false)
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
