import Foundation
import ZappPlugins
import BrightcovePlayerSDK

protocol PlayerViewControllerFactory {
    func controller(for item: ZPPlayable, mode: PlayerScreenMode, from vc: UIViewController) -> UIViewController
}

class PlayerViewControllerFactoryImp: PlayerViewControllerFactory {
    
    private let player: BCOVPlaybackController
    
    init(player: BCOVPlaybackController) {
        self.player = player
    }
    
    func controller(for item: ZPPlayable,
                    mode: PlayerScreenMode,
                    from vc: UIViewController) -> UIViewController {
        return PlayerViewController() { self.playerView(for: item, mode: mode, from: vc, to: $0) }
    }
    
    //MARK: - Private
    
    private func playerView(for item: ZPPlayable,
                            mode: PlayerScreenMode,
                            from vc: UIViewController,
                            to playerVC: PlayerViewController) -> BCOVPUIPlayerView {
        let controls = controlView(for: item)
        
        let options = BCOVPUIPlayerViewOptions()
        options.presentingViewController = vc.tabBarController
        
        let videoView: BCOVPUIPlayerView = BCOVPUIPlayerView(playbackController: player,
                                                             options: options,
                                                             controlsView: controls)
        
        switch mode {
            case .fullscreen:
                let button: BCOVPUIButton = controls.screenModeButton
                button.setTitle(button.secondaryTitle, for: .normal)
                button.removeTarget(nil, action: nil, for: .allTouchEvents)
                button.addTarget(playerVC, action: #selector(PlayerViewController.close), for: .touchUpInside)
            case .inline:
                break
        }
        
        return videoView
    }
    
    private func controlView(for item: ZPPlayable) -> BCOVPUIBasicControlView {
        return item.isLive() ? .withLiveLayout() : .withVODLayout()
    }
}
