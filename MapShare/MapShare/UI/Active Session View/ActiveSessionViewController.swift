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
    var activeSessionViewModel: ActiveSessionViewModel!
    
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
//        activeSessionViewModel = ActiveSessionViewModel()
        activeSessionTableView.dataSource = self
        activeSessionTableView.delegate = self
    }
    
    
    //MARK: - IB ACTIONS
    @IBAction func sessionControlButtonTapped(_ sender: Any) {
        
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
