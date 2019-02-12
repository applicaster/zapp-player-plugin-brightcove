//
//  ErrorView.swift
//  BrightcovePlayerPlugin
//
//  Created by Roman Karpievich on 1/24/19.
//

import UIKit

enum ErrorViewTypes {
    case network
    case video
}

class ErrorView: UIView {
    
    @IBOutlet var errorIcon: UIImageView!
    @IBOutlet var errorIconHeight: NSLayoutConstraint!
    @IBOutlet var errorMessageLabel: UILabel!
    @IBOutlet var actionButton: UIButton!
    @IBOutlet private var closeButton: UIButton!
    
    open var type = ErrorViewTypes.network {
        didSet {
            switch type {
            case .network:
                errorIcon.image = #imageLiteral(resourceName: "Connectivity.png")
                errorMessageLabel.text = "We are experiencing connectivity issues. Please make sure you’re connected to the Internet and try again."
                actionButton.setImage(#imageLiteral(resourceName: "Refresh.png"), for: .normal)
                actionButton.setTitle("Refresh", for: .normal)
                break
            case .video:
                errorIcon.image = #imageLiteral(resourceName: "Connectivity.png")
                errorIconHeight.constant = 0
                errorMessageLabel.text = "The video encountered an error and cannot be played. Click the icon below to go back."
                actionButton.setImage(#imageLiteral(resourceName: "Back.png"), for: .normal)
                actionButton.setTitle("Back", for: .normal)
                break
            }
        }
    }
    
    open var closeButtonAction = {
        
    }
    
    open var actionButtonAction = {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        actionButton.layer.borderColor = UIColor.white.cgColor
    }
    
    // MARK: - Private methods
    
    @IBAction private func actionButtonPressed(_ sender: Any) {
        actionButtonAction()
    }
    
    @IBAction private func closeButtonPressed(_ sender: Any) {
        closeButtonAction()
    }
}
