import Foundation
import ZappPlugins
import ApplicasterSDK
import BrightcovePlayerSDK
import BrightcoveIMA
import GoogleInteractiveMediaAds

public class BrightcovePlayerPlugin: APPlugablePlayerBase, PlaybackAnalyticEventsDelegate {
    
    // MARK: - Properties
    
    var playerViewController: PlayerViewController?
    
    private let analytics: AnalyticsAdapterProtocol
    private let adAnalytics: PlayerAdvertisementEventsDelegate
    
    // MARK: - Lifecycle
    
    init(analytics: AnalyticsAdapterProtocol = MorpheusAnalyticsAdapter()) {
        self.analytics = analytics
        self.adAnalytics = PlayerAdvertisement(analytics: analytics)
        
        super.init()
    }
    
    // MARK: - ZPPlayerProtocol
    
    public static func pluggablePlayerInit(playableItems items: [ZPPlayable]?,
                                           configurationJSON: NSDictionary?) -> ZPPlayerProtocol? {
        guard let videos = items else {
            APLoggerError("No playable item found, return nil")
            return nil
        }
        
        var errorViewConfig: ErrorViewConfiguration?
        if let configuration = configurationJSON {
            errorViewConfig = ErrorViewConfiguration(fromDictionary: configuration)
        }
        
        APLoggerInfo(videos.first!.analyticsParams()!.debugDescription)
        
        APLoggerInfo("Configuration: \(String(describing: configurationJSON))")
        APLoggerInfo("Items: \(videos.map { $0.toString() })")
        
        let playerViewController = ViewControllerFactory.createPlayerViewController(videoItems: videos, errorViewConfig: errorViewConfig)
        let instance = BrightcovePlayerPlugin()
        instance.playerViewController = playerViewController
        
        return instance
    }
    
    public override func pluggablePlayerViewController() -> UIViewController? {
        return self.playerViewController
    }
    
    public func pluggablePlayerCurrentUrl() -> NSURL? {
        let item = self.playerViewController?.player.currentItem
        let urlString = item?.contentVideoURLPath() ?? ""
        return NSURL(string: urlString)
    }
    
    public func pluggablePlayerCurrentPlayableItem() -> ZPPlayable? {
        return self.playerViewController?.player.currentItem
    }

    // MARK: - Inline playback
    
    public override func pluggablePlayerAddInline(_ rootViewController: UIViewController, container: UIView) {
        APLoggerVerbose("Adding to \(container) of \(rootViewController)")
        
        guard let playerViewController = self.playerViewController else {
            return
        }

        rootViewController.addChildViewController(playerViewController, to: container)
        playerViewController.view.matchParent()
        playerViewController.builder.mode = .inline
        playerViewController.setupPlayer()
        playerViewController.delegate = self.adAnalytics
        playerViewController.analyticEventDelegate = self
        
        if let item = self.playerViewController?.player.currentItem {
            analytics.track(item: item,
                            mode: .inline)
        }
    }
    
    public override func pluggablePlayerRemoveInline() {
        APLoggerVerbose("Removing inline player")
        
        if let item = self.playerViewController?.player.currentItem,
            let progress = self.playerViewController?.player.playbackState {
            analytics.complete(item: item,
                               mode: .inline,
                               progress: progress)
        }
        
        let container = self.playerViewController?.view.superview
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
        presentPlayerFullScreen(rootViewController, configuration: configuration) {
            self.playerViewController?.player.play()
        }
    }
    
    public override func presentPlayerFullScreen(_ rootViewController: UIViewController,
                                                 configuration: ZPPlayerConfiguration?,
                                                 completion: (() -> Void)?) {
        APLoggerVerbose("Player config: \(String(describing: configuration?.toString()))")
        
        guard let playerViewController = self.playerViewController,
            let topmostViewController = rootViewController.topmostModal(),
            let currentItem = playerViewController.player.currentItem  else {
            return
        }
        
        let animated: Bool = configuration?.animated ?? true
        playerViewController.builder.mode = .fullscreen
        playerViewController.setupPlayer()
        playerViewController.delegate = self.adAnalytics
        playerViewController.onDismiss = { [weak self] in
            self?.analytics.complete(item: playerViewController.player.currentItem!,
                                     mode: .fullscreen,
                                     progress: playerViewController.player.playbackState)
        }
        playerViewController.analyticEventDelegate = self
        
        analytics.track(item: currentItem, mode: .fullscreen)
        
        topmostViewController.present(playerViewController,
                                      animated: animated,
                                      completion: completion)
    }

    // MARK: - Playback controls
    
    public override func pluggablePlayerPlay(_ configuration: ZPPlayerConfiguration?) {
        self.playerViewController?.player.play()
    }
    
    public override func pluggablePlayerPause() {
        self.playerViewController?.player.pause()
    }
    
    public override func pluggablePlayerStop() {
        self.playerViewController?.player.stop()
    }

    // MARK: - Playback state
    
    public override func pluggablePlayerIsPlaying() -> Bool {
        let isPlaying = playerState() == .playing
        APLoggerVerbose("Return \(isPlaying)")
        return isPlaying
    }
    
    public func playerState() -> ZPPlayerState {
        return self.playerViewController!.player.playerState
    }
    
    // MARK: - Plugin type
    
    open override func pluggablePlayerType() -> ZPPlayerType {
        return BrightcovePlayerPlugin.pluggablePlayerType()
    }
    
    public static func pluggablePlayerType() -> ZPPlayerType {
        return .undefined
    }
    
    // MARK: - PlaybackAnalyticEventsDelegate methods
    
    func eventOccurred(_ event: AnalyticsEvent, params: [AnyHashable : Any], timed: Bool) {
        analytics.track(event: event, withParameters: params, timed: timed)
    }
}
