import Foundation
import ZappPlugins
import BrightcovePlayerSDK

protocol PlayerViewBuilder {
    func build(for vc: PlayerViewController) -> BCOVPUIPlayerView
}

class PlayerViewBuilderImp: PlayerViewBuilder {
    var mode: PlayerScreenMode = .fullscreen
    
    private let item: ZPPlayable
    private let player: BCOVPlaybackController
    
    init(player: BCOVPlaybackController, item: ZPPlayable) {
        self.player = player
        self.item = item
    }

    func build(for vc: PlayerViewController) -> BCOVPUIPlayerView {
        let controls = createControlView(for: vc)
        let options = createOptions(for: vc)
        
        let videoView: BCOVPUIPlayerView = BCOVPUIPlayerView(playbackController: player,
                                                             options: options,
                                                             controlsView: controls)
        
        return videoView
    }
    
    //MARK: - Private
    
    private func createOptions(for vc: PlayerViewController) -> BCOVPUIPlayerViewOptions {
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
    
    private func createControlView(for vc: UIViewController) -> BCOVPUIBasicControlView {
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
