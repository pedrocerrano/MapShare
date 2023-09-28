//
//  Member+UIColor.swift
//  MapShare
//
//  Created by iMac Pro on 8/30/23.
//

import UIKit

extension Member {
    
    static func convertColorToString(_ buttonColor: UIColor) -> String {
        let red   = String(format: "%.5f", buttonColor.cgColor.components?[0] ?? 0.0)
        let green = String(format: "%.5f", buttonColor.cgColor.components?[1] ?? 0.0)
        let blue  = String(format: "%.5f", buttonColor.cgColor.components?[2] ?? 0.0)
        let alpha = String(format: "%.5f", buttonColor.cgColor.alpha)
        
        return "\(red),\(green),\(blue),\(alpha)"
    }
    
    static func convertToColorFromString(string: String) -> UIColor? {
        let components = string.components(separatedBy: ",")
        guard components.count == 4,
              let red   = Float(components[0]),
              let green = Float(components[1]),
              let blue  = Float(components[2]),
              let alpha = Float(components[3])
        else { return nil}
        
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
}
