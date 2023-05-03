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
        recentDestinationsTableView.dataSource = self
        recentDestinationsTableView.delegate = self
        configureSheetPresentationController()
    }
    
    
    //MARK: - IB ACTIONS
    @IBAction func createSessionButtonTapped(_ sender: Any) {
        guard let sessionName = sessionNameTextField.text,
              let organizerName = organizerNameTextField.text else { return }
        let markerColor = "BLUE"
        
        if sessionName.isEmpty {
            presentSessionNeedsNameAlert()
        } else if organizerName.isEmpty {
            presentOrganizerNeedsNameAlert()
        } else {
            modalHomeViewModel.createNewMapShareSession(sessionName: sessionName, organizerName: organizerName, markerColor: markerColor)
            sessionNameTextField.resignFirstResponder()
            sessionNameTextField.text?.removeAll()
            organizerNameTextField.resignFirstResponder()
            organizerNameTextField.text?.removeAll()
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
    
    func presentOrganizerNeedsNameAlert() {
        let emptyOrganizerNameAlertController = UIAlertController(title: "What's Your Name?", message: "Please share your name so members will distinguish you on the map.", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Okay", style: .cancel)
        emptyOrganizerNameAlertController.addAction(dismissAction)
        present(emptyOrganizerNameAlertController, animated: true)
    }
    
    
     // MARK: - Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

     }
    
} //: CLASS


extension ModalHomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
        #warning("Update this value once the model has been incorporated")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentDestinationsCell", for: indexPath)
        
        return cell
    }
} //: TableViewDataSource and Delegate
