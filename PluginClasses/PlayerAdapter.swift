import Foundation
import ZappPlugins
import BrightcovePlayerSDK

protocol PlayerAdapter {
    var currentItem: ZPPlayable { get }
    
    func play()
    func pause()
    func stop()
}

class PlayerAdapterImp: NSObject, PlayerAdapter {
    
    let currentItem: ZPPlayable
    
    private let player: BCOVPlaybackController
    
    init(player: BCOVPlaybackController, item: ZPPlayable) {
        self.player = player
        self.currentItem = item
        
        super.init()
        
        setup()
    }

    private func setup() {
        let video: BCOVVideo = BCOVVideo(url: URL(string: currentItem.contentVideoURLPath()))
        player.setVideos([video] as NSFastEnumeration)
    }
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func stop() {
        player.pause()
        player.seek(to: kCMTimeZero, completionHandler: nil)
    }
}

extension PlayerAdapterImp: BCOVPlaybackControllerDelegate {
    func playbackController(_ controller: BCOVPlaybackController!, didAdvanceTo session: BCOVPlaybackSession!) {
       
    }
    
    func playbackController(_ controller: BCOVPlaybackController!, playbackSession session: BCOVPlaybackSession!, didReceive lifecycleEvent: BCOVPlaybackSessionLifecycleEvent!) {
        
    }
}
