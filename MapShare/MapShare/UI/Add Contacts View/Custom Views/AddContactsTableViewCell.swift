//
//  AddContactsTableViewCell.swift
//  MapShare
//
//  Created by iMac Pro on 5/1/23.
//

import UIKit

class AddContactsTableViewCell: UITableViewCell {

    //MARK: - OUTLETS
    @IBOutlet weak var contactNameLabel: UILabel!
    
    
    //MARK: - FUNCTIONS
    func configureCell(withContact contact: Member) {
        contactNameLabel.text = "\(contact.firstName) \(contact.lastName)"
    }

}
