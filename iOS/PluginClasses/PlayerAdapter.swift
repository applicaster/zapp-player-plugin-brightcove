import Foundation
import ZappPlugins
import BrightcovePlayerSDK

protocol PlayerAdapter: class {    
    var currentItem: ZPPlayable { get }
    var player: BCOVPlaybackController { get }
    
    var didEndPlayback: (() -> Void)? { get set }
    
    func play()
    func pause()
    func stop()
}

class PlayerAdapterImp: NSObject, PlayerAdapter {
    
    let currentItem: ZPPlayable
    let player: BCOVPlaybackController
    
    var didEndPlayback: (() -> Void)?
    
    init(player: BCOVPlaybackController, item: ZPPlayable) {
        self.player = player
        self.currentItem = item
        
        super.init()
        
        setup()
    }
    
    func setup() {
        player.delegate = self
    }
    
    func play() {
        let delivery: String = currentItem.isLive() ? kBCOVSourceDeliveryHLS : kBCOVSourceDeliveryMP4
        let video: BCOVVideo = BCOVVideo(url: URL(string: currentItem.contentVideoURLPath()), deliveryMethod: delivery)
        self.player.setVideos([video] as NSFastEnumeration)
        
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func stop() {
        player.pause()
        player.seekWithoutAds(kCMTimeZero, completionHandler: nil)
    }
}

extension PlayerAdapterImp: BCOVPlaybackControllerDelegate {
    @objc func playbackController(_ controller: BCOVPlaybackController!, didAdvanceTo session: BCOVPlaybackSession!) {
        print("ViewController Debug - Advanced to new session.")
    }
    
    @objc func playbackController(_ controller: BCOVPlaybackController!, playbackSession session: BCOVPlaybackSession!, didProgressTo progress: TimeInterval) {
        print(progress)
    }
    
    func playbackController(_ controller: BCOVPlaybackController!, playbackSession session: BCOVPlaybackSession!, didReceive lifecycleEvent: BCOVPlaybackSessionLifecycleEvent!) {
        
        let event: BCOVPlaybackSessionLifecycleEvent = lifecycleEvent
        
        switch event.eventType {
        case kBCOVPlaybackSessionLifecycleEventEnd:
            didEndPlayback?()

        default:
            break
        }
    }
}
