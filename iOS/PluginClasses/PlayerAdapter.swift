import Foundation
import ZappPlugins
import BrightcovePlayerSDK

protocol PlayerAdapter: class {    
    var currentItem: ZPPlayable { get }
    var player: BCOVPlaybackController { get }
    
    var playerState: ZPPlayerState { get }
    
    var currentProgress: TimeInterval { get }
    var currentDuration: TimeInterval { get }
    
    var didEndPlayback: (() -> Void)? { get set }
    
    func play()
    func pause()
    func stop()
}

class PlayerAdapterImp: NSObject, PlayerAdapter {
    
    let currentItem: ZPPlayable
    let player: BCOVPlaybackController
    
    private(set) var playerState: ZPPlayerState = .undefined
    
    private(set) var currentProgress: TimeInterval = .infinity
    private(set) var currentDuration: TimeInterval = .infinity
    
    var didEndPlayback: (() -> Void)?
    
    init(player: BCOVPlaybackController, item: ZPPlayable) {
        self.player = player
        self.currentItem = item
        
        super.init()
        
        setup()
    }
    
    func setup() {
        player.delegate = self
        player.isAutoAdvance = true
        
        let delivery: String = currentItem.isLive() ? kBCOVSourceDeliveryHLS : kBCOVSourceDeliveryMP4
        let video: BCOVVideo = BCOVVideo(url: URL(string: currentItem.contentVideoURLPath()), deliveryMethod: delivery)
        self.player.setVideos([video] as NSFastEnumeration)
    }
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func stop() {
        player.pause()
        player.seekWithoutAds(kCMTimeZero) { [weak self] _ in self?.playerState = .stopped }
    }
}

extension PlayerAdapterImp: BCOVPlaybackControllerDelegate {
    @objc func playbackController(_ controller: BCOVPlaybackController!, didAdvanceTo session: BCOVPlaybackSession!) {
        print("ViewController Debug - Advanced to new session.")
    }
    
    func playbackController(_ controller: BCOVPlaybackController!,
                            playbackSession session: BCOVPlaybackSession!,
                            didChangeDuration duration: TimeInterval) {
        currentDuration = duration
    }
    
    func playbackController(_ controller: BCOVPlaybackController!,
                            playbackSession session: BCOVPlaybackSession!,
                            didProgressTo progress: TimeInterval) {
        currentProgress = progress
    }
    
    func playbackController(_ controller: BCOVPlaybackController!,
                            playbackSession session: BCOVPlaybackSession!,
                            didReceive lifecycleEvent: BCOVPlaybackSessionLifecycleEvent!) {
        ZPPlayerState(event: lifecycleEvent).flatMap { playerState = $0 }
    }
    
    func playbackController(_ controller: BCOVPlaybackController!, didCompletePlaylist playlist: NSFastEnumeration!) {
        didEndPlayback?()
    }
}

extension ZPPlayerState {
    init?(event: BCOVPlaybackSessionLifecycleEvent) {
        switch event.eventType {
            
        case kBCOVPlaybackSessionLifecycleEventPlaybackStalled,
             kBCOVPlaybackSessionLifecycleEventResumeFail,
             kBCOVPlaybackSessionLifecycleEventFail,
             kBCOVPlaybackSessionLifecycleEventFailedToPlayToEndTime:
            self = .interruption
            
        case kBCOVPlaybackSessionLifecycleEventPause:
            self = .paused
            
        case kBCOVPlaybackSessionLifecycleEventPlaybackRecovered,
             kBCOVPlaybackSessionLifecycleEventPlay:
            self = .playing
            
        case kBCOVPlaybackSessionLifecycleEventEnd:
            self = .stopped
            
        case kBCOVPlaybackSessionLifecycleEventPlaybackBufferEmpty,
             kBCOVPlaybackSessionLifecycleEventResumeBegin,
             kBCOVPlaybackSessionLifecycleEventResumeComplete,
             kBCOVPlaybackSessionLifecycleEventReady,
             kBCOVPlaybackSessionLifecycleEventPlaybackLikelyToKeepUp:
            fallthrough
            
        default:
            return nil
        }
    }
}
