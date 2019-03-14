import Foundation
import ZappPlugins
import BrightcovePlayerSDK
import BrightcoveIMA
import GoogleInteractiveMediaAds

protocol PlayerAdvertisementEventsDelegate: AnyObject {
    func willLoadAds(forAdTagURL adTagURL: String,
                     forItem item: ZPPlayable)
    
    func eventOccured(_ event: BCOVPlaybackSessionLifecycleEvent,
                      duringSession session: BCOVPlaybackSession,
                      forItem item: ZPPlayable)
}

protocol PlaybackAnalyticEventsDelegate: AnyObject {
    func eventOccurred(_ event: AnalyticsEvent, params: [AnyHashable: Any], timed: Bool)
}

class PlayerViewController: UIViewController, IMAWebOpenerDelegate, PlaybackEventsDelegate {
    
    // MARK: - Properies
    
    var builder: PlayerViewBuilderProtocol
    let player: PlayerAdapterProtocol
    
    var onDismiss: (() -> Void)?
    
    lazy var playerView: BCOVPUIPlayerView = {
        self.builder.buildPlayerView()
    }()
    private var errorView: ErrorView?
    
    open var isAdPlaybackBlocked = false
    open var adManager: IMAAdsManager?
    
    weak var delegate: PlayerAdvertisementEventsDelegate?
    weak var analyticEventDelegate: PlaybackAnalyticEventsDelegate?
    
    var isContentPaused = false
    // MARK: - Lifecycle
    
    required init(builder: PlayerViewBuilderProtocol, player: PlayerAdapterProtocol) {
        self.builder = builder
        self.player = player

        super.init(nibName: nil, bundle: nil)
        
        self.player.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayerView()
        setupPlayer()
        setupAccessibilityIdentifiers()
        subscribeToNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isBeingDismissed { onDismiss?() }

        player.pause()
        player.player.pauseAd()
        super.viewWillDisappear(animated)
    }
    
    open func setupPlayer() {
        player.setupPlayer(atContainer: self)
        player.didSwitchToItem = { [weak self] item in
            self?.builder.configureControlsLayout(isLiveEvent: item.isLive())
        }
        player.didEndPlayback = { [weak self] in
            self?.close()
        }
    }
    
    // MARK: - Actions
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private
    
    private func setupPlayerView() {
        view.addSubview(playerView)
        
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        playerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        playerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func setupAccessibilityIdentifiers() {
        self.view.accessibilityIdentifier = "brightcove_player_screen"
        self.playerView.accessibilityIdentifier = "brightcove_player_stream_view"
        self.playerView.controlsView.accessibilityIdentifier = "brightcove_player_controls_view"
    }
    
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(wentBackground),
                                               name: NSNotification.Name.UIApplicationWillResignActive,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(wentForeground),
                                               name: NSNotification.Name.UIApplicationDidBecomeActive,
                                               object: nil)
    }
    
    @objc private func wentBackground() {
        if view.window != nil {
            if isContentPaused {
                player.player.pauseAd()
            } else {
                player.pause()
            }
        }
    }
    
    @objc private func wentForeground() {
        if view.window != nil {
            if isContentPaused {
                player.player.resumeAd()
            } else {
                player.resume()
            }
        }
    }
    
    private func showPlaybackError() {
        let reachabilityStatus = ZAAppConnector.sharedInstance().connectivityDelegate?.getCurrentConnectivityState()
        let errorType: ErrorViewTypes = reachabilityStatus == .offline ? .network : .video
        errorView?.removeFromSuperview()
        errorView = builder.errorView(withType: errorType)
        
        switch builder.mode {
        case .fullscreen:
            errorView!.frame = self.view.bounds
            self.view.addSubview(errorView!)
        case .inline:
            let rootViewController = UIApplication.shared.delegate?.window??.rootViewController
            errorView!.frame = rootViewController!.view.bounds
            rootViewController!.view.addSubview(errorView!)
        }
        
        isAdPlaybackBlocked = true
    }
    
    // MARK: - IMAWebOpenerDelegate methods
    
    func webOpenerDidClose(inAppBrowser webOpener: NSObject!) {
        player.resumeAdPlayback()
    }
    
    // MARK: - PlaybackEventsDelegate methods
    
    func willLoadAds(forAdTagURL adTagURL: String,
                     forItem item: ZPPlayable) {
        delegate?.willLoadAds(forAdTagURL: adTagURL, forItem: item)
    }
    
    func eventOccured(_ event: BCOVPlaybackSessionLifecycleEvent,
                      duringSession session: BCOVPlaybackSession,
                      forItem item: ZPPlayable) {
        switch event.eventType {
        case "kBCOVPlaybackSessionLifecycleEventPlayRequest":
            let isPlaybackLikelyToKeepUp = session.player.currentItem?.isPlaybackLikelyToKeepUp ?? false
            if isPlaybackLikelyToKeepUp == false {
                showPlaybackError()
            }
        case kBCOVIMALifecycleEventAdsLoaderLoaded:
            if let manager = event.properties[kBCOVIMALifecycleEventPropertyKeyAdsManager] as? IMAAdsManager {
                self.adManager = manager
            }
        case kBCOVIMALifecycleEventAdsLoaderFailed:
            let currentTime = CMTimeGetSeconds(session.player.currentTime()).rounded(.down)
            playerView.controlsView.progressSlider.removeMarker(atPosition: currentTime)
            fallthrough
        case "kBCOVPlaybackSessionLifecycleEventAdProgress",
             kBCOVIMALifecycleEventAdsManagerDidReceiveAdEvent,
             kBCOVIMALifecycleEventAdsManagerDidReceiveAdError:
            delegate?.eventOccured(event, duringSession: session, forItem: item)
            if isAdPlaybackBlocked == true {
                player.player.pauseAd()
            }
        case kBCOVPlaybackSessionLifecycleEventFail,
             kBCOVPlaybackSessionLifecycleEventResumeFail,
             kBCOVPlaybackSessionLifecycleEventPlaybackStalled:
            if let error = event.properties[kBCOVPlaybackSessionEventKeyError] as? NSError {
                var videoPlayError = VideoPlayError(from: error, forItem: item)
                videoPlayError.itemDuration = "\(session.player.currentItem!.duration.seconds)"
                analyticEventDelegate?.eventOccurred(.playbackError,
                                                     params: videoPlayError.dictionary,
                                                     timed: false)
            }
            
            showPlaybackError()
        case kBCOVPlaybackSessionLifecycleEventPlaybackRecovered:
            let reachabilityStatus = ZAAppConnector.sharedInstance().connectivityDelegate?.getCurrentConnectivityState()
            if reachabilityStatus != .offline {
                errorView?.removeFromSuperview()
                isAdPlaybackBlocked = false
            }
        case kBCOVIMALifecycleEventAdsManagerDidRequestContentPause:
            isContentPaused = true
        case kBCOVIMALifecycleEventAdsManagerDidRequestContentResume:
            isContentPaused = false
        default:
            break
        }
    }
    
}
