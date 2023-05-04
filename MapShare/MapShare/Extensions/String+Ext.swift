//
//  String+Ext.swift
//  MapShare
//
//  Created by iMac Pro on 5/4/23.
//

import Foundation

extension String {
    static func generateRandomCode() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        var randomString = ""
        
        for _ in 0..<6 {
            let randomIndex = Int(arc4random_uniform(UInt32(characters.count)))
            let character = characters[characters.index(characters.startIndex, offsetBy: randomIndex)]
            randomString += String(character)
        }
        
        return randomString
    }
}
