import Foundation
import ZappPlugins
import BrightcovePlayerSDK
import BrightcoveIMA
import GoogleInteractiveMediaAds

public class BrightcovePlayerPlugin: NSObject, ZPPlayerProtocol, PlaybackAnalyticEventsDelegate, ZPPluggableScreenProtocol {
    
    // MARK: - Properties
    
    var playerViewController: PlayerViewController?
    
    private var analytics: AnalyticsAdapterProtocol
    private let adAnalytics: PlayerAdvertisementEventsDelegate
    
    @objc weak public var screenPluginDelegate: ZPPlugableScreenDelegate?
    private var pluginModel: ZPPluginModel?
    private var screenModel: ZLScreenModel?
    private var dataSourceModel: NSObject?

    // MARK: - Lifecycle
    
    init(analytics: AnalyticsAdapterProtocol = MorpheusAnalyticsAdapter()) {
        self.analytics = analytics
        self.adAnalytics = PlayerAdvertisement(analytics: analytics)
        
        super.init()
    }
    
    public required init?(pluginModel: ZPPluginModel,
                          screenModel: ZLScreenModel,
                          dataSourceModel: NSObject?) {
        self.pluginModel = pluginModel
        self.screenModel = screenModel
        self.dataSourceModel = dataSourceModel
        self.analytics = MorpheusAnalyticsAdapter()
        self.adAnalytics = PlayerAdvertisement(analytics: analytics)
        
        super.init()
    }
    
    // MARK: - ZPPlayerProtocol
    
    public static func pluggablePlayerInit(playableItems items: [ZPPlayable]?,
                                           configurationJSON: NSDictionary?) -> ZPPlayerProtocol? {
        guard let videos = items else {
            return nil
        }
        
        var errorViewConfig: ErrorViewConfiguration?
        if let configuration = configurationJSON {
            errorViewConfig = ErrorViewConfiguration(fromDictionary: configuration)
        }
        
        let playerViewController = ViewControllerFactory.createPlayerViewController(videoItems: videos, errorViewConfig: errorViewConfig)
        let instance = BrightcovePlayerPlugin()
        instance.playerViewController = playerViewController
        
        return instance
    }
    
    public func pluggablePlayerViewController() -> UIViewController? {
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
    
    public func pluggablePlayerAddInline(_ rootViewController: UIViewController, container: UIView) {
        guard let playerViewController = self.playerViewController else {
            return
        }
        
        playerViewController.builder.mode = .inline

        rootViewController.addChildViewController(playerViewController, to: container)
        playerViewController.view.matchParent()
        playerViewController.setupPlayer()
        playerViewController.delegate = self.adAnalytics
        playerViewController.analyticEventDelegate = self
        analytics.screenMode = .inline
    }
    
    public func pluggablePlayerRemoveInline() {
        if let item = self.playerViewController?.player.currentItem,
            let progress = self.playerViewController?.player.playbackState {
            analytics.complete(item: item,
                               progress: progress)
        }
        
        let container = self.playerViewController?.view.superview
        container?.removeFromSuperview()
    }
    
    // MARK: - Fullscreen playback
    
    public func presentPlayerFullScreen(_ rootViewController: UIViewController,
                                                 configuration: ZPPlayerConfiguration?) {
        presentPlayerFullScreen(rootViewController, configuration: configuration) {
            self.playerViewController?.player.play()
        }
    }
    
    public func presentPlayerFullScreen(_ rootViewController: UIViewController,
                                                 configuration: ZPPlayerConfiguration?,
                                                 completion: (() -> Void)?) {
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
                                     progress: playerViewController.player.playbackState)
        }
        playerViewController.analyticEventDelegate = self
    
        analytics.screenMode = .fullscreen
        topmostViewController.present(playerViewController,
                                      animated: animated,
                                      completion: completion)
    }

    // MARK: - Playback controls
    
    public func pluggablePlayerPlay(_ configuration: ZPPlayerConfiguration?) {
        self.playerViewController?.player.play()
    }
    
    public func pluggablePlayerPause() {
        self.playerViewController?.player.pause()
    }
    
    public func pluggablePlayerStop() {
        self.playerViewController?.player.stop()
    }

    // MARK: - Playback state
    
    public func pluggablePlayerIsPlaying() -> Bool {
        return playerState() == .playing
    }
    
    public func playerState() -> ZPPlayerState {
        return self.playerViewController!.player.playerState
    }
    
    // MARK: - Plugin type
    
    open func pluggablePlayerType() -> ZPPlayerType {
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
