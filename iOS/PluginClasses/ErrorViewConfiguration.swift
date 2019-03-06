//
//  ErrorViewConfiguration.swift
//  BrightcovePlayerPlugin
//
//  Created by Roman Karpievich on 1/29/19.
//

import Foundation

private enum CustomConfiguration: String {
    case videoPlayErrorMessage = "General_Error_Message"
    case videoPlayErrorButtonText = "General_Error_Button"
    case connectivityErrorMessage = "Connectivity_Error_Message"
    case connectivityErrorButtonText = "Connectivity_Error_Button"
    
}

class ErrorViewConfiguration {
    let videoPlayErrorMessage: String
    let videoPlayErrorButtonText: String
    let connectivityErrorMessage: String
    let connectivityErrorButtonText: String
    
    init(fromDictionary dict: NSDictionary) {
        videoPlayErrorMessage = dict[CustomConfiguration.videoPlayErrorMessage.rawValue] as? String ?? ""
        videoPlayErrorButtonText = dict[CustomConfiguration.videoPlayErrorButtonText.rawValue] as? String ?? ""
        connectivityErrorMessage = dict[CustomConfiguration.connectivityErrorMessage.rawValue] as? String ?? ""
        connectivityErrorButtonText = dict[CustomConfiguration.connectivityErrorButtonText.rawValue] as? String ?? ""
    }
}
