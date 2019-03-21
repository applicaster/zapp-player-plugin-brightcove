//
//  ViewControllerFactory.swift
//  BrightcovePlayerPlugin
//
//  Created by Roman Karpievich on 1/23/19.
//

import Foundation
import ZappPlugins

class ViewControllerFactory {
    public static func createPlayerViewController(videoItems: [ZPPlayable],
                                                errorViewConfig: ErrorViewConfiguration?) -> PlayerViewController {
        let builder = PlayerViewBuilder()
        builder.errorViewConfiguration = errorViewConfig
        let player = PlayerAdapter(items: videoItems)
        let playerViewController = PlayerViewController(builder: builder,
                                                        player: player)
        builder.playerViewController = playerViewController
        
        return playerViewController
    }
}
