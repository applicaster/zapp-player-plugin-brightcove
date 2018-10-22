//
//  PlayerViewController.swift
//  BrightcovePlayer
//
//  Created by Alex Faizullov on 10/22/18.
//  Copyright © 2018 Alex Faizullov. All rights reserved.
//

import Foundation
import BrightcovePlayerSDK

class PlayerViewController: UIViewController {
    
    private let playerController: BCOVPlaybackController
    
    required init(playerController: BCOVPlaybackController) {
        self.playerController = playerController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let controlView = BCOVPUIBasicControlView.withVODLayout()
        let playerView: BCOVPUIPlayerView = BCOVPUIPlayerView(playbackController: playerController, options: nil, controlsView: controlView)
        
        view.addSubview(playerView)
        
        playerView.translatesAutoresizingMaskIntoConstraints = false
    
        playerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        playerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        playerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}
