import Foundation
import ZappPlugins
import BrightcovePlayerSDK

protocol PlayerViewBuilder {
    func build(for vc: PlayerViewController) -> BCOVPUIPlayerView
    func configureLayout(for view: BCOVPUIBasicControlView, item: ZPPlayable, vc: PlayerViewController)
}

class PlayerViewBuilderImp: PlayerViewBuilder {
    var mode: PlayerScreenMode = .fullscreen
    
    private let player: BCOVPlaybackController
    
    init(player: BCOVPlaybackController) {
        self.player = player
    }

    func build(for vc: PlayerViewController) -> BCOVPUIPlayerView {
        let controls = BCOVPUIBasicControlView.withVODLayout()
        controls?.layout = nil
        
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

    func configureLayout(for view: BCOVPUIBasicControlView, item: ZPPlayable, vc: PlayerViewController) {
        view.layout = item.isLive() ? BCOVPUIControlLayout.basicLive() : BCOVPUIControlLayout.basicVOD()
        
        switch mode {
        case .fullscreen:
            let button: BCOVPUIButton = view.screenModeButton
            button.setTitle(button.secondaryTitle, for: .normal)
            button.removeTarget(nil, action: nil, for: .allTouchEvents)
            button.addTarget(vc, action: #selector(PlayerViewController.close), for: .touchUpInside)
        case .inline:
            break
        }
    }
}
