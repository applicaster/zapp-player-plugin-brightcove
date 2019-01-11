import Foundation
import ZappPlugins
import ApplicasterSDK
import BrightcovePlayerSDK
import BrightcoveIMA
import GoogleInteractiveMediaAds

public class BrightcovePlayerPlugin: APPlugablePlayerBase {
    
    // MARK: - Properties
    
    weak var playerController: UIViewController?
    
    private let player: PlayerAdapterProtocol
    private let analytics: AnalyticsAdapterProtocol
    
    // MARK: - Lifecycle
    
    init(adapter: PlayerAdapterProtocol,
         analytics: AnalyticsAdapterProtocol = MorpheusAnalyticsAdapter()) {
        self.player = adapter
        self.analytics = analytics
    }
    
    // MARK: - ZPPlayerProtocol
    
    public static func pluggablePlayerInit(playableItems items: [ZPPlayable]?,
                                           configurationJSON: NSDictionary?) -> ZPPlayerProtocol? {
        guard let videos = items else {
            APLoggerError("No playable item found, return nil")
            return nil
        }
        
        APLoggerInfo(videos.first!.analyticsParams()!.debugDescription)
        
        APLoggerInfo("Configuration: \(String(describing: configurationJSON))")
        APLoggerInfo("Items: \(videos.map { $0.toString() })")
        
        let adapter = PlayerAdapter(items: videos)
        let instance = BrightcovePlayerPlugin(adapter: adapter)
        
        return instance
    }
    
    public override func pluggablePlayerViewController() -> UIViewController? {
        APLoggerInfo("Returning \(String(describing: playerController))")
        return playerController
    }
    
    public func pluggablePlayerCurrentUrl() -> NSURL? {
        return player.currentItem
            .flatMap { $0.contentVideoURLPath() }
            .flatMap { NSURL(string: $0) }
    }
    
    public func pluggablePlayerCurrentPlayableItem() -> ZPPlayable? {
        return player.currentItem
    }

    // MARK: - Inline playback
    
    public override func pluggablePlayerAddInline(_ rootViewController: UIViewController, container: UIView) {
        APLoggerVerbose("Adding to \(container) of \(rootViewController)")
        
        let playerVC = createPlayerController(mode: .inline)
        rootViewController.addChildViewController(playerVC, to: container)
        playerVC.view.matchParent()
        player.setupPlayer(atContainer: playerVC)
        
        analytics.track(item: player.currentItem!, mode: .inline)
    }
    
    public override func pluggablePlayerRemoveInline() {
        APLoggerVerbose("Removing inline player")
        
        analytics.complete(item: player.currentItem!, mode: .inline, progress: player.playbackState)
        
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

        player.didEndPlayback = { [weak playerVC] in
            playerVC?.close()
        }
        
        analytics.track(item: player.currentItem!, mode: .fullscreen)
        
        playerVC.onDismiss = { [player, analytics] in
            analytics.complete(item: player.currentItem!,
                               mode: .fullscreen,
                               progress: player.playbackState)
        }
        
        player.setupPlayer(atContainer: playerVC)

        rootVC.present(playerVC, animated: animated, completion: completion)
    }

    // MARK: - Playback controls
    
    public override func pluggablePlayerPlay(_ configuration: ZPPlayerConfiguration?) {
        APLoggerVerbose("Item: \(String(describing: player.currentItem?.toString()))")
        APLoggerVerbose("Configuration: \(String(describing: configuration?.toString()))")
        player.play()
    }
    
    public override func pluggablePlayerPause() {
        player.pause()
    }
    
    public override func pluggablePlayerStop() {
        player.stop()
    }

    // MARK: - Playback state
    
    public override func pluggablePlayerIsPlaying() -> Bool {
        let isPlaying = playerState() == .playing
        APLoggerVerbose("Return \(isPlaying)")
        return isPlaying
    }
    
    public func playerState() -> ZPPlayerState {
        return player.playerState
    }
    
    // MARK: - Playback progress
    
    public func playbackDuration() -> TimeInterval {
        return player.playbackState.duration
    }
    
    public func playbackPosition() -> TimeInterval {
        return player.playbackState.progress
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
        player.play()
    }
    
    private func createPlayerController(mode: PlayerScreenMode) -> PlayerViewController {
        let builder = PlayerViewBuilder()
        builder.mode = mode
        
        let playerVC = PlayerViewController(builder: builder, adapter: player)
        
        playerController = playerVC
        return playerVC
    }
}
