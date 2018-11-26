import Foundation
import ZappPlugins
import BrightcovePlayerSDK
import ApplicasterSDK

class PlayerViewController: UIViewController {
    
    // MARK: Properies
    
    private let builder: PlayerViewBuilder
    private let adapter: PlayerAdapter
    
    var onDismiss: (() -> Void)?
    
    lazy var playerView: BCOVPUIPlayerView = { self.builder.build(for: self) }()
    
    // MARK: - Lifecycle
    
    required init(builder: PlayerViewBuilder, adapter: PlayerAdapter) {
        APLoggerVerbose("Builder: \(builder), adapter: \(adapter)")
        self.builder = builder
        self.adapter = adapter

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayerView()
        setupAdapter()
        setupAccessibilityIdentifiers()
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

        adapter.pause()
        super.viewWillDisappear(animated)
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
    
    private func setupAdapter() {
        adapter.didSwitchToItem = { [weak self] item in
            APLoggerVerbose("Switching to playable item: \(item.toString())")
            guard let strongSelf = self else { return }
            let controls = strongSelf.playerView.controlsView!
            strongSelf.builder.configureLayout(for: controls, item: item, vc: strongSelf)
        }
    }
    
    private func setupAccessibilityIdentifiers() {
        self.view.accessibilityIdentifier = "brightcove_player_screen"
        self.playerView.accessibilityIdentifier = "brightcove_player_stream_view"
        self.playerView.controlsView.accessibilityIdentifier = "brightcove_player_controls_view"
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        APLoggerVerbose("Parent: \(parent.debugDescription)")
    }
}
