import Foundation
import ZappPlugins
import BrightcovePlayerSDK

protocol PlayerViewControllerFactory {
    func controller(for item: ZPPlayable, mode: PlayerScreenMode) -> UIViewController
}

class PlayerViewControllerFactoryImp: PlayerViewControllerFactory {
    
    private let player: BCOVPlaybackController
    
    init(player: BCOVPlaybackController) {
        self.player = player
    }
    
    func controller(for item: ZPPlayable, mode: PlayerScreenMode) -> UIViewController {
        let controller = UIViewController()
        let view: UIView = controller.view
        
        let videoView = playerView(for: item, mode: mode, from: controller)
        
        view.addSubview(videoView)
        
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        videoView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        videoView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        videoView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        return controller
    }
    
    //MARK: - Private
    
    private func playerView(for item: ZPPlayable, mode: PlayerScreenMode, from vc: UIViewController) -> BCOVPUIPlayerView {
        let controls = controlView(for: item)
        
        let options = BCOVPUIPlayerViewOptions()
        options.presentingViewController = vc
        
        let videoView: BCOVPUIPlayerView = BCOVPUIPlayerView(playbackController: player,
                                                             options: options,
                                                             controlsView: controls)
        
        switch mode {
            case .fullscreen:
                controls.screenModeButton.isHidden = true
            case .inline:
                break
        }
        
        return videoView
    }
    
    private func controlView(for item: ZPPlayable) -> BCOVPUIBasicControlView {
        return item.isLive() ? .withLiveLayout() : .withVODLayout()
    }
}
