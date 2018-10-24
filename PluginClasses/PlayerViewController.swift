import Foundation

class PlayerViewController: UIViewController {
    
    let playerViewBuilder: (PlayerViewController) -> UIView

    required init(playerViewBuilder: @escaping (PlayerViewController) -> UIView) {
        self.playerViewBuilder = playerViewBuilder
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let playerView = playerViewBuilder(self)

        view.addSubview(playerView)
        
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        playerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        playerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    @objc
    func close() { dismiss(animated: true, completion: nil) }
}
