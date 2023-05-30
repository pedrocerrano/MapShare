//
//  Double+Ext.swift
//  MapShare
//
//  Created by iMac Pro on 5/28/23.
//

import Foundation

extension Double {
    func asHoursAndMinsString(style: DateComponentsFormatter.UnitsStyle) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = style
        return formatter.string(from: self) ?? "Formatter Failure"
    }
}
