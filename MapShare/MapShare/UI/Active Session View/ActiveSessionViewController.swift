//
//  ActiveSessionViewController.swift
//  MapShare
//
//  Created by iMac Pro on 5/3/23.
//

import UIKit

class ActiveSessionViewController: UIViewController {

    //MARK: - OUTLETS
    @IBOutlet weak var sessionNameLabel: UILabel!
    @IBOutlet weak var sessionCodeLabel: UILabel!
    @IBOutlet weak var sessionControlButton: UIButton!
    @IBOutlet weak var activeSessionTableView: UITableView!
    
    
    //MARK: - PROPERTIES
    override var sheetPresentationController: UISheetPresentationController {
        presentationController as! UISheetPresentationController
    }
    
    var activeSessionViewModel: ActiveSessionViewModel!
    
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        activeSessionTableView.dataSource = self
        activeSessionTableView.delegate = self
        configureSheetPresentationController()
        sheetPresentationController.animateChanges {
            sheetPresentationController.selectedDetentIdentifier = sheetPresentationController.detents[1].identifier
        }
        configureUI()
    }
    
    
    //MARK: - IB ACTIONS
    @IBAction func sessionControlButtonTapped(_ sender: Any) {
        #warning("if isOrganizer == true, delete the entire active session and dismiss view")
        #warning("if isOrganizer == false, delete one member from the session and reload the tableview")
    }
    
    
    //MARK: - FUNCTIONS
    func configureUI() {
        sessionControlButton.layer.cornerRadius = sessionControlButton.frame.height / 2
    }
    
    
    func configureSheetPresentationController() {
        let screenHeight = view.frame.height
        sheetPresentationController.detents = Detents.buildDetent(screenHeight: screenHeight)
        sheetPresentationController.prefersGrabberVisible = true
        sheetPresentationController.largestUndimmedDetentIdentifier = sheetPresentationController.detents[2].identifier
    }
    

    /*
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    */

} //: CLASS


//MARK: - EXT: TableViewDataSource and Delegate
extension ActiveSessionViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
        #warning("Update this value once the model has been incorporated")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath) as? ActiveSessionTableViewCell else { return UITableViewCell() }
        
        
        return cell
    }
    
} //: TableView
