import Foundation
import ZappPlugins
import ApplicasterSDK
import AVKit
import BrightcovePlayerSDK

protocol PlayerAdapter {
    var playerController: UIViewController { get }
    var currentItem: ZPPlayable { get }
    
    func play()
    func pause()
    func stop()
}

class PlayerAdapterImp: NSObject, PlayerAdapter {
    var playerController: UIViewController {
        return controller
    }
    
    let currentItem: ZPPlayable
    
    private lazy var controller: PlayerViewController = {
        PlayerViewController(playerController: player)
    }()
    
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

public class BrightcovePlayerPlugin: APPlugablePlayerBase {
    
    // MARK: - Properties
    
    private let adapter: PlayerAdapter
    
    init(adapter: PlayerAdapter) {
        self.adapter = adapter
    }
    
    // MARK: - ZPPlayerProtocol
    
    public static func pluggablePlayerInit(playableItems items: [ZPPlayable]?, configurationJSON: NSDictionary?) -> ZPPlayerProtocol? {
        guard let videos = items else { return nil }
        
        let manager: BCOVPlayerSDKManager = BCOVPlayerSDKManager.shared()
        let controller: BCOVPlaybackController = manager.createPlaybackController()
        
        let adapter = PlayerAdapterImp(player: controller, item: videos.first!)
        let instance = BrightcovePlayerPlugin(adapter: adapter)
        
        return instance
    }
    
    public override func pluggablePlayerViewController() -> UIViewController? {
        return adapter.playerController
    }
    
    public func pluggablePlayerCurrentUrl() -> NSURL? {
        return adapter.currentItem
            .contentVideoURLPath()
            .flatMap { NSURL(string: $0) }
    }
    
    public func pluggablePlayerCurrentPlayableItem() -> ZPPlayable? {
        return adapter.currentItem
    }

    public override func presentPlayerFullScreen(_ rootViewController: UIViewController, configuration: ZPPlayerConfiguration?) {
        presentPlayerFullScreen(rootViewController, configuration: configuration) { [weak self] in
            self?.playVideo()
        }
    }
    
    public override func presentPlayerFullScreen(_ rootViewController: UIViewController,
                                                 configuration: ZPPlayerConfiguration?,
                                                 completion: (() -> Void)?) {
        let animated: Bool = configuration?.animated ?? true
        let rootVC: UIViewController = rootViewController.topmostModal()
        let playerVC = adapter.playerController
        
        rootVC.present(playerVC, animated: animated, completion: completion)
    }

    public override func pluggablePlayerPlay(_ configuration: ZPPlayerConfiguration?) {
        adapter.play()
    }
    
    public override func pluggablePlayerPause() {
        adapter.pause()
    }
    
    public override func pluggablePlayerStop() {
        adapter.stop()
    }

    public override func pluggablePlayerIsPlaying() -> Bool {
        return false
    }
    
    public override func pluggablePlayerAddInline(_ rootViewController: UIViewController, container : UIView) {
        let playerVC = adapter.playerController
        rootViewController.addChildViewController(playerVC, to: container)
        playerVC.view.matchParent()
    }
    
    public override func pluggablePlayerRemoveInline(){
        let container = adapter.playerController.view.superview
        super.pluggablePlayerRemoveInline()
        container?.removeFromSuperview()
    }
    
    open override func pluggablePlayerType() -> ZPPlayerType {
        return BrightcovePlayerPlugin.pluggablePlayerType()
    }
    
    public static func pluggablePlayerType() -> ZPPlayerType {
        return .undefined
    }
    
    // MARK: - Private
    
    private func playVideo() {
        adapter.play()
    }
}
