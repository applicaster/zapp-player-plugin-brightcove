//
//  PlayerViewController.swift
//  BrightcovePlayerTVOS
//
//  Created by Egor Brel on 8/15/19.
//

import UIKit
import BrightcovePlayerSDK

protocol PlaybackEventsDelegate: AnyObject {
    func videoEventOccured(_ event: BCOVPlaybackSessionLifecycleEvent,
                      duringSession session: BCOVPlaybackSession)
    func didEndPlayback()
    func videoItemsLoadStarted()
}

class PlayerViewController: UIViewController, PlaybackEventsDelegate {

    weak var eventsResponderDelegate: PlayerEventsResponder?
    let loadIndicator = UIActivityIndicatorView()
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
        setupLoadIndicator()
    }

    private func setupPlayerView() {
        view.addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        playerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        playerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func setupLoadIndicator() {
        view.addSubview(loadIndicator)
        loadIndicator.color = .white
        loadIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadIndicator.widthAnchor.constraint(equalToConstant: 30).isActive = true
        loadIndicator.heightAnchor.constraint(equalToConstant: 30).isActive = true
        loadIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        loadIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    open func setupPlayer() {
        player.playbackEventsDelegate = self
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
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if(presses.first?.type == UIPress.PressType.menu) {
            eventsResponderDelegate?.eventOccured(event: .onVideoEnd)
        } else {
            super.pressesBegan(presses, with: event)
        }
    }
    
    func showLoadIndicator() {
        loadIndicator.startAnimating()
        loadIndicator.isHidden = false
    }
    
    func hideLoadIndicator() {
        loadIndicator.stopAnimating()
        loadIndicator.isHidden = true
    }
    
    func videoEventOccured(_ event: BCOVPlaybackSessionLifecycleEvent, duringSession session: BCOVPlaybackSession) {
        switch event.eventType {
        case kBCOVPlaybackSessionLifecycleEventReady:
            hideLoadIndicator()
            eventsResponderDelegate?.eventOccured(event: .onVideoLoad)
        case kBCOVPlaybackSessionLifecycleEventFail,
             kBCOVPlaybackSessionLifecycleEventResumeFail,
             kBCOVPlaybackSessionLifecycleEventPlaybackStalled:
            hideLoadIndicator()
            var errorDictionary = [String: String]()
            if let error = event.properties[kBCOVPlaybackSessionEventKeyError] as? NSError {
                errorDictionary["localizedDescription"] = error.localizedDescription
            }
            eventsResponderDelegate?.eventOccured(event: .onVideoError, infoDictionary: errorDictionary)
            eventsResponderDelegate?.eventOccured(event: .onVideoEnd)
        default:
            break
        }
    }
    
    func didEndPlayback() {
        eventsResponderDelegate?.eventOccured(event: .onVideoEnd)
    }
    
    func videoItemsLoadStarted() {
        showLoadIndicator()
        eventsResponderDelegate?.eventOccured(event: .onVideoLoadStart)
    }
}
