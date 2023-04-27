//
//  ModalHomeViewController.swift
//  MapShare
//
//  Created by iMac Pro on 4/27/23.
//

import UIKit

class ModalHomeViewController: UIViewController {
    
    //MARK: - OUTLETS
    
    
    //MARK: - PROPERTIES
    override var sheetPresentationController: UISheetPresentationController {
        presentationController as! UISheetPresentationController
    }
    
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    
    
    //MARK: - FUNCTIONS
    func configureSheetPresentationController() {
        let screenHeight = view.frame.height
        sheetPresentationController.detents = Constants.Detents.buildDetent(screenHeight: screenHeight)
        sheetPresentationController.prefersGrabberVisible = true
        sheetPresentationController.largestUndimmedDetentIdentifier = sheetPresentationController.detents[2].identifier
    }
    
    
    //    func buildDetent(screenHeight: CGFloat) -> [UISheetPresentationController.Detent] {
    //        let bottomDetent = UISheetPresentationController.Detent.custom { context in
    //            screenHeight * Constants.Detents.bottomDetentMultipler
    //        }
    //
    //        let middleDetent = UISheetPresentationController.Detent.custom { context in
    //            screenHeight * Constants.Detents.middleDetentMultiplier
    //        }
    //
    //        let topDetent = UISheetPresentationController.Detent.custom { context in
    //            screenHeight * Constants.Detents.topDetentMultiplier
    //        }
    //
    //        return [bottomDetent, middleDetent, topDetent]
    //    }
    
    /*
     // MARK: - Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
     }
     */
    
} //: CLASS
