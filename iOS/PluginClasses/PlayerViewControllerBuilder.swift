import Foundation
import ZappPlugins
import BrightcovePlayerSDK

protocol PlayerViewBuilderProtocol {
    var mode: PlayerScreenMode { get set }
    var playerViewController: PlayerViewController! { get set }
    var errorViewConfiguration: ErrorViewConfiguration? { get set }
    
    func buildPlayerView() -> BCOVPUIPlayerView
    func configureControlsLayout(isLiveEvent: Bool)
    func errorView(withType type: ErrorViewTypes) -> ErrorView
}

class PlayerViewBuilder: PlayerViewBuilderProtocol {
    var mode: PlayerScreenMode = .fullscreen
    weak var playerViewController: PlayerViewController!
    var errorViewConfiguration: ErrorViewConfiguration?
    
    var options: BCOVPUIPlayerViewOptions {
        let options = BCOVPUIPlayerViewOptions()
        
        switch mode {
        case .fullscreen:
            options.presentingViewController = playerViewController
        case .inline:
            options.presentingViewController = UIApplication.shared
                .keyWindow?
                .rootViewController?
                .topmostModal()
        }
        
        return options
    }
    
    // MARK: - PlayerViewBuilderProtocol methods
    
    func buildPlayerView() -> BCOVPUIPlayerView {
        let controls = BCOVPUIBasicControlView.withVODLayout()
        controls?.layout = nil
        
        let videoView: BCOVPUIPlayerView = BCOVPUIPlayerView(playbackController: nil,
                                                             options: options,
                                                             controlsView: controls)
        
        switch mode {
        case .fullscreen:
            setupCloseButton(for: videoView)
        case .inline:
            break
        }
        
        return videoView
    }
    
    func configureControlsLayout(isLiveEvent: Bool) {
        let controlsView = playerViewController.playerView.controlsView!
        controlsView.layout = isLiveEvent ? BCOVPUIControlLayout.basicLive() : BCOVPUIControlLayout.basicVOD()
        controlsView.progressSlider?.minimumTrackTintColor = .white
        
        switch mode {
        case .fullscreen:
            // Since we need to hide screen mode button, finding the layout view that contains screenModeButton
            guard let items = controlsView.layout.allLayoutItems as? Set<BCOVPUILayoutView> else { return }
            items.first { $0.subviews.contains(controlsView.screenModeButton) }
                .flatMap { $0.isRemoved = true }
            controlsView.setNeedsLayout()
        case .inline:
            break
        }
    }
    
    func errorView(withType type: ErrorViewTypes) -> ErrorView {
        let errorView = ErrorView.nibInstance()
        errorView.type = type
        errorView.closeButtonAction = {
            switch self.mode {
            case .fullscreen:
                self.playerViewController.close()
            case .inline:
                errorView.removeFromSuperview()
            }
        }
        
        switch type {
        case .network:
            errorView.actionButtonAction = {
                errorView.removeFromSuperview()
                self.playerViewController.isAdPlaybackBlocked = false
                self.playerViewController.player.player.resumeAd()
                self.playerViewController.player.resume()
            }
        case .video:
            errorView.actionButtonAction = {
                switch self.mode {
                case .fullscreen:
                    self.playerViewController.close()
                case .inline:
                    self.playerViewController.adManager?.destroy()
                    errorView.removeFromSuperview()
                }
            }
        }
        
        if let config = errorViewConfiguration {
            switch type {
            case .network:
                errorView.errorMessageLabel.text = config.connectivityErrorMessage
                errorView.actionButton.setTitle(config.connectivityErrorButtonText, for: .normal)
            case .video:
                errorView.errorMessageLabel.text = config.videoPlayErrorMessage
                errorView.actionButton.setTitle(config.videoPlayErrorButtonText, for: .normal)
            }
        }
        
        return errorView
    }
    
    // MARK: - Private
    
    private func setupCloseButton(for view: BCOVPUIPlayerView) {
        let button = UIButton.blurredRoundedButton()
        button.accessibilityIdentifier = "brightcove_player_close_button" // Accessibility ids for automation matters
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button.setTitle("\u{2573}", for: .normal)
        button.tintColor = .white
        button.addTarget(playerViewController, action: #selector(PlayerViewController.close), for: .touchUpInside)
        
        let controls = view.controlsFadingView!
        controls.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.leftAnchor.constraint(equalTo: controls.leftAnchor, constant: 12).isActive = true
        button.topAnchor.constraint(equalTo: controls.topAnchor, constant: 12).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.widthAnchor.constraint(equalToConstant: 44).isActive = true
    }
}
