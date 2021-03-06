//
//  PlayerAdapter.swift
//  DefaultPlayer
//
//  Created by Anton Kononenko on 12/2/18.
//  Copyright © 2018 Applicaster. All rights reserved.
//

import Foundation
import BrightcovePlayerSDK

protocol PlayerAdapterProtocol: AnyObject {
    func setVideoItem(item: VideoItem)
    func setupPlayer(atContainer playerViewController: PlayerViewController)
    func play()
    func pause()
    func resume()
    var playbackEventsDelegate: PlaybackEventsDelegate? { get set }
}

class PlayerAdapter: NSObject, PlayerAdapterProtocol, BCOVPlaybackControllerDelegate {
    
    weak var playbackEventsDelegate: PlaybackEventsDelegate?
    var player: BCOVPlaybackController!
    var currentVideoItem: VideoItem?
    
    private var videos: [BCOVVideo] = [] {
        didSet { player.setVideos(videos as NSFastEnumeration) }
    }
    
    override init() {
        super.init()
    }
    
    func setupPlayer(atContainer playerViewController: PlayerViewController) {
        self.player = BCOVPlayerSDKManager.shared().createPlaybackController()
        playerViewController.playerView.playbackController = self.player
        
        self.player.delegate = self
        self.player.isAutoPlay = true
        self.player.isAutoAdvance = true
    }
    
    func play() {
        loadItems()
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func resume() {
        player.play()
    }
    
    func loadItems() {
        playbackEventsDelegate?.videoItemsLoadStarted()
        guard let item = self.currentVideoItem else {
            return
        }
        let video: BCOVVideo = BCOVVideo(url: URL(string: item.urlString), deliveryMethod: item.delivery)
                                         
        self.videos = [video]
    }
    
    func setVideoItem(item: VideoItem) {
        currentVideoItem = item
    }
    
    func playbackController(_ controller: BCOVPlaybackController!,
                            playbackSession session: BCOVPlaybackSession!,
                            didReceive lifecycleEvent: BCOVPlaybackSessionLifecycleEvent!) {
        playbackEventsDelegate?.videoEventOccured(lifecycleEvent, duringSession: session)
    }
    
    func playbackController(_ controller: BCOVPlaybackController!, didCompletePlaylist playlist: NSFastEnumeration!) {
        playbackEventsDelegate?.didEndPlayback()
    }
}
