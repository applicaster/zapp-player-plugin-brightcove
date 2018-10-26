import Foundation
import ZappPlugins

class PlayerViewController: UIViewController {
    
    let builder: PlayerViewBuilder
    let adapter: PlayerAdapter
    
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
        let playerView = builder.build(for: self)
        
        view.addSubview(playerView)
        
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        playerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        playerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    @objc
    func close() {
        dismiss(animated: true, completion: nil) }
}
