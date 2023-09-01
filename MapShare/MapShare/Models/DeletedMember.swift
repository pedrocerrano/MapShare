//
//  DeletedMember.swift
//  MapShare
//
//  Created by iMac Pro on 9/1/23.
//

import Foundation

class DeletedMember {
    
    enum DeletedMemberKey {
        static let title = "title"
    }
    
    var title: String
    
    var deletedMemberDictionaryRepresentation: [String : AnyHashable] {
        [
            DeletedMemberKey.title : self.title
        ]
    }
    
    init(title: String) {
        self.title = title
    }
}


//MARK: - Convenience Initializer
extension DeletedMember {
    convenience init?(fromDeletedMemberDictionary deletedMemberDictionary: [String : Any]) {
        guard let title = deletedMemberDictionary[DeletedMemberKey.title] as? String
        else { return nil }
        
        self.init(title: title)
    }
}
