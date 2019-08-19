//
//  ViewControllerFactory.swift
//  BrightcovePlayerPlugin
//
//  Created by Roman Karpievich on 1/23/19.
//

import Foundation
import ZappPlugins

class ViewControllerFactory {
    public static func createPlayerViewController() -> PlayerViewController {
        let builder = PlayerViewBuilder()
        let player = PlayerAdapter()
        let playerViewController = PlayerViewController(builder: builder,
                                                        player: player)
        builder.playerViewController = playerViewController
        
        return playerViewController
    }
}
