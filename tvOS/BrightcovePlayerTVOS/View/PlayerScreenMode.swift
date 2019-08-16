//
//  PlayerScreenMode.swift
//  BrightcovePlayerTVOS
//
//  Created by Egor Brel on 8/15/19.
//

import Foundation

enum PlayerScreenMode: String, Equatable {
    case inline = "Inline Player"
    case fullscreen = "Full Screen Player"
    
    var key: String {
        return "View"
    }
}

