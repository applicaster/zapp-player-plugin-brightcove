//
//  ViewControllerFactory.swift
//  BrightcovePlayerPlugin
//
//  Created by Roman Karpievich on 1/23/19.
//

import Foundation
import ZappPlugins

class ViewControllerFactory {
    open static func createPlayerViewController(videoItems: [ZPPlayable]) -> PlayerViewController {
        let builder = PlayerViewBuilder()
        let player = PlayerAdapter(items: videoItems)
        let playerViewController = PlayerViewController(builder: builder,
                                                        player: player)
        builder.playerViewController = playerViewController
        
        return playerViewController
    }
}
