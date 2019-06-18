import Foundation
import ZappPlugins
import BrightcovePlayerSDK
import BrightcoveIMA
import GoogleInteractiveMediaAds

struct Progress {
    var progress: TimeInterval = .infinity
    var duration: TimeInterval = .infinity
    
    var isValid: Bool {
        return progress.isFinite && duration.isFinite
    }
    
    var isCompleted: Bool {
        return isValid && progress >= duration
    }
}

protocol PlayerAdapterProtocol: class {
    var currentItem: ZPPlayable? { get }
    var player: BCOVPlaybackController! { get set}
    
    var playbackState: Progress { get }
    var playerState: ZPPlayerState { get }
    
    var didEndPlayback: (() -> Void)? { get set }
    var didSwitchToItem: ((ZPPlayable) -> Void)? { get set }
    var delegate: PlaybackEventsDelegate? { get set }

    func setupPlayer(atContainer playerViewController: PlayerViewController)
    func play()
    func pause()
    func stop()
    func resume()
    func resumeAdPlayback()
}

protocol PlaybackEventsDelegate: AnyObject {
    func willLoadAds(forAdTagURL adTagURL: String,
                     forItem item: ZPPlayable)
    func eventOccured(_ event: BCOVPlaybackSessionLifecycleEvent,
                      duringSession session: BCOVPlaybackSession,
                      forItem item: ZPPlayable)
    func rewindButtonPressed(at: TimeInterval)
    func seekOccured(from: TimeInterval, to: TimeInterval)
    func didStartPlaybackSession()
    func pauseButtonPressed()
}

class PlayerAdapter: NSObject, PlayerAdapterProtocol {

    // MARK: - Properties
    
    var player: BCOVPlaybackController!

    private(set) var playerState: ZPPlayerState = .undefined
    private(set) var playbackState: Progress = Progress()
    
    var didEndPlayback: (() -> Void)?
    var didSwitchToItem: ((ZPPlayable) -> Void)?
    
    private var items: [ZPPlayable]
    
    private var videos: [BCOVVideo] = [] {
        didSet { player.setVideos(videos as NSFastEnumeration) }
    }
    
    private(set) var currentItem: ZPPlayable? {
        didSet { currentItem.flatMap { didSwitchToItem?($0) } }
    }
    
    weak var playerView: BCOVPUIPlayerView?
    weak var delegate: PlaybackEventsDelegate?
    
    var isPausedButtonPressed = false
    
    // MARK: - Lifecycle
    
    init(items: [ZPPlayable]) {
        self.currentItem = items.first
        self.items = items
        
        super.init()
    }
    
    // MARK: - PlayerAdapterProtocol methods
    
    func setupPlayer(atContainer playerViewController: PlayerViewController) {
        let manager = BCOVPlayerSDKManager.shared()!
        let imaSettings = IMASettings()
        let renderSettings = IMAAdsRenderingSettings()
        renderSettings.webOpenerPresentingController = playerViewController
        renderSettings.webOpenerDelegate = playerViewController
        let imaPlaybackSessionOptions = [kBCOVIMAOptionIMAPlaybackSessionDelegateKey: self]
        
        let type = currentItem!.advertisementType
        
        let sidecarSessionProvider = manager.createSidecarSubtitlesSessionProvider(withUpstreamSessionProvider: nil)
        
        if let adsRequestPolicy = self.adsRequestPolicy(forType: type) {
            let imaSessionProvider = manager.createIMASessionProvider(with: imaSettings,
                                                           adsRenderingSettings: renderSettings,
                                                           adsRequestPolicy: adsRequestPolicy,
                                                           adContainer: playerViewController.playerView,
                                                           companionSlots: nil,
                                                           upstreamSessionProvider: sidecarSessionProvider,
                                                           options: imaPlaybackSessionOptions)
            self.player = manager.createPlaybackController(with: imaSessionProvider,
                                                           viewStrategy: nil)
        } else {
            self.player = manager.createPlaybackController(with: sidecarSessionProvider,
                                                           viewStrategy: nil)
        }
        
        playerViewController.playerView.playbackController = self.player
        playerView = playerViewController.playerView
    
        self.player.delegate = self
        self.player.isAutoPlay = true
        self.player.isAutoAdvance = true
    }
    
    func play() {
        loadItems()
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func stop() {
        player.pause()
        player.seekWithoutAds(CMTime.zero) { [weak self] _ in self?.playerState = .stopped }
    }
    
    func resume() {
        player.play()
    }
    
    func resumeAdPlayback() {
        player.resumeAd()
    }
    
    // MARK: - Private
    
    private func loadItems() {
        currentItem = items.first
        self.videos = items.map({ $0.bcovVideo })
    }
    
    private func adsRequestPolicy(forType type: Advertisement) -> BCOVIMAAdsRequestPolicy? {
        switch type {
        case .vast(_):
            let policy = BCOVCuePointProgressPolicy.init(processingCuePoints: .processFinalCuePoint,
                                                         resumingPlaybackFrom: .fromContentPlayhead,
                                                         ignoringPreviouslyProcessedCuePoints: false)
            let adsRequestPolicy = BCOVIMAAdsRequestPolicy(vastAdTagsInCuePointsAndAdsCuePointProgressPolicy: policy)
            return adsRequestPolicy
        case .vmap(_):
            return BCOVIMAAdsRequestPolicy.videoPropertiesVMAPAdTagUrl()
        case .none:
            return nil
        }
    }
    
    @objc private func pauseButtonPressed() {
        if isPausedButtonPressed == false {
            delegate?.pauseButtonPressed()
        }
        
        isPausedButtonPressed.toggle()
    }
}

extension PlayerAdapter: BCOVPlaybackControllerDelegate {
    func playbackController(_ controller: BCOVPlaybackController!, didAdvanceTo session: BCOVPlaybackSession!) {
        guard let source = session.video.sources.first as? BCOVSource,
            let sourceURL = source.url?.absoluteString else {
            return
        }
        
        guard let video = items.first(where: { $0.contentVideoURLPath() == sourceURL }) else {
            return
        }
        
        currentItem = video
        playbackState = Progress()
        
        delegate?.didStartPlaybackSession()
        playerView?.controlsView.playbackButton.addTarget(self,
                                                          action: #selector(pauseButtonPressed),
                                                          for: .touchDown)
    }
    
    func playbackController(_ controller: BCOVPlaybackController!,
                            playbackSession session: BCOVPlaybackSession!,
                            didChangeDuration duration: TimeInterval) {
        playbackState.duration = duration
    }
    
    func playbackController(_ controller: BCOVPlaybackController!,
                            playbackSession session: BCOVPlaybackSession!,
                            didProgressTo progress: TimeInterval) {
        let previousProgress = playbackState.progress
        let minSeekInterval = 1.0
        if abs(progress - previousProgress) > minSeekInterval, previousProgress.isNormal == true {
            switch session.player.rate {
            case 0:
                delegate?.seekOccured(from: previousProgress, to: progress)
            case 1:
                delegate?.rewindButtonPressed(at: previousProgress)
            default:
                break
            }
        }
        
        if progress.isFinite {
            playbackState.progress = progress
            
        }
    }
    
    func playbackController(_ controller: BCOVPlaybackController!,
                            playbackSession session: BCOVPlaybackSession!,
                            didReceive lifecycleEvent: BCOVPlaybackSessionLifecycleEvent!) {
        ZPPlayerState(event: lifecycleEvent).flatMap { playerState = $0 }
        
        delegate?.eventOccured(lifecycleEvent,
                               duringSession: session,
                               forItem: currentItem!)
    }
    
    func playbackController(_ controller: BCOVPlaybackController!, didCompletePlaylist playlist: NSFastEnumeration!) {
        didEndPlayback?()
    }
}

// MARK: - BCOVIMAPlaybackSessionDelegate

extension PlayerAdapter: BCOVIMAPlaybackSessionDelegate {
    
    func willCallIMAAdsLoaderRequestAds(with adsRequest: IMAAdsRequest!, forPosition position: TimeInterval) {
        guard let adTagURL = adsRequest.adTagUrl else {
            return
        }
        delegate?.willLoadAds(forAdTagURL: adTagURL, forItem: currentItem!)
    }
}
