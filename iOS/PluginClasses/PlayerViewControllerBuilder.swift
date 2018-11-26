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
        
        switch mode {
        case .fullscreen:
            setupCloseButton(for: videoView, vc: vc)
        case .inline:
            break
        }
        
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
        
        view.progressSlider.flatMap {
            $0.minimumTrackTintColor = .white
        }
        
        switch mode {
        case .fullscreen:
            // Since we need to hide screen mode button, finding the layout view that contains screenModeButton
            guard let items = view.layout.allLayoutItems as? Set<BCOVPUILayoutView> else { return }
            items.first { $0.subviews.contains(view.screenModeButton) }
                .flatMap { $0.isRemoved = true }
            view.setNeedsLayout()            
        case .inline:
            break
        }
    }
    
    // MARK: -- Private
    
    private func setupCloseButton(for view: BCOVPUIPlayerView, vc: PlayerViewController) {
        let button = UIButton.blurredRoundedButton()
        button.accessibilityIdentifier = "brightcove_player_close_button" // Accessibility ids for automation matters
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button.setTitle("\u{2573}", for: .normal)
        button.tintColor = .white
        button.addTarget(vc, action: #selector(PlayerViewController.close), for: .touchUpInside)
        
        let controls = view.controlsFadingView!
        controls.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.leftAnchor.constraint(equalTo: controls.leftAnchor, constant: 12).isActive = true
        button.topAnchor.constraint(equalTo: controls.topAnchor, constant: 12).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.widthAnchor.constraint(equalToConstant: 44).isActive = true
    }
}
