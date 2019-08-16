//
//  PlayerViewBuilder.swift
//  BrightcovePlayerTVOS
//
//  Created by Egor Brel on 8/15/19.
//

import Foundation
import BrightcovePlayerSDK
import ZappPlugins

protocol PlayerViewBuilderProtocol {
    var mode: PlayerScreenMode { get set }
    var playerViewController: PlayerViewController! { get set }
    
    func buildPlayerView() -> BCOVTVPlayerView
}

class PlayerViewBuilder: PlayerViewBuilderProtocol {
    
    var mode: PlayerScreenMode = .fullscreen
    
    weak var playerViewController: PlayerViewController!

    func buildPlayerView() -> BCOVTVPlayerView {
        let options = BCOVTVPlayerViewOptions()
        guard let playerView = BCOVTVPlayerView(options: options) else {
            return BCOVTVPlayerView()
        }
        return playerView
    }
}
