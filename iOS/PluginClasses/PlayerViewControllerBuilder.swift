import Foundation
import ZappPlugins
import BrightcovePlayerSDK

protocol PlayerViewControllerBuilder {
    func build(for item: ZPPlayable, mode: PlayerScreenMode) -> UIViewController
}

class PlayerViewControllerBuilderImp: PlayerViewControllerBuilder {
    
    private let player: BCOVPlaybackController
    
    init(player: BCOVPlaybackController) {
        self.player = player
    }
    
    func build(for item: ZPPlayable,
               mode: PlayerScreenMode) -> UIViewController {
        return PlayerViewController() { self.playerView(for: item, mode: mode, to: $0) }
    }
    
    //MARK: - Private
    
    private func playerView(for item: ZPPlayable,
                            mode: PlayerScreenMode,
                            to playerVC: PlayerViewController) -> BCOVPUIPlayerView {
        let controls = createControlView(for: item, mode: mode, vc: playerVC)
        let options = createOptions(mode: mode, vc: playerVC)

        let videoView: BCOVPUIPlayerView = BCOVPUIPlayerView(playbackController: player,
                                                             options: options,
                                                             controlsView: controls)
        
        return videoView
    }
    
    private func createOptions(mode: PlayerScreenMode, vc: PlayerViewController) -> BCOVPUIPlayerViewOptions {
        let options = BCOVPUIPlayerViewOptions()
        
        switch mode {
        case .fullscreen:
            options.presentingViewController = vc
        case .inline:
            options.presentingViewController = UIApplication.shared
                .keyWindow?
                .rootViewController?
                .topmostModal()
        }
        
        return options
    }
    
    private func createControlView(for item: ZPPlayable,
                                   mode: PlayerScreenMode,
                                   vc: UIViewController) -> BCOVPUIBasicControlView {
        let controls: BCOVPUIBasicControlView = item.isLive() ? .withLiveLayout() : .withVODLayout()
        
        switch mode {
        case .fullscreen:
            let button: BCOVPUIButton = controls.screenModeButton
            button.setTitle(button.secondaryTitle, for: .normal)
            button.removeTarget(nil, action: nil, for: .allTouchEvents)
            button.addTarget(vc, action: #selector(PlayerViewController.close), for: .touchUpInside)
        case .inline:
            break
        }
        
        return controls
    }
}
