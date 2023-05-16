//
//  String+Ext.swift
//  MapShare
//
//  Created by iMac Pro on 5/4/23.
//

import UIKit

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
    
    static func convertToColorFromString(string: String) -> UIColor? {
        let components = string.components(separatedBy: ",")
        guard components.count == 4,
              let red = Float(components[0]),
              let green = Float(components[1]),
              let blue = Float(components[2]),
              let alpha = Float(components[3]) else { return nil}
        
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
}
