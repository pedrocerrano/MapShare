//
//  ModalHomeViewController.swift
//  MapShare
//
//  Created by iMac Pro on 4/27/23.
//

import UIKit

class ModalHomeViewController: UIViewController {

    //MARK: - PROPERTIES
    override var sheetPresentationController: UISheetPresentationController {
        presentationController as! UISheetPresentationController
    }
    
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSheetPresentationController()
    }
    
    
    //MARK: - FUNCTIONS
    func configureSheetPresentationController() {
        let screenHeight = view.frame.height
        
        let bottomDetent = UISheetPresentationController.Detent.custom { context in
            screenHeight * Constants.Detents.bottomDetentMultipler
        }
        
        let middleDetent = UISheetPresentationController.Detent.custom { context in
            screenHeight * Constants.Detents.middleDetentMultiplier
        }
        
        let topDetent = UISheetPresentationController.Detent.custom { context in
            screenHeight * Constants.Detents.topDetentMultiplier
        }
        
        sheetPresentationController.detents = [bottomDetent, middleDetent, topDetent]
        sheetPresentationController.prefersGrabberVisible = true
        sheetPresentationController.largestUndimmedDetentIdentifier = topDetent.identifier
    }
    

    /*
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    */

} //: CLASS
