//
//  AnalyticParamsBuilder.swift
//  BrightcovePlayerPlugin
//
//  Created by Roman Karpievich on 3/19/19.
//

import Foundation
import BrightcovePlayerSDK

class AnalyticParamsBuilder {
    
    public var duration = 0.0 {
        didSet {
            parameters[AnalyticsKeys.itemDuration.rawValue] = String.create(fromInterval: duration)
        }
    }
    
    public var progress = 0.0 {
        didSet {
            parameters[AnalyticsKeys.timecode.rawValue] = String.create(fromInterval: progress)
        }
    }
    
    public var isLive = false {
        didSet {
            let isLive = self.isLive ? "Live" : "VOD"
            parameters[AnalyticsKeys.videoType.rawValue] = isLive
        }
    }
    
    public var timecodeFrom = 0.0 {
        didSet {
            parameters[AnalyticsKeys.timecodeFrom.rawValue] = String.create(fromInterval: timecodeFrom)
        }
    }
    public var timecodeTo = 0.0 {
        didSet {
            parameters[AnalyticsKeys.timecodeTo.rawValue] = String.create(fromInterval: timecodeTo)
        }
    }
    
    public var durationInVideo = 0.0 {
        didSet {
            parameters[AnalyticsKeys.durationInVideo.rawValue] = String.create(fromInterval: durationInVideo)
        }
    }
    
    public var originalView: BCOVPUIScreenMode = .full {
        didSet {
            parameters[AnalyticsKeys.originalView.rawValue] = stringValue(from: originalView)
        }
    }
    
    public var newView: BCOVPUIScreenMode = .full {
        didSet {
            parameters[AnalyticsKeys.newView.rawValue] = stringValue(from: newView)
        }
    }
    
    public var viewSwitchCounter = 0 {
        didSet {
            parameters[AnalyticsKeys.switchInstance.rawValue] = "\(viewSwitchCounter)"
        }
    }
    
    public var seekDirection = "" {
        didSet {
            parameters[AnalyticsKeys.seekDirection.rawValue] = seekDirection
        }
    }
    
    private(set) var parameters: [String: String] = [:]
    
    // MARK: - Private methods
    
    private func stringValue(from screenMode: BCOVPUIScreenMode) -> String {
        switch screenMode {
        case .full:
            return "Full Screen"
        case .normal:
            return "Inline"
        }
    }
}
