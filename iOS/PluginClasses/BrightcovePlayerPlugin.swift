import Foundation
import ZappPlugins
import ApplicasterSDK
import BrightcovePlayerSDK

public class BrightcovePlayerPlugin: APPlugablePlayerBase {
    
    // MARK: - Properties
    
    weak var playerController: UIViewController?
    
    private let adapter: PlayerAdapter

    // MARK: - Lifecycle
    
    init(adapter: PlayerAdapter) {
        self.adapter = adapter
    }
    
    // MARK: - ZPPlayerProtocol
    
    public static func pluggablePlayerInit(playableItems items: [ZPPlayable]?, configurationJSON: NSDictionary?) -> ZPPlayerProtocol? {
        guard let videos = items else { return nil }
        
        let manager: BCOVPlayerSDKManager = BCOVPlayerSDKManager.shared()
        let controller: BCOVPlaybackController = manager.createPlaybackController()
        let adapter = PlayerAdapterImp(player: controller, items: videos)
        let instance = BrightcovePlayerPlugin(adapter: adapter)
        
        return instance
    }
    
    public override func pluggablePlayerViewController() -> UIViewController? {
        return playerController
    }
    
    public func pluggablePlayerCurrentUrl() -> NSURL? {
        return adapter.currentItem
            .flatMap { $0.contentVideoURLPath() }
            .flatMap { NSURL(string: $0) }
    }
    
    public func pluggablePlayerCurrentPlayableItem() -> ZPPlayable? {
        return adapter.currentItem
    }

    // MARK: - Inline playback
    
    public override func pluggablePlayerAddInline(_ rootViewController: UIViewController, container: UIView) {
        let playerVC = createPlayerController(mode: .inline)
        rootViewController.addChildViewController(playerVC, to: container)
        playerVC.view.matchParent()
    }
    
    public override func pluggablePlayerRemoveInline(){
        let container = playerController?.view.superview
        super.pluggablePlayerRemoveInline()
        container?.removeFromSuperview()
    }
    
    // MARK: - Fullscreen playback
    
    public override func presentPlayerFullScreen(_ rootViewController: UIViewController,
                                                 configuration: ZPPlayerConfiguration?) {
        presentPlayerFullScreen(rootViewController, configuration: configuration) { [weak self] in
            self?.playVideo()
        }
    }
    
    public override func presentPlayerFullScreen(_ rootViewController: UIViewController,
                                                 configuration: ZPPlayerConfiguration?,
                                                 completion: (() -> Void)?) {
        let animated: Bool = configuration?.animated ?? true
        let rootVC: UIViewController = rootViewController.topmostModal()
        let playerVC = createPlayerController(mode: .fullscreen)
        
        adapter.didEndPlayback = { [weak playerVC] in playerVC?.close() }
        
        rootVC.present(playerVC, animated: animated, completion: completion)
    }

    // MARK: - Playback controls
    
    public override func pluggablePlayerPlay(_ configuration: ZPPlayerConfiguration?) {
        adapter.play()
    }
    
    public override func pluggablePlayerPause() {
        adapter.pause()
    }
    
    public override func pluggablePlayerStop() {
        adapter.stop()
    }

    // MARK: - Playback state
    
    public override func pluggablePlayerIsPlaying() -> Bool {
        return playerState() == .playing
    }
    
    public func playerState() -> ZPPlayerState {
        return adapter.playerState
    }
    
    // MARK: - Playback progress
    
    public func playbackDuration() -> TimeInterval {
        return adapter.currentDuration
    }
    
    public func playbackPosition() -> TimeInterval {
        return adapter.currentProgress
    }
    
    // MARK: - Plugin type
    
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
    
    private func createPlayerController(mode: PlayerScreenMode) -> PlayerViewController {
        let builder = PlayerViewBuilderImp(player: adapter.player)
        builder.mode = mode
        
        let playerVC = PlayerViewController(builder: builder, adapter: adapter)

        playerController = playerVC
        return playerVC
    }
}
