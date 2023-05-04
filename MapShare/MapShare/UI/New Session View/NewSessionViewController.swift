//
//  NewSessionViewController.swift
//  MapShare
//
//  Created by iMac Pro on 4/27/23.
//

import UIKit

class NewSessionViewController: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var sessionNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var screenNameTextField: UITextField!
    @IBOutlet weak var iconColorButton: UIButton!
    @IBOutlet weak var createSessionButton: UIButton!
    
    
    //MARK: - PROPERTIES
    override var sheetPresentationController: UISheetPresentationController {
        presentationController as! UISheetPresentationController
    }

    var newSessionViewModel: NewSessionViewModel!
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        newSessionViewModel = NewSessionViewModel()
        configureSheetPresentationController()
    }
    
    
    //MARK: - IB ACTIONS
    @IBAction func createSessionButtonTapped(_ sender: Any) {
        guard let sessionName = sessionNameTextField.text,
              let firstName = firstNameTextField.text,
              let lastName = lastNameTextField.text,
              let screenName = screenNameTextField.text else { return }
        let markerColor = "BLUE"
        let highlandVillageLat: Double = 33.08484
        let highlandVillageLon: Double = -97.05305
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
        } else {
            newSessionViewModel.createNewMapShareSession(sessionName: sessionName, firstName: firstName, lastName: lastName, screenName: optionalScreenName, markerColor: markerColor, organizerLatitude: highlandVillageLat, organizerLongitude: highlandVillageLon)
            sessionNameTextField.resignFirstResponder()
            sessionNameTextField.text?.removeAll()
            firstNameTextField.resignFirstResponder()
            firstNameTextField.text?.removeAll()
            lastNameTextField.resignFirstResponder()
            lastNameTextField.text?.removeAll()
            screenNameTextField.resignFirstResponder()
            screenNameTextField.text?.removeAll()
        }
    }
    
    @IBAction func searchDestinationsButtonTapped(_ sender: Any) {
        
    }
    
    
    //MARK: - FUNCTIONS
    func configureSheetPresentationController() {
        let screenHeight = view.frame.height
        sheetPresentationController.detents = Constants.Detents.buildDetent(screenHeight: screenHeight)
        sheetPresentationController.prefersGrabberVisible = true
        sheetPresentationController.largestUndimmedDetentIdentifier = sheetPresentationController.detents[2].identifier
    }
    
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
    
    
     // MARK: - Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

     }
    
} //: CLASS

