import Foundation
import ZappPlugins
import ApplicasterSDK
import BrightcovePlayerSDK

public class BrightcovePlayerPlugin: APPlugablePlayerBase {
    
    // MARK: - Properties
    
    weak var playerController: UIViewController?
    
    private let adapter: PlayerAdapter
    private let builder: PlayerViewControllerBuilder

    // MARK: - Lifecycle
    
    init(adapter: PlayerAdapter, builder: PlayerViewControllerBuilder) {
        self.adapter = adapter
        self.builder = builder
    }
    
    // MARK: - ZPPlayerProtocol
    
    public static func pluggablePlayerInit(playableItems items: [ZPPlayable]?, configurationJSON: NSDictionary?) -> ZPPlayerProtocol? {
        guard let videos = items else { return nil }
        
        let manager: BCOVPlayerSDKManager = BCOVPlayerSDKManager.shared()
        let controller: BCOVPlaybackController = manager.createPlaybackController()
        
        let adapter = PlayerAdapterImp(player: controller, item: videos.first!)
        let builder = PlayerViewControllerBuilderImp(player: controller)
        
        let instance = BrightcovePlayerPlugin(adapter: adapter, builder: builder)
        
        return instance
    }
    
    public override func pluggablePlayerViewController() -> UIViewController? {
        return playerController
    }
    
    public func pluggablePlayerCurrentUrl() -> NSURL? {
        return adapter.currentItem
            .contentVideoURLPath()
            .flatMap { NSURL(string: $0) }
    }
    
    public func pluggablePlayerCurrentPlayableItem() -> ZPPlayable? {
        return adapter.currentItem
    }

    // MARK: - Inline playback
    
    public override func pluggablePlayerAddInline(_ rootViewController: UIViewController, container: UIView) {
        let playerVC = createPlayerController(for: adapter.currentItem, mode: .inline)
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
        let playerVC = createPlayerController(for: adapter.currentItem, mode: .fullscreen)
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

    public override func pluggablePlayerIsPlaying() -> Bool {
        return false
    }
    
    // MARK: - Type
    
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
    
    private func createPlayerController(for item: ZPPlayable,
                                        mode: PlayerScreenMode) -> UIViewController {
        let playerVC = builder.build(for: item, mode: mode)
        playerController = playerVC
        return playerVC
    }
}
