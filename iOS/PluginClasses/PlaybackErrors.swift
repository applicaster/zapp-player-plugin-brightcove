//
//  PlaybackErrors.swift
//  BrightcovePlayerPlugin
//
//  Created by Roman Karpievich on 1/22/19.
//

import Foundation
import BrightcovePlayerSDK

enum PlaybackErrors: Int {
    case loadFailed = 69401
    case failedToPlayToEnd = 69402
    case noPlayableSource = 69403
    
    var key: String {
        return "ErrorCode"
    }
    
    var value: String {
        switch self {
        case .loadFailed:
            return "kBCOVPlaybackSessionErrorCodeLoadFailed"
        case .failedToPlayToEnd:
            return "kBCOVPlaybackSessionErrorCodeFailedToPlayToEnd"
        case .noPlayableSource:
            return "kBCOVPlaybackSessionErrorCodeNoPlayableSource"
        }
    }
}
