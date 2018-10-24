import Foundation
import ZappPlugins
import ApplicasterSDK
import BrightcovePlayerSDK

public class BrightcovePlayerPlugin: APPlugablePlayerBase {
    
    // MARK: - Properties
    
    weak var playerController: UIViewController?
    
    private let adapter: PlayerAdapter
    private let factory: PlayerViewControllerFactory

    // MARK: - Lifecycle
    
    init(adapter: PlayerAdapter, factory: PlayerViewControllerFactory) {
        self.adapter = adapter
        self.factory = factory
    }
    
    // MARK: - ZPPlayerProtocol
    
    public static func pluggablePlayerInit(playableItems items: [ZPPlayable]?, configurationJSON: NSDictionary?) -> ZPPlayerProtocol? {
        guard let videos = items else { return nil }
        
        let manager: BCOVPlayerSDKManager = BCOVPlayerSDKManager.shared()
        let controller: BCOVPlaybackController = manager.createPlaybackController()
        
        let adapter = PlayerAdapterImp(player: controller, item: videos.first!)
        let factory = PlayerViewControllerFactoryImp(player: controller)
        
        let instance = BrightcovePlayerPlugin(adapter: adapter, factory: factory)
        
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
        let playerVC = createPlayerController(for: adapter.currentItem,
                                              mode: .inline,
                                              from: rootViewController)
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
        let playerVC = createPlayerController(for: adapter.currentItem,
                                              mode: .fullscreen,
                                              from: rootViewController)
        
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
                                        mode: PlayerScreenMode,
                                        from vc: UIViewController) -> UIViewController {
        let playerVC = factory.controller(for: item,
                                          mode: mode,
                                          from: vc)
        playerController = playerVC
        return playerVC
    }
}
