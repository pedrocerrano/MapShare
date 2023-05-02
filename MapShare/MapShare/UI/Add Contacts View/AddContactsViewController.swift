//
//  AddContactsViewController.swift
//  MapShare
//
//  Created by iMac Pro on 4/27/23.
//

import UIKit


class AddContactsViewController: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var contactsSearchBar: UISearchBar!
    @IBOutlet weak var contactListTableView: UITableView!
    
    
    //MARK: - PROPERTIES
    var addContactsViewModel: AddContactsViewModel!
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        contactListTableView.dataSource = self
        contactListTableView.delegate   = self
        contactsSearchBar.delegate      = self
        addContactsViewModel.requestAccess { accessGranted in
            #warning("Figure out how to recheck when access is denied")
        }
    }
    
    //MARK: - FUNCTIONS
    func showSettingsAlertController() {
        let showSettingsAlertController = UIAlertController(title: "MapShare requires access to Contacts to invive Members to join",
                                                            message: "Go to Settings to grant access.",
                                                            preferredStyle: .alert)
        guard let settings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settings) else { return }
        
        let dismissAction      = UIAlertAction(title: "Cancel", style: .cancel)
        let goToSettingsAction = UIAlertAction(title: "Open Settings", style: .default) { _ in
            UIApplication.shared.open(settings)
        }
        
        showSettingsAlertController.addAction(dismissAction)
        showSettingsAlertController.addAction(goToSettingsAction)
        parent?.present(showSettingsAlertController, animated: true)
    }
    
    
    
    /*
     // MARK: - NAVIGATION
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
     }
     */
    
} //: CLASS


//MARK: - EXT: TableViewDataSource and TableViewDelegate
extension AddContactsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addContactsViewModel.session.members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as? AddContactsTableViewCell else { return UITableViewCell() }
        
        
        let contact = addContactsViewModel.session.members[indexPath.row]
        cell.configureCell(withContact: contact)
        
        return cell
    }
} //: EXT TableView


//MARK: - EXT: SearchBar
extension AddContactsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
} //: EXT SearchBar


//MARK: - EXT: AddContactsViewModelDelegate
extension AddContactsViewController: AddContactsViewModelDelegate {
    func accessToContactsDenied() {
        showSettingsAlertController()
    }
} //: EXT ViewModelDelegate
