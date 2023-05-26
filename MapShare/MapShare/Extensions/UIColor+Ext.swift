//
//  UIColor+Ext.swift
//  MapShare
//
//  Created by Chase on 5/15/23.
//

import UIKit

extension UIColor {
    
    func convertColorToString() -> String {
        let red   = String(format: "%.5f", self.cgColor.components?[0] ?? 0.0)
        let green = String(format: "%.5f", self.cgColor.components?[1] ?? 0.0)
        let blue  = String(format: "%.5f", self.cgColor.components?[2] ?? 0.0)
        let alpha = String(format: "%.5f", self.cgColor.alpha)
        
        return "\(red),\(green),\(blue),\(alpha)"
    }
}
