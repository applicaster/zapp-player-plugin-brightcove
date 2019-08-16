//
//  PlayerViewController.swift
//  BrightcovePlayerTVOS
//
//  Created by Egor Brel on 8/15/19.
//

import UIKit
import BrightcovePlayerSDK

class PlayerViewController: UIViewController {

    weak var eventsResponderDelegate: PlayerEventsResponder?
    let builder: PlayerViewBuilderProtocol
    let player: PlayerAdapterProtocol
    
    lazy var playerView: BCOVTVPlayerView = {
        self.builder.buildPlayerView()
    }()
    
    var videoSourceDictionary: NSDictionary? {
        didSet {
            if let source = self.videoSourceDictionary {
                player.setVideoItem(item: VideoItem(source: source))
            }
        }
    }
    
    required init(builder: PlayerViewBuilderProtocol, player: PlayerAdapterProtocol) {
        self.builder = builder
        self.player = player
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayerView()
        setupPlayer()
    }

    private func setupPlayerView() {
        view.addSubview(playerView)
        
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        playerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        playerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    open func setupPlayer() {
        player.setupPlayer(atContainer: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        eventsResponderDelegate?.eventOccured(event: .onVideoFullscreenPlayerWillPresent)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.resume()
        eventsResponderDelegate?.eventOccured(event: .onVideoFullscreenPlayerDidPresent)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        eventsResponderDelegate?.eventOccured(event: .onVideoFullscreenPlayerDidDismiss)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.pause()
        eventsResponderDelegate?.eventOccured(event: .onVideoFullscreenPlayerWillDismiss)
    }
}
