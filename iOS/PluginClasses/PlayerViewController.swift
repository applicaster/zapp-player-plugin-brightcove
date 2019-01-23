import Foundation
import ZappPlugins
import BrightcovePlayerSDK
import ApplicasterSDK
import GoogleInteractiveMediaAds

class PlayerViewController: UIViewController, IMAWebOpenerDelegate {
    
    // MARK: - Properies
    
    var builder: PlayerViewBuilderProtocol
    let player: PlayerAdapterProtocol
    
    var onDismiss: (() -> Void)?
    
    lazy var playerView: BCOVPUIPlayerView = {
        self.builder.build(for: self)
    }()
    
    // MARK: - Lifecycle
    
    required init(builder: PlayerViewBuilderProtocol, player: PlayerAdapterProtocol) {
        self.builder = builder
        self.player = player

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayerView()
        setupPlayer()
        setupAccessibilityIdentifiers()
        subscribeToNotifications()
        APLoggerVerbose("Setup completed, view is loaded")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        APLoggerVerbose("Is presenting: \(isBeingPresented)")
        APLoggerVerbose("Is moving to parent VC: \(isMovingToParentViewController)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        APLoggerVerbose("Is dismissed: \(isBeingDismissed)")
        if isBeingDismissed { onDismiss?() }

        player.pause()
        super.viewWillDisappear(animated)
    }
    
    open func setupPlayer() {
        player.setupPlayer(atContainer: self)
        player.didSwitchToItem = { [weak self] item in
            APLoggerVerbose("Switching to playable item: \(item.toString())")
            guard let strongSelf = self else { return }
            let controls = strongSelf.playerView.controlsView!
            strongSelf.builder.configureLayout(for: controls, item: item, vc: strongSelf)
        }
        player.didEndPlayback = { [weak self] in
            self?.close()
        }
    }
    
    // MARK: - Actions
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private
    
    private func setupPlayerView() {
        view.addSubview(playerView)
        
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        playerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        playerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func setupAccessibilityIdentifiers() {
        self.view.accessibilityIdentifier = "brightcove_player_screen"
        self.playerView.accessibilityIdentifier = "brightcove_player_stream_view"
        self.playerView.controlsView.accessibilityIdentifier = "brightcove_player_controls_view"
    }
    
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(wentBackground),
                                               name: NSNotification.Name.UIApplicationWillResignActive,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(wentForeground),
                                               name: NSNotification.Name.UIApplicationDidBecomeActive,
                                               object: nil)
    }
    
    @objc private func wentBackground() {
        if view.window != nil {
            player.pause()
        }
    }
    
    @objc private func wentForeground() {
        if view.window != nil {
            player.resume()
        }
    }
    
    // MARK: - IMAWebOpenerDelegate methods
    
    func webOpenerDidClose(inAppBrowser webOpener: NSObject!) {
        player.resumeAdPlayback()
    }
}
