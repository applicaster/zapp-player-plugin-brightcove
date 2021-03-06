//
//  Player.swift
//  DefaultPlayer
//
//  Created by Anton Kononenko on 12/2/18.
//  Copyright © 2018 Applicaster. All rights reserved.
//

import Foundation
import React
import BrightcovePlayerSDK
import ZappPlugins

enum PlayerEvents {
    case onVideoLoadStart
    case onVideoLoad
    case onVideoEnd
    case onVideoFullscreenPlayerWillPresent
    case onVideoFullscreenPlayerDidPresent
    case onVideoFullscreenPlayerWillDismiss
    case onVideoFullscreenPlayerDidDismiss
    case onVideoError
}

protocol PlayerEventsResponder: AnyObject {
    func eventOccured(event: PlayerEvents, infoDictionary: [String: String])
}

extension PlayerEventsResponder {
    func eventOccured(event: PlayerEvents, infoDictionary: [String: String] = [String: String]()) {
        return eventOccured(event: event, infoDictionary: infoDictionary)
    }
}

@objc public class BrightcovePlayer: UIView {
    
    var fullscreenPlayerPresented: Bool = false
    var playerViewController: PlayerViewController?
    @objc public var onVideoLoadStart: RCTBubblingEventBlock?
    @objc public var onVideoLoad: RCTBubblingEventBlock?
    @objc public var onVideoEnd: RCTBubblingEventBlock?
    @objc public var onVideoFullscreenPlayerWillPresent: RCTBubblingEventBlock?
    @objc public var onVideoFullscreenPlayerDidPresent: RCTBubblingEventBlock?
    @objc public var onVideoFullscreenPlayerWillDismiss: RCTBubblingEventBlock?
    @objc public var onVideoFullscreenPlayerDidDismiss: RCTBubblingEventBlock?
    @objc public var onVideoError: RCTBubblingEventBlock?
    @objc public var entry: [String: Any]?
   
    @objc public var src: NSDictionary? {
        didSet {
            if playerViewController == nil {
                playerViewController = ViewControllerFactory.createPlayerViewController()
            
                playerViewController?.eventsResponderDelegate = self
                playerViewController?.videoSourceDictionary = src
                var viewController = firstAvailableUIViewController()
                if viewController == nil,
                    let keyWindow = UIApplication.shared.keyWindow {
                    
                    viewController = keyWindow.rootViewController
                    if let children = viewController?.children {
                        viewController = children.last;
                    }
                }
                guard let playerViewController = playerViewController else {
                    return
                }
                viewController?.present(playerViewController, animated: true) {
                    self.playerViewController?.player.play()
                }
            } else {
                playerViewController?.videoSourceDictionary = src
                playerViewController?.player.play()
            }
        }
    }
    
    @objc public var paused: Bool = false {
        didSet {
            paused ? playerViewController?.player.pause() : playerViewController?.player.resume()
        }
    }
    
    public init(eventDispatcher: RCTEventDispatcher) {
        super.init(frame: .zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        return nil
    }
    
}

extension BrightcovePlayer: PlayerEventsResponder {
    func eventOccured(event: PlayerEvents, infoDictionary: [String: String]) {
        switch event {
        case .onVideoLoadStart:
            if let onVideoLoadStart = onVideoLoadStart {
                onVideoLoadStart(["target": reactTag ?? NSNull()])
            }
        case .onVideoLoad:
            if let onVideoLoad = onVideoLoad {
                onVideoLoad(["target": reactTag ?? NSNull()])
            }
        case .onVideoEnd:
            if let onVideoEnd = onVideoEnd {
                onVideoEnd(["target": reactTag ?? NSNull()])
                self.playerViewController?.dismiss(animated: true, completion: nil)
            }
        case .onVideoFullscreenPlayerWillPresent:
            if let onVideoFullscreenPlayerWillPresent = onVideoFullscreenPlayerWillPresent {
                onVideoFullscreenPlayerWillPresent(["target": reactTag ?? NSNull()])
            }
        case .onVideoFullscreenPlayerDidPresent:
            if let onVideoFullscreenPlayerDidPresent = onVideoFullscreenPlayerDidDismiss {
                onVideoFullscreenPlayerDidPresent(["target": reactTag ?? NSNull()])
            }
        case .onVideoFullscreenPlayerWillDismiss:
            if let onVideoFullscreenPlayerWillDismiss = onVideoFullscreenPlayerWillDismiss {
                onVideoFullscreenPlayerWillDismiss(["target": reactTag ?? NSNull()])
            }
        case .onVideoFullscreenPlayerDidDismiss:
            if let onVideoFullscreenPlayerDidDismiss = onVideoFullscreenPlayerDidDismiss {
                onVideoFullscreenPlayerDidDismiss(["target": reactTag ?? NSNull()])
            }
        case .onVideoError:
            if let onVideoError = onVideoError {
                onVideoError(["error": infoDictionary,
                              "target": reactTag ?? NSNull()])
            }
        }
    }
}
