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
        videoPlayErrorMessage = dict[CustomConfiguration.videoPlayErrorMessage] as? String ?? ""
        videoPlayErrorButtonText = dict[CustomConfiguration.videoPlayErrorButtonText] as? String ?? ""
        connectivityErrorMessage = dict[CustomConfiguration.connectivityErrorMessage] as? String ?? ""
        connectivityErrorButtonText = dict[CustomConfiguration.connectivityErrorButtonText] as? String ?? ""
    }
}
