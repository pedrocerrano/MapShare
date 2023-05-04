//
//  ActiveSessionViewModel.swift
//  MapShare
//
//  Created by iMac Pro on 5/3/23.
//

import Foundation

struct ActiveSessionViewModel {
    
    //MARK: - PROPERTIES
    var session: Session
    var service: FirebaseService
    
    init(session: Session, service: FirebaseService = FirebaseService()) {
        self.session = session
        self.service = service
    }
    
    //MARK: - FUNCTIONS
    func loadSession() {
        
    }
    
}
