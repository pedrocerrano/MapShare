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
        print("This prints")
        sheetPresentationController.animateChanges {
            sheetPresentationController.dismissalTransitionWillBegin()
        }
        guard let activeSessionViewModel else { return }
        #warning("The line above will need to be deleted to get the following code to work, once the segue passes data throughout the app")
        if activeSessionViewModel.session.members[0].isOrganizer == true {
            organizerEndedActiveSessionAlert()
        } else {
            memberExitsActiveSessionAlert()
        }
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
    
    
    //MARK: - ALERTS
    func organizerEndedActiveSessionAlert() {
        let organizerEndedActiveSessionAlertController = UIAlertController(title: "End Session?", message: "Press 'Confirm' to end MapShare for all members.", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { alert in
            #warning("Add Firestore delete session and trigger navigation to dismiss modal")
        }
        organizerEndedActiveSessionAlertController.addAction(dismissAction)
        organizerEndedActiveSessionAlertController.addAction(confirmAction)
        present(organizerEndedActiveSessionAlertController, animated: true)
    }
    
    
    func memberExitsActiveSessionAlert() {
        let memberExitsActiveSessionAlertController = UIAlertController(title: "Exit Session?", message: "Press 'Confirm' to exit MapShare.", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { alert in
            #warning("Add Firestore delete member from session and trigger all views to refresh/reload")
        }
        memberExitsActiveSessionAlertController.addAction(dismissAction)
        memberExitsActiveSessionAlertController.addAction(confirmAction)
        present(memberExitsActiveSessionAlertController, animated: true)
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
