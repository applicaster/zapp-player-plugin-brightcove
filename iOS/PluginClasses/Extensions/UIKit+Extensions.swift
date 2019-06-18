import Foundation

extension UIButton {

    static func blurredRoundedButton(radius: CGFloat = 5.0) -> UIButton {
        let button = UIButton(type: .system)
        
        let blur = UIBlurEffect(style: .dark)
        let blurredView = UIVisualEffectView(effect: blur)
        
        blurredView.isUserInteractionEnabled = false
        button.insertSubview(blurredView, at: 0)
        
        blurredView.layer.cornerRadius = radius
        blurredView.layer.masksToBounds = true
        
        blurredView.matchParent()
        
        return button
    }
}
