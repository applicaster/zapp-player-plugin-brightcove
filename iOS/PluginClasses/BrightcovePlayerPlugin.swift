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
        guard let videos = items else {
            APLoggerError("No playable item found, return nil")
            return nil
        }
        
        APLoggerInfo("Configuration: \(String(describing: configurationJSON))")
        APLoggerInfo("Items: \(videos.map { $0.toString() })")
        
        let manager: BCOVPlayerSDKManager = BCOVPlayerSDKManager.shared()
        let controller: BCOVPlaybackController = manager.createPlaybackController()
        
        APLoggerInfo("manager: \(manager), controller: \(controller)")
        
        let adapter = PlayerAdapterImp(player: controller, items: videos)
        let instance = BrightcovePlayerPlugin(adapter: adapter)
        
        return instance
    }
    
    public override func pluggablePlayerViewController() -> UIViewController? {
        APLoggerInfo("Returning \(String(describing: playerController))")
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
        APLoggerVerbose("Adding to \(container) of \(rootViewController)")
        let playerVC = createPlayerController(mode: .inline)
        rootViewController.addChildViewController(playerVC, to: container)
        playerVC.view.matchParent()
    }
    
    public override func pluggablePlayerRemoveInline(){
        APLoggerVerbose("Removing inline player")
        let container = playerController?.view.superview
        super.pluggablePlayerRemoveInline()
        container?.removeFromSuperview()
    }
    
    deinit {
        APLoggerInfo("Plugin deinitialized")
    }
    
    // MARK: - Fullscreen playback
    
    public override func presentPlayerFullScreen(_ rootViewController: UIViewController,
                                                 configuration: ZPPlayerConfiguration?) {
        APLoggerVerbose("Player config: \(String(describing: configuration?.toString()))")
        presentPlayerFullScreen(rootViewController, configuration: configuration) { self.playVideo() }
    }
    
    public override func presentPlayerFullScreen(_ rootViewController: UIViewController,
                                                 configuration: ZPPlayerConfiguration?,
                                                 completion: (() -> Void)?) {
        APLoggerVerbose("Player config: \(String(describing: configuration?.toString()))")
        let animated: Bool = configuration?.animated ?? true
        let rootVC: UIViewController = rootViewController.topmostModal()
        let playerVC = createPlayerController(mode: .fullscreen)
        adapter.didEndPlayback = { [weak playerVC] in playerVC?.close() }

        rootVC.present(playerVC, animated: animated, completion: completion)
    }

    // MARK: - Playback controls
    
    public override func pluggablePlayerPlay(_ configuration: ZPPlayerConfiguration?) {
        APLoggerVerbose("Item: \(String(describing: adapter.currentItem?.toString()))")
        APLoggerVerbose("Configuration: \(String(describing: configuration?.toString()))")
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
        let isPlaying = playerState() == .playing
        APLoggerVerbose("Return \(isPlaying)")
        return isPlaying
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
