import Foundation
import ZappPlugins
import BrightcovePlayerSDK

class PlayerViewController: UIViewController {
    
    // MARK: Properies
    
    private let builder: PlayerViewBuilder
    private let adapter: PlayerAdapter
    
    lazy var playerView: BCOVPUIPlayerView = { self.builder.build(for: self) }()
    
    // MARK: - Lifecycle
    
    required init(builder: PlayerViewBuilder, adapter: PlayerAdapter) {
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
    }
    
    // MARK: - Actions
    
    @objc func close() { dismiss(animated: true, completion: nil) }
    
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
            guard let strongSelf = self else { return }
            let controls = strongSelf.playerView.controlsView!
            strongSelf.builder.configureLayout(for: controls, item: item, vc: strongSelf)
        }
    }
}
