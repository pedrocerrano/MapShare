//
//  ModalHomeViewController.swift
//  MapShare
//
//  Created by iMac Pro on 4/27/23.
//

import UIKit

class ModalHomeViewController: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var newMSButton: UIButton!
    @IBOutlet weak var xMarkButton: UIButton!
    
    
    //MARK: - PROPERTIES
    override var sheetPresentationController: UISheetPresentationController {
        presentationController as! UISheetPresentationController
    }

    var modalHomeViewModel: ModalHomeViewModel!
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        modalHomeViewModel = ModalHomeViewModel()
        configureSheetPresentationController()
    }
    
    
    //MARK: - IB ACTIONS
    @IBAction func newMSButtonTapped(_ sender: Any) {
        sheetPresentationController.animateChanges {
            sheetPresentationController.selectedDetentIdentifier = sheetPresentationController.detents[2].identifier
        }
    }
    
    @IBAction func xMarkButtonTapped(_ sender: Any) {
        sheetPresentationController.animateChanges {
            sheetPresentationController.selectedDetentIdentifier = sheetPresentationController.detents[0].identifier
        }
    }
    
    @IBAction func addContactsButtonTapped(_ sender: Any) {
        modalHomeViewModel.createNewMapShareSession()
    }
    
    
    //MARK: - FUNCTIONS
    func configureSheetPresentationController() {
        let screenHeight = view.frame.height
        sheetPresentationController.detents = Constants.Detents.buildDetent(screenHeight: screenHeight)
        sheetPresentationController.prefersGrabberVisible = true
        sheetPresentationController.largestUndimmedDetentIdentifier = sheetPresentationController.detents[2].identifier
    }
    
    
     // MARK: - Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "toAddContactsVC" {
             guard let destinationVC = segue.destination as? AddContactsViewController,
                   let session = modalHomeViewModel.session else { return }
             destinationVC.addContactsViewModel = AddContactsViewModel(session: session, delegate: destinationVC.self)
         }
     }
    
} //: CLASS
