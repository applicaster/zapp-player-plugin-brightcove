//
//  String+Extensions.swift
//  BrightcovePlayerPlugin
//
//  Created by Roman Karpievich on 3/15/19.
//

import Foundation

extension String {
    public static func create(fromInterval interval: TimeInterval) -> String {
        guard interval.isNormal == true else {
            return ""
        }
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        
        return formatter.string(from: interval) ?? ""
    }
}
