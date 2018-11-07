import Foundation
import ZappPlugins
import BrightcovePlayerSDK
import ApplicasterSDK

protocol PlayerAdapter: class {    
    var currentItem: ZPPlayable? { get }
    var player: BCOVPlaybackController { get }
    
    var playerState: ZPPlayerState { get }
    
    var currentProgress: TimeInterval { get }
    var currentDuration: TimeInterval { get }
    
    var didEndPlayback: (() -> Void)? { get set }
    var didSwitchToItem: ((ZPPlayable) -> Void)? { get set }
    
    func play()
    func pause()
    func stop()
    func resume()
}

class PlayerAdapterImp: NSObject, PlayerAdapter {

    // MARK: - Properties
    
    let player: BCOVPlaybackController
    
    private(set) var playerState: ZPPlayerState = .undefined
    
    private(set) var currentProgress: TimeInterval = .infinity
    private(set) var currentDuration: TimeInterval = .infinity
    
    private let loader: VideoLoader = StaticURLLoader()
    
    var didEndPlayback: (() -> Void)?
    var didSwitchToItem: ((ZPPlayable) -> Void)?
    
    private var items: [ZPPlayable]
    
    private var videos: [BCOVVideo] = [] {
        didSet { player.setVideos(videos as NSFastEnumeration) }
    }
    
    private(set) var currentItem: ZPPlayable? {
        didSet { currentItem.flatMap { didSwitchToItem?($0) } }
    }
    
    // MARK: - Lifecycle
    
    init(player: BCOVPlaybackController, items: [ZPPlayable]) {
        self.player = player
        self.currentItem = items.first
        self.items = items
        
        super.init()
        
        setup()
    }
    
    // MARK: - Actions
    
    func setup() {
        setupPlayer()
    }
    
    func play() {
        APLoggerDebug("Play")
        loadItems()
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func stop() {
        player.pause()
        player.seekWithoutAds(kCMTimeZero) { [weak self] _ in self?.playerState = .stopped }
    }
    
    func resume() {
        player.play()
    }
    
    // MARK: - Private
    
    private func setupPlayer() {
        player.delegate = self
        player.isAutoPlay = true
        player.isAutoAdvance = true
    }
    
    private func loadItems() {
        APLoggerDebug("Load items")
        currentItem = items.first
        
        loader.load(items: items) { [weak self] result in
            APLoggerDebug("Loaded: \(items)")
            switch result {
            case let .success(videos):
                self?.videos = videos
            case let .failure(error):
                print(error)
            }
        }
    }
}

extension PlayerAdapterImp: BCOVPlaybackControllerDelegate {
    func playbackController(_ controller: BCOVPlaybackController!, didAdvanceTo session: BCOVPlaybackSession!) {
        APLoggerDebug("Did advance to: \(String(describing: session))")
        currentItem = loader.find(video: session.video, in: items)
    }
    
    func playbackController(_ controller: BCOVPlaybackController!,
                            playbackSession session: BCOVPlaybackSession!,
                            didChangeDuration duration: TimeInterval) {
        currentDuration = duration
    }
    
    func playbackController(_ controller: BCOVPlaybackController!,
                            playbackSession session: BCOVPlaybackSession!,
                            didProgressTo progress: TimeInterval) {
        currentProgress = progress
    }
    
    func playbackController(_ controller: BCOVPlaybackController!,
                            playbackSession session: BCOVPlaybackSession!,
                            didReceive lifecycleEvent: BCOVPlaybackSessionLifecycleEvent!) {
        APLoggerDebug("Session did receive \(lifecycleEvent)")
        ZPPlayerState(event: lifecycleEvent).flatMap { playerState = $0 }
    }
    
    func playbackController(_ controller: BCOVPlaybackController!, didCompletePlaylist playlist: NSFastEnumeration!) {
        APLoggerDebug("Did complete \(String(describing: playlist))")
        didEndPlayback?()
    }
}

extension ZPPlayerState {
    init?(event: BCOVPlaybackSessionLifecycleEvent) {
        switch event.eventType {
            
        case kBCOVPlaybackSessionLifecycleEventPlaybackStalled,
             kBCOVPlaybackSessionLifecycleEventResumeFail,
             kBCOVPlaybackSessionLifecycleEventFail,
             kBCOVPlaybackSessionLifecycleEventFailedToPlayToEndTime:
            self = .interruption
            
        case kBCOVPlaybackSessionLifecycleEventPause:
            self = .paused
            
        case kBCOVPlaybackSessionLifecycleEventPlaybackRecovered,
             kBCOVPlaybackSessionLifecycleEventPlay:
            self = .playing
            
        case kBCOVPlaybackSessionLifecycleEventEnd:
            self = .stopped
            
        case kBCOVPlaybackSessionLifecycleEventPlaybackBufferEmpty,
             kBCOVPlaybackSessionLifecycleEventResumeBegin,
             kBCOVPlaybackSessionLifecycleEventResumeComplete,
             kBCOVPlaybackSessionLifecycleEventReady,
             kBCOVPlaybackSessionLifecycleEventPlaybackLikelyToKeepUp:
            fallthrough
            
        default:
            return nil
        }
    }
}
