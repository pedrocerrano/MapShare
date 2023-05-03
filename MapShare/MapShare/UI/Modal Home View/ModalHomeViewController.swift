//
//  ModalHomeViewController.swift
//  MapShare
//
//  Created by iMac Pro on 4/27/23.
//

import UIKit

class ModalHomeViewController: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var sessionNameTextField: UITextField!
    @IBOutlet weak var organizerNameTextField: UITextField!
    @IBOutlet weak var iconColorButton: UIButton!
    @IBOutlet weak var createSessionButton: UIButton!
    @IBOutlet weak var recentDestinationsTableView: UITableView!
    
    
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
    @IBAction func createSessionButtonTapped(_ sender: Any) {
        
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
    
    
     // MARK: - Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

     }
    
} //: CLASS


extension ModalHomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3 #warning("Update this value once the model has been incorporated")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
} 
